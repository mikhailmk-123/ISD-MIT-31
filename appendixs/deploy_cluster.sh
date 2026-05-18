#!/bin/bash

# 1. Очищення старих даних та створення нових директорій
echo "[1/5] Створення директорій для кластера..."
rm -rf /tmp/mongo_cluster
mkdir -p /tmp/mongo_cluster/cfg /tmp/mongo_cluster/shard1 /tmp/mongo_cluster/shard2

# 2. Запуск бекенд-вузлів (Config + Shards) у фоні
echo "[2/5] Запуск Config Server та Shard-вузлів..."
mongod --configsvr --replSet cfg --port 27030 --dbpath /tmp/mongo_cluster/cfg --bind_ip localhost --fork --logpath /tmp/mongo_cluster/cfg.log
mongod --shardsvr --replSet shard1rs --port 27021 --dbpath /tmp/mongo_cluster/shard1 --bind_ip localhost --fork --logpath /tmp/mongo_cluster/shard1.log
mongod --shardsvr --replSet shard2rs --port 27022 --dbpath /tmp/mongo_cluster/shard2 --bind_ip localhost --fork --logpath /tmp/mongo_cluster/shard2.log

# Даємо базі кілька секунд на старт
sleep 3

# 3. Ініціалізація Replica Sets через mongosh
echo "[3/5] Ініціалізація Replica Sets..."
mongosh --port 27030 --eval 'rs.initiate({_id: "cfg", configsvr: true, members: [{ _id: 0, host: "localhost:27030" }]})' --quiet
mongosh --port 27021 --eval 'rs.initiate({_id: "shard1rs", members: [{ _id: 0, host: "localhost:27021" }]})' --quiet
mongosh --port 27022 --eval 'rs.initiate({_id: "shard2rs", members: [{ _id: 0, host: "localhost:27022" }]})' --quiet

# Чекаємо завершення виборів (Leader Election)
echo "Очікування вибору Primary-вузлів (5 секунд)..."
sleep 5

# 4. Запуск маршрутизатора mongos
echo "[4/5] Запуск Ingress-маршрутизатора mongos..."
mongos --configdb cfg/localhost:27030 --port 27020 --bind_ip localhost --fork --logpath /tmp/mongo_cluster/mongos.log

sleep 3

# 5. Налаштування шардування (додавання шардів та активація)
echo "[5/5] Застосування топології шардування..."
mongosh --port 27020 --eval '
sh.addShard("shard1rs/localhost:27021");
sh.addShard("shard2rs/localhost:27022");
sh.enableSharding("performance_test");

// Створюємо індекс під ключ шардування
db.getSiblingDB("performance_test").sales.createIndex({ "category": 1 });

// Вмикаємо шардування колекції
sh.shardCollection("performance_test.sales", { "category": 1 });

print("\n=== СТАТУС РОЗПОДІЛУ ===");
sh.status();
' --quiet

echo "✅ Кластер успішно розгорнуто! Точка входу (mongos): localhost:27020"
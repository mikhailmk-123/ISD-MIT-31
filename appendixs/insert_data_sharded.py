from pymongo import MongoClient
import random
import datetime

# ПІДКЛЮЧЕННЯ ДО MONGOS (Маршрутизатор на порту 27020)
client = MongoClient("mongodb://localhost:27020")
db = client["performance_test"]
collection = db["sales"]

categories = ["Electronics", "Clothing", "Books", "Home", "Sports"]

print("Генерація 100 000 документів у пам'яті...")
documents = [
    {
        "customer_id": random.randint(1, 1000),
        "category": random.choice(categories),
        "amount": random.uniform(5, 500),
        "timestamp": datetime.datetime(2024, random.randint(1, 12), random.randint(1, 28)) 
    }
    for _ in range(100000)
]

print("Виконання пакетної вставки (Bulk Insert)...")
# Mongos автоматично перенаправить різні категорії на різні фізичні шарди
collection.insert_many(documents)
print("✅ 100 000 документів успішно додано у Sharded Cluster!")
CREATE OR REPLACE FUNCTION update_order_total() RETURNS TRIGGER AS $$
DECLARE
    target_order_id INT;
BEGIN
    IF (TG_OP = 'DELETE') THEN
        target_order_id := OLD.order_id;
    ELSE
        target_order_id := NEW.order_id;
    END IF;

    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(t.price), 0)
        FROM order_details od
        JOIN tests t ON od.test_id = t.test_id
        WHERE od.order_id = target_order_id
    )
    WHERE order_id = target_order_id;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_sync_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_details
FOR EACH ROW EXECUTE FUNCTION update_order_total();
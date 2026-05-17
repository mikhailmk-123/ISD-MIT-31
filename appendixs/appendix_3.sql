CREATE TABLE order_details_log (
    log_id SERIAL PRIMARY KEY,
    detail_id INT,
    operation VARCHAR(10),
    old_status test_status_enum,
    new_status test_status_enum,
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50) DEFAULT current_user
);

CREATE OR REPLACE FUNCTION log_test_status_changes() RETURNS TRIGGER AS $$
BEGIN
    IF (TG_OP = 'DELETE') THEN
        INSERT INTO order_details_log (detail_id, operation, old_status)
        VALUES (OLD.detail_id, TG_OP, OLD.status);
        RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF OLD.status IS DISTINCT FROM NEW.status THEN
            INSERT INTO order_details_log (detail_id, operation, old_status, new_status)
            VALUES (NEW.detail_id, TG_OP, OLD.status, NEW.status);
        END IF;
        RETURN NEW;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO order_details_log (detail_id, operation, new_status)
        VALUES (NEW.detail_id, TG_OP, NEW.status);
        RETURN NEW;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_order_details
AFTER INSERT OR UPDATE OR DELETE ON order_details
FOR EACH ROW EXECUTE FUNCTION log_test_status_changes();
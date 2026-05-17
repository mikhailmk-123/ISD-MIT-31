CREATE OR REPLACE FUNCTION get_patient_status(p_patient_id INT) RETURNS VARCHAR AS $$
DECLARE
    total_spent DECIMAL(10, 2);
    patient_status VARCHAR(20);
BEGIN
    SELECT COALESCE(SUM(total_amount), 0) INTO total_spent
    FROM orders
    WHERE patient_id = p_patient_id;

    IF total_spent >= 2000 THEN
        patient_status := 'VIP Patient';
    ELSIF total_spent >= 500 THEN
        patient_status := 'Regular Patient';
    ELSE
        patient_status := 'New Patient';
    END IF;

    RETURN patient_status;
END;
$$ LANGUAGE plpgsql;
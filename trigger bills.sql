CREATE OR REPLACE TRIGGER trg_bill_default_values
BEFORE INSERT ON bills
FOR EACH ROW
BEGIN
    IF :NEW.billing_date IS NULL THEN
        :NEW.billing_date := SYSDATE;
    END IF;

    IF :NEW.status IS NULL THEN
        :NEW.status := 'UNPAID';
    END IF;
END;
/
 

 
DECLARE
    v_max NUMBER;
BEGIN
    SELECT NVL(MAX(payment_id), 0) INTO v_max FROM payments;
    BEGIN
    EXECUTE IMMEDIATE 'DROP SEQUENCE payments_seq';
    EXCEPTION WHEN OTHERS THEN NULL;
    END;
    EXECUTE IMMEDIATE
    'CREATE SEQUENCE payments_seq START WITH ' || (v_max + 1) || ' INCREMENT BY 1';
END;
/
 

CREATE OR REPLACE TRIGGER trg_bill_auto_payment
AFTER UPDATE ON bills
FOR EACH ROW
WHEN (NEW.status = 'PAID' AND OLD.status <> 'PAID')
BEGIN
    INSERT INTO payments (payment_id, bill_id, payment_date, amount)
    VALUES (payments_seq.NEXTVAL, :NEW.bill_id, SYSDATE, :NEW.amount);
END;
/

 

DECLARE
    v_appt_id NUMBER;

    v_patient NUMBER := 101;     
    v_doctor  NUMBER := 201;    
    v_dept    NUMBER;
BEGIN
    SELECT department_id INTO v_dept 
    FROM doctors 
    WHERE doctor_id = v_doctor;
    SELECT NVL(MAX(appointment_id), 0) + 1 INTO v_appt_id FROM appointments;
    INSERT INTO appointments (
        appointment_id, appointment_date, appointment_time,
        doctor_id, department_id, patient_id
    ) VALUES (
        v_appt_id, SYSDATE, '10:00',
        v_doctor, v_dept, v_patient
    );

    DBMS_OUTPUT.PUT_LINE('TEST: Appointment created → ' || v_appt_id);
END;
/

 
DECLARE
    v_bill_id NUMBER;
    v_appt    NUMBER;
BEGIN
    SELECT MAX(appointment_id) INTO v_appt FROM appointments;

    SELECT NVL(MAX(bill_id), 0) + 1 INTO v_bill_id FROM bills;

    INSERT INTO bills (bill_id, appointment_id, amount)
    VALUES (v_bill_id, v_appt, 200);

    DBMS_OUTPUT.PUT_LINE('TEST: Bill created → ' || v_bill_id);
END;
/
 

INSERT INTO payments (payment_id, bill_id, payment_date, amount)
VALUES (
    payments_seq.NEXTVAL,
    (SELECT MAX(bill_id) FROM bills),
    SYSDATE,
    200
);


SELECT * FROM payments 
WHERE bill_id = (SELECT MAX(bill_id) FROM bills);
/

 
UPDATE bills
SET status = 'PAID'
WHERE bill_id = (SELECT MAX(bill_id) FROM bills);
/
 

SELECT * FROM payments 
WHERE bill_id = (SELECT MAX(bill_id) FROM bills)
ORDER BY payment_date;
/

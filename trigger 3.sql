CREATE OR REPLACE TRIGGER trg_no_past_appointments
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
BEGIN
    IF TRUNC(:NEW.appointment_date) < TRUNC(SYSDATE) THEN
        RAISE_APPLICATION_ERROR(-20080,'ERROR: Cannot schedule an appointment in the past.');
    END IF;
END;
/

INSERT INTO appointments (appointment_id, appointment_date, appointment_time, doctor_id, patient_id)
VALUES (9009, DATE '2024-01-01', '10:00', 134, 1);

INSERT INTO appointments (appointment_id, appointment_date, appointment_time, doctor_id, patient_id)
VALUES (9011, SYSDATE, '11:00', 134, 1);

CREATE OR REPLACE TRIGGER trg_dept_no_delete
BEFORE DELETE ON departments
FOR EACH ROW
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count 
    FROM doctors 
    WHERE department_id = :OLD.department_id;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20013,'Cannot delete department: doctors exist');
    END IF;
END;
/

DROP TRIGGER trg_presc_dos;
/

CREATE OR REPLACE TRIGGER trg_presc_dos
BEFORE INSERT ON prescriptions
FOR EACH ROW
BEGIN
    IF :NEW.dosage IS NULL OR TRIM(:NEW.dosage) = '' THEN
        RAISE_APPLICATION_ERROR(
            -20050,
            'ERROR: Dosage cannot be empty! How is the patient supposed to take the medicine???' ||
            CHR(10) ||
            CHR(10) ||
            'AVIASALES PROMO:' || CHR(10) ||
            '   "Forget the medicine… but don’t forget your next flight!"' || CHR(10) ||
            '   Aviasales — cheap flights available now!'
        );
    END IF;
END;
/

INSERT INTO prescriptions (prescription_id, appointment_id, medicine_id, dosage, duration)
VALUES (751, 751, 10, NULL, 7);

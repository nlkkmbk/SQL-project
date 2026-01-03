CREATE OR REPLACE PROCEDURE proc_upcoming_appointments(
    p_doctor_id IN doctors.doctor_id%TYPE
)
IS
    CURSOR cur_appts IS
        SELECT a.appointment_id,
               a.appointment_date,
               a.appointment_time,
               p.first_name AS patient_first,
               p.last_name  AS patient_last
        FROM   appointments a
               JOIN patients p ON a.patient_id = p.patient_id
        WHERE  a.doctor_id = p_doctor_id
          AND  a.appointment_date >TRUNC(SYSDATE)
        ORDER  BY a.appointment_date, a.appointment_time;

    v_row   cur_appts%ROWTYPE;
    v_found BOOLEAN := FALSE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Upcoming Appointments for Doctor ID: ' || p_doctor_id);

    OPEN cur_appts;
    LOOP
        FETCH cur_appts INTO v_row;
        EXIT WHEN cur_appts%NOTFOUND;

        v_found := TRUE;

        DBMS_OUTPUT.PUT_LINE(
            'Appointment ID: ' || v_row.appointment_id ||
            ' | Date: ' || TO_CHAR(v_row.appointment_date, 'YYYY-MM-DD') ||
            ' | Time: ' || v_row.appointment_time ||
            ' | Patient: ' || v_row.patient_first || ' ' || v_row.patient_last
        );
    END LOOP;
    CLOSE cur_appts;

    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No upcoming appointments found.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: No appointments found for Doctor ID ' || p_doctor_id);
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error in proc_upcoming_appointments: ' || SQLERRM);
END proc_upcoming_appointments;
/


CREATE OR REPLACE PROCEDURE proc_doctor_daily_report(
    p_doctor_id IN doctors.doctor_id%TYPE,
    p_date      IN DATE
)
IS
    v_fname doctors.first_name%TYPE;
    v_lname doctors.last_name%TYPE;
    v_email doctors.email%TYPE;
    v_spec  specializations.specialization_name%TYPE;
    v_dep   departments.department_name%TYPE;

    v_appt_count      NUMBER := 0;
    v_unique_patients NUMBER := 0;
    v_treatment_count NUMBER := 0;
    v_presc_count     NUMBER := 0;
BEGIN
    SELECT d.first_name,
           d.last_name,
           d.email,
           s.specialization_name,
           dep.department_name
    INTO   v_fname,
           v_lname,
           v_email,
           v_spec,
           v_dep
    FROM   doctors d
           JOIN specializations s ON d.specialization_id = s.specialization_id
           JOIN departments     dep ON d.department_id = dep.department_id
    WHERE  d.doctor_id = p_doctor_id;

    SELECT COUNT(*)
    INTO   v_appt_count
    FROM   appointments
    WHERE  doctor_id = p_doctor_id
      AND  appointment_date = TRUNC(p_date);

    SELECT COUNT(DISTINCT patient_id)
    INTO   v_unique_patients
    FROM   appointments
    WHERE  doctor_id = p_doctor_id
      AND  appointment_date = TRUNC(p_date);

    SELECT COUNT(*)
    INTO   v_treatment_count
    FROM   treatments t
           JOIN appointments a ON t.appointment_id = a.appointment_id
    WHERE  a.doctor_id       = p_doctor_id
      AND  a.appointment_date = TRUNC(p_date);

    SELECT COUNT(*)
    INTO   v_presc_count
    FROM   prescriptions pr
           JOIN appointments a ON pr.appointment_id = a.appointment_id
    WHERE  a.doctor_id       = p_doctor_id
      AND  a.appointment_date = TRUNC(p_date);

    DBMS_OUTPUT.PUT_LINE('Doctor Daily Report');
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(p_date,'YYYY-MM-DD'));
    DBMS_OUTPUT.PUT_LINE('Doctor: ' || v_fname || ' ' || v_lname);
    DBMS_OUTPUT.PUT_LINE('Email: ' || v_email);
    DBMS_OUTPUT.PUT_LINE('Specialization: ' || v_spec);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_dep);
    DBMS_OUTPUT.PUT_LINE('-------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Appointments: ' || v_appt_count);
    DBMS_OUTPUT.PUT_LINE('Unique Patients: ' || v_unique_patients);
    DBMS_OUTPUT.PUT_LINE('Treatments Performed: ' || v_treatment_count);
    DBMS_OUTPUT.PUT_LINE('Prescriptions Written: ' || v_presc_count);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Error: Doctor ID ' || p_doctor_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error in proc_doctor_daily_report: ' || SQLERRM);
END proc_doctor_daily_report;
/

BEGIN
    proc_upcoming_appointments(p_doctor_id => 134);
END;
/

BEGIN
    proc_doctor_daily_report(
        p_doctor_id => 17,
        p_date      => DATE '2023-05-01'
    );
END;
/

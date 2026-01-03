CREATE OR REPLACE PACKAGE pkg_patient_analytics AS
PROCEDURE proc_patient_history(p_patient_id IN patients.patient_id%TYPE);
PROCEDURE proc_frequent_patients;
FUNCTION fn_patient_most_frequent_doctor(p_patient_id IN patients.patient_id%TYPE) RETURN VARCHAR2;
END pkg_patient_analytics;
/

CREATE OR REPLACE PACKAGE BODY pkg_patient_analytics AS
PROCEDURE proc_patient_history(p_patient_id IN patients.patient_id%TYPE)
IS
  CURSOR c_hist IS
  SELECT DISTINCT
  a.appointment_id,
  a.appointment_date,
  d.diagnosis_name,
  p.first_name AS patient_first,
  p.last_name AS patient_last,
  doc.first_name AS doctor_first,
  doc.last_name AS doctor_last
  FROM appointments a
  JOIN diagnoses d ON d.appointment_id = a.appointment_id
  JOIN patients p ON a.patient_id = p.patient_id
  JOIN doctors doc ON a.doctor_id = doc.doctor_id
  WHERE a.patient_id = p_patient_id
  ORDER BY a.appointment_date DESC;
  v_rec c_hist%ROWTYPE;
  v_found BOOLEAN := FALSE;
  v_exists NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_exists
    FROM patients
    WHERE patient_id = p_patient_id;
    IF v_exists = 0 THEN
    DBMS_OUTPUT.PUT_LINE('Error: Patient ID ' || p_patient_id || ' not found.');
    RETURN;
    END IF;
    DBMS_OUTPUT.PUT_LINE('Medical History for Patient ID: ' || p_patient_id );
    OPEN c_hist;
    LOOP
    FETCH c_hist INTO v_rec;
    EXIT WHEN c_hist%NOTFOUND;
    v_found := TRUE;

   DBMS_OUTPUT.PUT_LINE(
        'Patient: ' || v_rec.patient_first || ' ' || v_rec.patient_last ||
        ', Doctor: ' || v_rec.doctor_first || ' ' || v_rec.doctor_last ||
        ', Date: ' || TO_CHAR(v_rec.appointment_date, 'YYYY-MM-DD') ||
        ', Diagnosis: ' || NVL(v_rec.diagnosis_name, 'No diagnosis')
        );
    END LOOP;
    CLOSE c_hist;
    IF NOT v_found THEN
        DBMS_OUTPUT.PUT_LINE('No appointments found for Patient ID ' || p_patient_id);
    END IF;

EXCEPTION
  WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('Unexpected error in proc_patient_history: ' || SQLERRM);
END proc_patient_history;

PROCEDURE proc_frequent_patients IS
CURSOR cur_frequent_patients IS
SELECT p.patient_id, p.first_name, p.last_name,
    COUNT(a.appointment_id) AS visit_count,
    ROUND(
    (MAX(a.appointment_date) - MIN(a.appointment_date)) /
    NULLIF((COUNT(a.appointment_id) - 1), 0)) AS avg_interval FROM patients p
    JOIN appointments a ON p.patient_id = a.patient_id
    GROUP BY p.patient_id, p.first_name, p.last_name
    HAVING COUNT(a.appointment_id) >= 5
    ORDER BY visit_count DESC;

    rec_patient cur_frequent_patients%ROWTYPE;
    v_found BOOLEAN := FALSE;

    BEGIN
        DBMS_OUTPUT.PUT_LINE('Patients With 5+ Appointments');
    OPEN cur_frequent_patients;
    LOOP
    FETCH cur_frequent_patients INTO rec_patient;
    EXIT WHEN cur_frequent_patients%NOTFOUND;
    v_found := TRUE;
    DBMS_OUTPUT.PUT_LINE(
              'Patient: ' || rec_patient.first_name || ' ' || rec_patient.last_name ||
              ' | Visits: ' || rec_patient.visit_count ||
              ' | Avg Interval: ' || NVL(rec_patient.avg_interval, 0) || ' days'
            );
        END LOOP;

    CLOSE cur_frequent_patients;

    IF NOT v_found THEN
    DBMS_OUTPUT.PUT_LINE('No frequent patients found.');
    END IF;

    EXCEPTION WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('Error: No patient data found.');
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Unexpected error in proc_frequent_patients: ' || SQLERRM);
    END proc_frequent_patients;

FUNCTION fn_patient_most_frequent_doctor(p_patient_id IN patients.patient_id%TYPE) RETURN VARCHAR2 IS

    v_patient_name   VARCHAR2(200);
    v_doctor_name    VARCHAR2(200);
    v_specialization VARCHAR2(200);
    v_department     VARCHAR2(200);
    v_visit_count    NUMBER;
    v_result         VARCHAR2(1000);
BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_patient_name
    FROM patients
    WHERE patient_id = p_patient_id;

    SELECT d.first_name || ' ' || d.last_name,
           s.specialization_name,
           dept.department_name
    INTO v_doctor_name, v_specialization, v_department
    FROM (
        SELECT doctor_id
        FROM appointments
        WHERE patient_id = p_patient_id
        GROUP BY doctor_id
        ORDER BY COUNT(*) DESC
        FETCH FIRST 1 ROWS ONLY
    ) freq
    JOIN doctors d ON d.doctor_id = freq.doctor_id
    JOIN specializations s ON s.specialization_id = d.specialization_id
    JOIN departments dept ON dept.department_id = d.department_id;

    SELECT COUNT(*)
    INTO v_visit_count
    FROM appointments
    WHERE patient_id = p_patient_id
    AND doctor_id = (
    SELECT doctor_id
    FROM appointments
    WHERE patient_id = p_patient_id
    GROUP BY doctor_id
    ORDER BY COUNT(*) DESC
    FETCH FIRST 1 ROWS ONLY
      );

    v_result := '==Most Frequent Doctor Report for Patient ID ' || p_patient_id || ' (' || v_patient_name || ')==' || CHR(10) ||
                'Doctor: ' || v_doctor_name || CHR(10) ||
                'Specialization: ' || NVL(v_specialization,'N/A') || CHR(10) ||
                'Department: ' || NVL(v_department,'N/A') || CHR(10) ||
                'Number of Visits: ' || v_visit_count;

    RETURN v_result;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Patient ID ' || p_patient_id || ' has no doctor visits.';
    WHEN OTHERS THEN
        RETURN 'Unexpected error: ' || SQLERRM;
END fn_patient_most_frequent_doctor;

END pkg_patient_analytics;
/


BEGIN
    pkg_patient_analytics.proc_patient_history(123);  
END;
/



BEGIN
    pkg_patient_analytics.proc_patient_history(4567867);
END;
/


BEGIN
    pkg_patient_analytics.proc_frequent_patients;
END;
/



BEGIN
    DBMS_OUTPUT.PUT_LINE(fn_patient_most_frequent_doctor(130));
END;
/




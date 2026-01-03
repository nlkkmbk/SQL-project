CREATE OR REPLACE PACKAGE pkg_treatment_analytics IS

  PROCEDURE pr_low_stock_medicines(p_threshold IN NUMBER);
  PROCEDURE pr_top_diagnoses(p_limit IN NUMBER);
  PROCEDURE proc_treatment_trends(p_days IN NUMBER);
  PROCEDURE proc_prescription_summary(p_medicine_id IN MEDICINES.medicine_id%TYPE);
  PROCEDURE proc_frequent_treatments(p_limit IN NUMBER);

END pkg_treatment_analytics;
/

CREATE OR REPLACE PACKAGE BODY pkg_treatment_analytics IS
  PROCEDURE pr_low_stock_medicines(p_threshold IN NUMBER) IS
  TYPE t_med_rec IS RECORD (
  name medicines.medicine_name%TYPE,
  stock medicines.stock_quantity%TYPE);

  v_med t_med_rec;
  CURSOR c_med IS SELECT medicine_name, stock_quantity
  FROM medicines WHERE stock_quantity < p_threshold
  ORDER BY stock_quantity;
 
  v_count NUMBER := 0;

  BEGIN
    DBMS_OUTPUT.PUT_LINE('Low Stock Medicines (Threshold: ' || p_threshold || ')');
    OPEN c_med;
    LOOP
    FETCH c_med INTO v_med;
    EXIT WHEN c_med%NOTFOUND;
    v_count := v_count + 1;
    DBMS_OUTPUT.PUT_LINE( v_med.name || ' | Stock: ' || v_med.stock ||
        CASE 
          WHEN v_med.stock <= 2 THEN ' URGENT! '
          ELSE ''
        END
      );
    END LOOP;
    CLOSE c_med;

    IF v_count = 0 THEN
    DBMS_OUTPUT.PUT_LINE('All medicines are above the threshold.');
    ELSE
    DBMS_OUTPUT.PUT_LINE('Total medicines below threshold: ' || v_count);
    END IF;
  END pr_low_stock_medicines;


  PROCEDURE pr_top_diagnoses(p_limit IN NUMBER) IS
    TYPE t_diag_rec IS RECORD (
    name diagnoses.diagnosis_name%TYPE,
    count_patients NUMBER
    );

    v_diag t_diag_rec;
    CURSOR c_diag IS
    SELECT d.diagnosis_name, COUNT(DISTINCT a.patient_id) AS patient_count FROM diagnoses d
    JOIN appointments a ON d.appointment_id = a.appointment_id
    GROUP BY d.diagnosis_name
    ORDER BY patient_count DESC;

    v_rank NUMBER := 0;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Top ' || p_limit || ' Diagnoses by Patient Count');
    OPEN c_diag;
    LOOP
    FETCH c_diag INTO v_diag;
    EXIT WHEN c_diag%NOTFOUND;
    v_rank := v_rank + 1;
    EXIT WHEN v_rank > p_limit;
    DBMS_OUTPUT.PUT_LINE(
        'Diagnosis: ' || v_diag.name ||
        ' | Patients: ' || v_diag.count_patients ||
    CASE
    WHEN v_diag.count_patients > 5 THEN ' Warning! High occurrence'
    ELSE ' Rare case'
    END);
    END LOOP;
    CLOSE c_diag;
  END pr_top_diagnoses;


  PROCEDURE proc_treatment_trends(p_days IN NUMBER) IS
    TYPE t_treat_rec IS RECORD (
      treatment_name treatments.treatment_type%TYPE,
      total_assignments NUMBER,
      patient_count NUMBER
    );

    v_trend t_treat_rec;
    CURSOR c_trends IS
    SELECT t.treatment_type,
    COUNT(*) AS total_assignments,
    COUNT(DISTINCT a.patient_id) AS patient_count
    FROM treatments t
    JOIN appointments a ON t.appointment_id = a.appointment_id
    WHERE a.appointment_date >= TRUNC(SYSDATE) - p_days
    GROUP BY t.treatment_type
    ORDER BY total_assignments DESC;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Treatment Trends (Last ' || p_days || ' days)');
    OPEN c_trends;
    LOOP
    FETCH c_trends INTO v_trend;
    EXIT WHEN c_trends%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(
        'Treatment: ' || v_trend.treatment_name ||
        ' | Total Assignments: ' || v_trend.total_assignments ||
        ' | Unique Patients: ' || v_trend.patient_count ||
        CASE
          WHEN v_trend.total_assignments > 10 THEN ' Popular treatment'
          ELSE ''
        END);
    END LOOP;
    CLOSE c_trends;
  END proc_treatment_trends;




PROCEDURE proc_prescription_summary(p_medicine_id IN MEDICINES.medicine_id%TYPE) IS
    TYPE t_presc_rec IS RECORD (
      med_name MEDICINES.medicine_name%TYPE,
      total NUMBER,
      avg_days NUMBER);
    v_presc t_presc_rec;
  BEGIN
    SELECT m.medicine_name,
    COUNT(*) AS total,
    NVL(AVG(TO_NUMBER(REPLACE(p.duration, ' days', ''))), 0) AS avg_days
    INTO v_presc
    FROM medicines m
    JOIN prescriptions p ON m.medicine_id = p.medicine_id
    WHERE m.medicine_id = p_medicine_id
    GROUP BY m.medicine_name;

    DBMS_OUTPUT.PUT_LINE('Prescription Summary for Medicine: ' || v_presc.med_name );
    DBMS_OUTPUT.PUT_LINE('Total Prescriptions: ' || v_presc.total);
    DBMS_OUTPUT.PUT_LINE('Average Treatment Duration: ' || ROUND(v_presc.avg_days, 0) || ' days');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      DBMS_OUTPUT.PUT_LINE('Medicine not found.');
  END proc_prescription_summary;

  PROCEDURE proc_frequent_treatments(p_limit IN NUMBER) IS
    TYPE t_freq_treat_rec IS RECORD (
      treatment_name treatments.treatment_type%TYPE,
      total_assignments NUMBER,
      patient_count NUMBER
    );

    v_treat t_freq_treat_rec;
    CURSOR c_treat IS
      SELECT t.treatment_type,
             COUNT(*) AS total_assignments,
             COUNT(DISTINCT a.patient_id) AS patient_count
      FROM treatments t
      JOIN appointments a ON t.appointment_id = a.appointment_id
      GROUP BY t.treatment_type
      ORDER BY total_assignments DESC;

    v_rank NUMBER := 0;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Top ' || p_limit || ' Most Frequent Treatments');

    OPEN c_treat;
    LOOP
      FETCH c_treat INTO v_treat;
      EXIT WHEN c_treat%NOTFOUND;

      v_rank := v_rank + 1;
      EXIT WHEN v_rank > p_limit;

      DBMS_OUTPUT.PUT_LINE(
        'Treatment: ' || v_treat.treatment_name ||
        ' | Total Assignments: ' || v_treat.total_assignments ||
        ' | Unique Patients: ' || v_treat.patient_count ||
        CASE
          WHEN v_treat.total_assignments > 10 THEN ' Popular treatment'
          ELSE ''
        END
      );
    END LOOP;
    CLOSE c_treat;
  END proc_frequent_treatments;

END pkg_treatment_analytics;
/



BEGIN
    pkg_treatment_analytics.pr_low_stock_medicines(2);  
END;
/



BEGIN
    pkg_treatment_analytics.pr_top_diagnoses(100);  
END;
/



BEGIN
    pkg_treatment_analytics.proc_treatment_trends(30);
END;
/



BEGIN
    pkg_treatment_analytics.proc_prescription_summary(10);  
END;
/



BEGIN
    pkg_treatment_analytics.proc_frequent_treatments(10);  
END;
/

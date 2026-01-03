CREATE OR REPLACE PACKAGE pkg_patient_risk AS
    FUNCTION f_age_risk(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN NUMBER;
    FUNCTION f_bmi_risk(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN NUMBER;
    FUNCTION f_diag_risk(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN NUMBER;
    FUNCTION f_treat_risk(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN NUMBER;
    FUNCTION f_patient_risk_score(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN NUMBER;
    FUNCTION f_pr_sum(p_patient_id IN PATIENTS.patient_id%TYPE) RETURN VARCHAR2;
END pkg_patient_risk;
/
CREATE OR REPLACE PACKAGE BODY pkg_patient_risk AS    
    FUNCTION f_age_risk(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN NUMBER IS
        v_birth DATE;
        v_age NUMBER;
    BEGIN
        SELECT birth_date INTO v_birth FROM PATIENTS WHERE patient_id = p_patient_id;
        v_age := TRUNC(MONTHS_BETWEEN(SYSDATE, v_birth) / 12);

        IF v_age > 60 THEN RETURN 10;
        ELSIF v_age >= 40 THEN RETURN 10;
        ELSE RETURN 0;
        END IF;
    END f_age_risk;


    FUNCTION f_bmi_risk(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN NUMBER IS
        v_h NUMBER;
        v_w NUMBER;
        v_bmi NUMBER;
    BEGIN
        SELECT height, weight INTO v_h, v_w
        FROM PATIENTS WHERE patient_id = p_patient_id;

        v_bmi := ROUND(v_w / (v_h * v_h), 2);

        IF v_bmi >= 30 THEN RETURN 30;
        ELSIF v_bmi >= 25 THEN RETURN 10;
        ELSE RETURN 0;
        END IF;
    END f_bmi_risk;


    FUNCTION f_diag_risk(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN NUMBER IS
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM DIAGNOSES
        WHERE appointment_id IN (
            SELECT appointment_id FROM APPOINTMENTS
            WHERE patient_id = p_patient_id);

        IF v_cnt >= 5 THEN RETURN 30;
        ELSIF v_cnt >= 2 THEN RETURN 15;
        ELSE RETURN 0;
        END IF;
    END f_diag_risk;


    FUNCTION f_treat_risk(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN NUMBER IS
        v_cnt NUMBER;
    BEGIN
        SELECT COUNT(*) INTO v_cnt FROM TREATMENTS
        WHERE appointment_id IN (
            SELECT appointment_id FROM APPOINTMENTS
            WHERE patient_id = p_patient_id);

        IF v_cnt > 10 THEN RETURN 30;
        ELSIF v_cnt > 5 THEN RETURN 5;
        ELSE RETURN 0;
        END IF;
    END f_treat_risk;


    FUNCTION f_patient_risk_score(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN NUMBER IS
        s_age   NUMBER;
        s_bmi   NUMBER;
        s_diag  NUMBER;
        s_treat NUMBER;
        total   NUMBER;
    BEGIN
        s_age   := f_age_risk(p_patient_id);
        s_bmi   := f_bmi_risk(p_patient_id);
        s_diag  := f_diag_risk(p_patient_id);
        s_treat := f_treat_risk(p_patient_id);

        total := s_age + s_bmi + s_diag + s_treat;

        RETURN total;
    END f_patient_risk_score;


    FUNCTION f_pr_sum(p_patient_id IN PATIENTS.patient_id%TYPE)
    RETURN VARCHAR2 IS
        s_age   NUMBER;
        s_bmi   NUMBER;
        s_diag  NUMBER;
        s_treat NUMBER;
        total   NUMBER;
        status  VARCHAR2(20);

        v_fname PATIENTS.first_name%TYPE;
        v_lname PATIENTS.last_name%TYPE;
        v_birth DATE;
        v_years NUMBER;
    BEGIN
        SELECT first_name, last_name, birth_date
        INTO v_fname, v_lname, v_birth
        FROM PATIENTS
        WHERE patient_id = p_patient_id;

        v_years := TRUNC(MONTHS_BETWEEN(SYSDATE, v_birth) / 12);

        s_age   := f_age_risk(p_patient_id);
        s_bmi   := f_bmi_risk(p_patient_id);
        s_diag  := f_diag_risk(p_patient_id);
        s_treat := f_treat_risk(p_patient_id);

        total := s_age + s_bmi + s_diag + s_treat;

        IF total <= 30 THEN
            status := 'Normal';
        ELSIF total <= 60 THEN
            status := 'Medium Risk';
        ELSE
            status := 'High Risk';
        END IF;

        RETURN
            'Patient Health Risk Summary' || CHR(10) ||
            'Name          : ' || v_fname || ' ' || v_lname || CHR(10) ||
            'Age           : ' || v_years || CHR(10) ||
            'Age risk      : ' || s_age || CHR(10) ||
            'BMI risk      : ' || s_bmi || CHR(10) ||
            'Diagnosis risk: ' || s_diag || CHR(10) ||
            'Treatment risk: ' || s_treat || CHR(10) ||
            '----------------------------------' || CHR(10) ||
            'TOTAL SCORE   : ' || total || CHR(10) ||
            'STATUS        : ' || status;
    END f_pr_sum;
END pkg_patient_risk;
/
BEGIN
    DBMS_OUTPUT.PUT_LINE(pkg_patient_risk.f_pr_sum(1));
END;
/
CREATE OR REPLACE PACKAGE BODY price_update_pkg IS
FUNCTION increase_prices(p_percent NUMBER) RETURN VARCHAR2 IS v_output VARCHAR2(32767) := '';
BEGIN
    IF p_percent = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Percent cannot be zero.');
    END IF;
    IF p_percent < 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Percent cannot be negative.');
    END IF;

    IF meds.COUNT = 0 THEN
    SELECT medicine_name
    BULK COLLECT INTO meds
    FROM MEDICINES;
    END IF;

    SELECT price
    BULK COLLECT INTO old_prices FROM MEDICINES
    WHERE medicine_name IN (SELECT COLUMN_VALUE FROM TABLE(meds));

    FORALL i IN 1 .. meds.COUNT
    UPDATE MEDICINES
    SET price = price * (1 + p_percent / 100)
    WHERE medicine_name = meds(i);

    SELECT price
    BULK COLLECT INTO new_prices
    FROM MEDICINES
    WHERE medicine_name IN (SELECT COLUMN_VALUE FROM TABLE(meds));

    v_output := 'Prices updated:' || CHR(10);

    FOR i IN 1 .. meds.COUNT LOOP
       v_output := v_output ||
       meds(i) || ': old = ' || old_prices(i) ||
       ', new = ' || new_prices(i) || CHR(10);
    END LOOP;

    RETURN v_output;
    END increase_prices;
END price_update_pkg;
/

DECLARE
    v_msg VARCHAR2(32767);
BEGIN
    v_msg := price_update_pkg.increase_prices(10);
    DBMS_OUTPUT.PUT_LINE(v_msg);
END;
/
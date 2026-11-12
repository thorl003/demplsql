-- ============================================================================
-- 03_Triggers.sql -- REQUIRES 00_PLSQL_Setup.sql
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
PROMPT === PROBLEM 18: BEFORE INSERT OR UPDATE VALIDATION TRIGGER ===
CREATE OR REPLACE TRIGGER plx_tr_salary_guard
BEFORE INSERT OR UPDATE OF salary ON plx_emp
FOR EACH ROW
BEGIN
  IF :NEW.salary < 10000 THEN
    RAISE_APPLICATION_ERROR(-20101, 'Salary must be at least 10000');
  END IF;
END;
/
-- Validate error safely (exception caught, so the full script continues).
BEGIN
  INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary)
  VALUES (999, 'Bad Salary', 10, 1000);
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Expected validation error: ' || SQLERRM);
END;
/
SELECT COUNT(*) AS rejected_bad_salary FROM plx_emp WHERE emp_id = 999;

PROMPT === PROBLEM 19: AFTER INSERT ROW TRIGGER ===
CREATE OR REPLACE TRIGGER plx_tr_insert_audit
AFTER INSERT ON plx_emp
FOR EACH ROW
BEGIN
  INSERT INTO plx_audit(audit_id, emp_id, action_type, old_salary,
                        new_salary, logged_at)
  VALUES (plx_audit_seq.NEXTVAL, :NEW.emp_id, 'INSERT', NULL,
          :NEW.salary, SYSTIMESTAMP);
END;
/
INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary)
VALUES (105, 'Esha', 20, 48000);
COMMIT;
SELECT * FROM plx_audit WHERE emp_id = 105;

PROMPT === PROBLEM 20: AFTER UPDATE ROW TRIGGER ===
CREATE OR REPLACE TRIGGER plx_tr_update_audit
AFTER UPDATE OF salary ON plx_emp
FOR EACH ROW
BEGIN
  INSERT INTO plx_audit(audit_id, emp_id, action_type, old_salary,
                        new_salary, logged_at)
  VALUES (plx_audit_seq.NEXTVAL, :NEW.emp_id, 'UPDATE', :OLD.salary,
          :NEW.salary, SYSTIMESTAMP);
END;
/
UPDATE plx_emp SET salary = salary + 500 WHERE emp_id = 101;
COMMIT;
SELECT * FROM plx_audit WHERE emp_id = 101 ORDER BY audit_id;

PROMPT === PROBLEM 21: AFTER DELETE ROW TRIGGER ===
CREATE OR REPLACE TRIGGER plx_tr_delete_audit
AFTER DELETE ON plx_emp
FOR EACH ROW
BEGIN
  INSERT INTO plx_audit(audit_id, emp_id, action_type, old_salary,
                        new_salary, logged_at)
  VALUES (plx_audit_seq.NEXTVAL, :OLD.emp_id, 'DELETE', :OLD.salary,
          NULL, SYSTIMESTAMP);
END;
/
DELETE FROM plx_emp WHERE emp_id = 104;
COMMIT;
SELECT * FROM plx_audit WHERE emp_id = 104 ORDER BY audit_id;

PROMPT === PROBLEM 22: BEFORE UPDATE STATEMENT LEVEL TRIGGER ===
CREATE OR REPLACE TRIGGER plx_tr_update_statement
BEFORE UPDATE OF salary ON plx_emp
BEGIN
  INSERT INTO plx_events(event_id, event_label, event_at)
  VALUES (plx_event_seq.NEXTVAL, 'Salary UPDATE statement started', SYSTIMESTAMP);
END;
/
UPDATE plx_emp SET salary = salary + 50 WHERE dept_id = 10;
COMMIT;
SELECT * FROM plx_events ORDER BY event_id;

PROMPT === PROBLEM 23: TRIGGER WITH WHEN CONDITION ===
CREATE OR REPLACE TRIGGER plx_tr_salary_increase
AFTER UPDATE OF salary ON plx_emp
FOR EACH ROW
WHEN (NEW.salary > OLD.salary)
BEGIN
  DBMS_OUTPUT.PUT_LINE('Salary increased for employee ' || :NEW.emp_id);
END;
/
UPDATE plx_emp SET salary = salary + 150 WHERE emp_id = 103;
COMMIT;

PROMPT === PROBLEM 24: BEFORE UPDATE ROW TRIGGER ASSIGNS :NEW ===
CREATE OR REPLACE TRIGGER plx_tr_set_updated_at
BEFORE UPDATE ON plx_emp
FOR EACH ROW
BEGIN
  :NEW.updated_at := SYSDATE;
END;
/
UPDATE plx_emp SET status = 'ON_LEAVE' WHERE emp_id = 102;
COMMIT;
SELECT emp_id, status, updated_at FROM plx_emp WHERE emp_id = 102;

PROMPT === PROBLEM 25: MULTI-EVENT TRIGGER WITH INSERTING / UPDATING / DELETING ===
CREATE OR REPLACE TRIGGER plx_tr_event_banner
AFTER INSERT OR UPDATE OR DELETE ON plx_emp
BEGIN
  IF INSERTING THEN
    DBMS_OUTPUT.PUT_LINE('INSERT statement on PLX_EMP');
  ELSIF UPDATING THEN
    DBMS_OUTPUT.PUT_LINE('UPDATE statement on PLX_EMP');
  ELSIF DELETING THEN
    DBMS_OUTPUT.PUT_LINE('DELETE statement on PLX_EMP');
  END IF;
END;
/
UPDATE plx_emp SET status = 'ACTIVE' WHERE emp_id = 102;
COMMIT;

PROMPT === PROBLEM 26: COMPOUND TRIGGER (ADVANCED, COUNTS ROWS) ===
CREATE OR REPLACE TRIGGER plx_tr_compound_count
FOR UPDATE OF salary ON plx_emp
COMPOUND TRIGGER
  g_rows NUMBER := 0;
  AFTER EACH ROW IS
  BEGIN
    g_rows := g_rows + 1;
  END AFTER EACH ROW;
  AFTER STATEMENT IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Compound trigger updated rows = ' || g_rows);
  END AFTER STATEMENT;
END plx_tr_compound_count;
/
UPDATE plx_emp SET salary = salary + 1 WHERE dept_id = 10;
COMMIT;

PROMPT === PROBLEM 27: VIEW TRIGGER AND OBJECT INFORMATION ===
SELECT trigger_name, trigger_type, triggering_event, status
FROM user_triggers
WHERE trigger_name LIKE 'PLX_%'
ORDER BY trigger_name;
SELECT object_name, object_type, status
FROM user_objects
WHERE object_name LIKE 'PLX_%'
ORDER BY object_type, object_name;
SELECT audit_id, emp_id, action_type, old_salary, new_salary
FROM plx_audit ORDER BY audit_id;

PROMPT === PROBLEM 28: ENABLE, DISABLE, COMPILE TRIGGER ===
ALTER TRIGGER plx_tr_salary_guard DISABLE;
ALTER TRIGGER plx_tr_salary_guard ENABLE;
ALTER TRIGGER plx_tr_salary_guard COMPILE;
PROMPT The salary guard is ENABLED again.

PROMPT === PROBLEM 29: SAVEPOINT AND ROLLBACK OF AUDIT ROW ===
SAVEPOINT before_demo_update;
UPDATE plx_emp SET salary = salary + 333 WHERE emp_id = 101;
SELECT emp_id, salary FROM plx_emp WHERE emp_id = 101;
ROLLBACK TO before_demo_update;
SELECT emp_id, salary FROM plx_emp WHERE emp_id = 101;
PROMPT The UPDATE and its DML trigger's audit row were rolled back.

PROMPT === FINAL DATA AFTER RUNNING ALL PROBLEMS ===
SELECT emp_id, emp_name, dept_id, salary, status
FROM plx_emp ORDER BY emp_id;
SELECT audit_id, emp_id, action_type, old_salary, new_salary
FROM plx_audit ORDER BY audit_id;

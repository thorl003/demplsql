-- ============================================================================
-- 01_Procedures.sql -- REQUIRES 00_PLSQL_Setup.sql
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
PROMPT === PROBLEM 01: HELLO / ANONYMOUS BLOCK ===
BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello from PL/SQL');
END;
/

PROMPT === PROBLEM 02: SIMPLE PROCEDURE ===
CREATE OR REPLACE PROCEDURE plx_pr_greet(p_name IN VARCHAR2)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Welcome ' || p_name);
END;
/
EXEC plx_pr_greet('Arun')

PROMPT === PROBLEM 03: PROCEDURE WITH SELECT INTO ===
CREATE OR REPLACE PROCEDURE plx_pr_show_employee(p_id IN NUMBER)
AS
  v_name plx_emp.emp_name%TYPE;
  v_salary plx_emp.salary%TYPE;
BEGIN
  SELECT emp_name, salary INTO v_name, v_salary
  FROM plx_emp WHERE emp_id = p_id;
  DBMS_OUTPUT.PUT_LINE('Employee: ' || v_name || ', Salary: ' || v_salary);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No employee for ID ' || p_id);
END;
/
EXEC plx_pr_show_employee(101)
EXEC plx_pr_show_employee(999)

PROMPT === PROBLEM 04: PROCEDURE THAT UPDATES SALARY ===
CREATE OR REPLACE PROCEDURE plx_pr_raise_salary(
  p_id IN NUMBER, p_raise IN NUMBER
)
AS
BEGIN
  IF p_raise <= 0 OR p_raise IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'Raise must be positive');
  END IF;
  UPDATE plx_emp SET salary = salary + p_raise WHERE emp_id = p_id;
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Employee not found');
  END IF;
  DBMS_OUTPUT.PUT_LINE('Updated salary for ID ' || p_id);
END;
/
EXEC plx_pr_raise_salary(101, 1000)
SELECT emp_id, salary FROM plx_emp WHERE emp_id = 101;
COMMIT;

PROMPT === PROBLEM 05: PROCEDURE WITH OUT PARAMETER ===
CREATE OR REPLACE PROCEDURE plx_pr_dept_count(
  p_dept_id IN NUMBER, p_count OUT NUMBER
)
AS
BEGIN
  SELECT COUNT(*) INTO p_count FROM plx_emp WHERE dept_id = p_dept_id;
END;
/
VARIABLE v_count NUMBER
EXEC plx_pr_dept_count(10, :v_count)
PRINT v_count

PROMPT === PROBLEM 06: PROCEDURE WITH IN OUT PARAMETER ===
CREATE OR REPLACE PROCEDURE plx_pr_add_to_amount(
  p_amount IN OUT NUMBER, p_extra IN NUMBER
)
AS
BEGIN
  p_amount := NVL(p_amount, 0) + p_extra;
END;
/
VARIABLE v_amount NUMBER
EXEC :v_amount := 100
EXEC plx_pr_add_to_amount(:v_amount, 25)
PRINT v_amount

PROMPT === PROBLEM 07: DEFAULT PARAMETER ===
CREATE OR REPLACE PROCEDURE plx_pr_greet_dept(
  p_name IN VARCHAR2, p_dept IN VARCHAR2 DEFAULT 'IT'
)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE(p_name || ' belongs to ' || p_dept);
END;
/
EXEC plx_pr_greet_dept('Bina')
EXEC plx_pr_greet_dept('Chitra', 'CSE')

PROMPT === PROBLEM 08: PROCEDURE WITH EXCEPTION HANDLING ===
CREATE OR REPLACE PROCEDURE plx_pr_safe_divide(
  p_num IN NUMBER, p_den IN NUMBER
)
AS
  v_answer NUMBER;
BEGIN
  v_answer := p_num / p_den;
  DBMS_OUTPUT.PUT_LINE('Result = ' || v_answer);
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('Cannot divide by zero');
END;
/
EXEC plx_pr_safe_divide(10, 2)
EXEC plx_pr_safe_divide(10, 0)

PROMPT === PROBLEM 09: PROCEDURE USING EXPLICIT CURSOR ===
CREATE OR REPLACE PROCEDURE plx_pr_list_employees
AS
  CURSOR c_emp IS
    SELECT emp_id, emp_name, salary FROM plx_emp ORDER BY emp_id;
BEGIN
  FOR r IN c_emp LOOP
    DBMS_OUTPUT.PUT_LINE(r.emp_id || ' ' || r.emp_name || ' ' || r.salary);
  END LOOP;
END;
/
EXEC plx_pr_list_employees

PROMPT === PROBLEM 10: PROCEDURE CALLING PROCEDURE ===
CREATE OR REPLACE PROCEDURE plx_pr_employee_report(p_id IN NUMBER)
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('--- Employee report ---');
  plx_pr_show_employee(p_id);
END;
/
EXEC plx_pr_employee_report(102)

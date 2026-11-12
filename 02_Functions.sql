-- ============================================================================
-- 02_Functions.sql -- REQUIRES 00_PLSQL_Setup.sql
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
PROMPT === PROBLEM 11: SQUARE FUNCTION ===
CREATE OR REPLACE FUNCTION plx_fn_square(p_num IN NUMBER)
RETURN NUMBER
AS
BEGIN
  RETURN p_num * p_num;
END;
/
SELECT plx_fn_square(6) AS result FROM dual;

PROMPT === PROBLEM 12: GRADE FUNCTION ===
CREATE OR REPLACE FUNCTION plx_fn_grade(p_mark IN NUMBER)
RETURN VARCHAR2
AS
BEGIN
  IF p_mark IS NULL OR p_mark < 0 OR p_mark > 100 THEN
    RETURN 'INVALID';
  ELSIF p_mark >= 90 THEN
    RETURN 'A';
  ELSIF p_mark >= 75 THEN
    RETURN 'B';
  ELSIF p_mark >= 50 THEN
    RETURN 'C';
  ELSE
    RETURN 'FAIL';
  END IF;
END;
/
SELECT plx_fn_grade(92) AS grade_92,
       plx_fn_grade(48) AS grade_48 FROM dual;

PROMPT === PROBLEM 13: ANNUAL SALARY USING SELECT INTO ===
CREATE OR REPLACE FUNCTION plx_fn_annual_salary(p_id IN NUMBER)
RETURN NUMBER
AS
  v_monthly plx_emp.salary%TYPE;
BEGIN
  SELECT salary INTO v_monthly FROM plx_emp WHERE emp_id = p_id;
  RETURN v_monthly * 12;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20013, 'Employee ID does not exist');
END;
/
SELECT emp_name, plx_fn_annual_salary(emp_id) AS annual_salary
FROM plx_emp ORDER BY emp_id;

PROMPT === PROBLEM 14: DEPARTMENT EMPLOYEE COUNT FUNCTION ===
CREATE OR REPLACE FUNCTION plx_fn_dept_count(p_dept_id IN NUMBER)
RETURN NUMBER
AS
  v_total NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_total FROM plx_emp WHERE dept_id = p_dept_id;
  RETURN v_total;
END;
/
SELECT dept_name, plx_fn_dept_count(dept_id) AS employee_count
FROM plx_dept ORDER BY dept_id;

PROMPT === PROBLEM 15: FACTORIAL USING LOOP ===
CREATE OR REPLACE FUNCTION plx_fn_factorial(p_n IN NUMBER)
RETURN NUMBER
AS
  v_result NUMBER := 1;
BEGIN
  IF p_n IS NULL OR p_n < 0 OR p_n > 20 OR p_n != TRUNC(p_n) THEN
    RAISE_APPLICATION_ERROR(-20015, 'Use an integer between 0 and 20');
  END IF;
  FOR i IN 1..p_n LOOP
    v_result := v_result * i;
  END LOOP;
  RETURN v_result;
END;
/
SELECT plx_fn_factorial(5) AS factorial_5 FROM dual;

PROMPT === PROBLEM 16: FUNCTION USED INSIDE PL/SQL ===
DECLARE
  v_total NUMBER;
BEGIN
  v_total := plx_fn_annual_salary(102);
  DBMS_OUTPUT.PUT_LINE('Annual salary for 102 = ' || v_total);
END;
/

PROMPT === PROBLEM 17: SIMPLE BONUS FUNCTION ===
CREATE OR REPLACE FUNCTION plx_fn_bonus(p_salary IN NUMBER, p_rate IN NUMBER)
RETURN NUMBER
AS
BEGIN
  IF p_rate < 0 OR p_rate > 100 OR p_rate IS NULL THEN
    RAISE_APPLICATION_ERROR(-20017, 'Rate must be in range 0 to 100');
  END IF;
  RETURN ROUND(p_salary * p_rate / 100, 2);
END;
/
SELECT emp_name, salary, plx_fn_bonus(salary, 10) AS bonus_10_percent
FROM plx_emp ORDER BY emp_id;

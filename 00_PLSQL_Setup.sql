-- ============================================================================
-- 00_PLSQL_Setup.sql -- RUN ONCE IN A FRESH COLLEGE (OR OTHER LAB) SCHEMA
-- This file CREATES PLX_* tables and sample rows; existing names cause errors.
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED
SET LINESIZE 160
SET PAGESIZE 100
SET VERIFY OFF

PROMPT === 00: CREATE TABLES ===
CREATE TABLE plx_dept (
  dept_id NUMBER PRIMARY KEY,
  dept_name VARCHAR2(40) NOT NULL UNIQUE
);

CREATE TABLE plx_emp (
  emp_id NUMBER PRIMARY KEY,
  emp_name VARCHAR2(50) NOT NULL,
  dept_id NUMBER REFERENCES plx_dept(dept_id),
  salary NUMBER(10,2) NOT NULL,
  hire_date DATE DEFAULT SYSDATE NOT NULL,
  status VARCHAR2(12) DEFAULT 'ACTIVE' NOT NULL,
  updated_at DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT plx_emp_salary_ck CHECK (salary >= 0)
);

CREATE TABLE plx_audit (
  audit_id NUMBER PRIMARY KEY,
  emp_id NUMBER,
  action_type VARCHAR2(30),
  old_salary NUMBER(10,2),
  new_salary NUMBER(10,2),
  logged_at TIMESTAMP
);

CREATE SEQUENCE plx_audit_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE plx_events (
  event_id NUMBER PRIMARY KEY,
  event_label VARCHAR2(120),
  event_at TIMESTAMP DEFAULT SYSTIMESTAMP
);

CREATE SEQUENCE plx_event_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE plx_bonus (
  bonus_id NUMBER PRIMARY KEY,
  emp_id NUMBER REFERENCES plx_emp(emp_id),
  bonus_amount NUMBER(10,2),
  created_at DATE DEFAULT SYSDATE
);

CREATE SEQUENCE plx_bonus_seq START WITH 1 INCREMENT BY 1;

PROMPT === 00: INSERT SAMPLE VALUES ===
INSERT INTO plx_dept VALUES (10, 'IT');
INSERT INTO plx_dept VALUES (20, 'CSE');
INSERT INTO plx_dept VALUES (30, 'ECE');

INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary, hire_date)
VALUES (101, 'Arun', 10, 50000, DATE '2024-06-10');
INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary, hire_date)
VALUES (102, 'Bina', 10, 62000, DATE '2023-08-12');
INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary, hire_date)
VALUES (103, 'Chitra', 20, 74000, DATE '2022-01-15');
INSERT INTO plx_emp(emp_id, emp_name, dept_id, salary, hire_date)
VALUES (104, 'Dev', 30, 39000, DATE '2025-02-01');
COMMIT;
SELECT emp_id, emp_name, dept_id, salary FROM plx_emp ORDER BY emp_id;

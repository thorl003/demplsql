================================================================================
HOW TO RUN - ORACLE SQL*PLUS TRIGGERS, PROCEDURES, FUNCTIONS EXAM PACK
================================================================================

CONTENTS
  PLSQL_Help.txt           = Exam setup, login, execution, debugging
  PLSQL_Scenario.txt       = 30 numbered solved problems (00 to 29)
  PLSQL_Syntax.txt         = 31 numbered syntax templates (01 to 31)
  00_PLSQL_Setup.sql       = Create PLX_* tables, sequences, insert values
  01_Procedures.sql        = Problems 01-10
  02_Functions.sql         = Problems 11-17
  03_Triggers.sql          = Problems 18-29
  Scenario_RunAll.sql      = Runs all four .sql programs in sequence

REQUIREMENTS
  Oracle DB + SQL*Plus installed. Your existing COLLEGE schema (or another
  fresh practice schema) has CREATE SESSION, TABLE, PROCEDURE, TRIGGER, SEQUENCE
  and table space quota. No separate data file required.

SETUP (WINDOWS)
  1. Extract all files into C:\sql_lab (not only the ZIP file).
  2. Open Windows CMD and type: sqlplus /nolog
  3. At SQL> type: CONNECT college@localhost:1521/XEPDB1
     Enter password when asked. Oracle Database Free may use FREEPDB1.
  4. At SQL> type: SET SERVEROUTPUT ON
  5. At SQL> type: @C:\sql_lab\Scenario_RunAll.sql

NOTE: The setup creates new PLX_* objects, so execute once in a fresh lab
schema. Running it again in the same schema will produce object/PK conflicts.
For exam practice, copy individual problem code blocks from PLSQL_Scenario.txt.

A TRIGGER IS NEVER CALLED USING EXEC. INSERT/UPDATE/DELETE FIRES IT.
Every CREATE PROCEDURE / FUNCTION / TRIGGER ends with END; followed by /.
Normal DML trigger log entries roll back with the triggering DML.

Official Oracle documentation:
  https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/plsql-triggers.html
  https://docs.oracle.com/en/database/oracle/oracle-database/21/lnpls/CREATE-TRIGGER-statement.html

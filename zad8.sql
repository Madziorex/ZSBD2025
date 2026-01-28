----1
CREATE TABLE archiwum_departamentow (
    id NUMBER,
    nazwa VARCHAR2(100),
    data_zamkniecia DATE,
    ostatni_manager VARCHAR2(100)
);

CREATE OR REPLACE TRIGGER trg_arch_departments
AFTER DELETE ON departments
FOR EACH ROW
DECLARE
    v_manager VARCHAR2(100);
BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_manager
    FROM employees
    WHERE employee_id = :OLD.manager_id;

    INSERT INTO archiwum_departamentow
    VALUES (
        :OLD.department_id,
        :OLD.department_name,
        SYSDATE,
        v_manager
    );
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO archiwum_departamentow
        VALUES (
            :OLD.department_id,
            :OLD.department_name,
            SYSDATE,
            NULL
        );
END;

----2
CREATE TABLE zlodziej (
    id NUMBER,
    usr VARCHAR2(50),
    czas_zmiany DATE
);

CREATE OR REPLACE TRIGGER trg_salary_range
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF :NEW.salary < 2000 OR :NEW.salary > 26000 THEN

        INSERT INTO zlodziej
        VALUES (
            :NEW.employee_id,
            USER,
            SYSDATE
        );

        COMMIT;

        RAISE_APPLICATION_ERROR(-20010, 'Salary out of range');
    END IF;
END;

----3
CREATE SEQUENCE employees_seq
START WITH 10000
INCREMENT BY 1;

CREATE OR REPLACE TRIGGER trg_employees_ai
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    IF :NEW.employee_id IS NULL THEN
        :NEW.employee_id := employees_seq.NEXTVAL;
    END IF;
END;

----4
CREATE OR REPLACE TRIGGER trg_block_job_grades
BEFORE INSERT OR UPDATE OR DELETE ON job_grades
BEGIN
    RAISE_APPLICATION_ERROR(-20020, 'Operation not allowed on JOB_GRADES');
END;


----5
CREATE OR REPLACE TRIGGER trg_protect_jobs_salary
BEFORE UPDATE OF min_salary, max_salary ON jobs
FOR EACH ROW
BEGIN
    :NEW.min_salary := :OLD.min_salary;
    :NEW.max_salary := :OLD.max_salary;
END;

----6
--1
INSERT INTO departments (department_id, department_name, location_id)
VALUES (998, 'TEST_ARCH', 1700);

DELETE FROM departments WHERE department_id = 998;

SELECT * FROM archiwum_departamentow;

--2
INSERT INTO employees (
    last_name, email, hire_date, job_id, salary
)
VALUES (
    'TEST', 'TEST1', SYSDATE, 'AD_VP', 30000
);

UPDATE employees
SET salary = 1000
WHERE employee_id = 100;

SELECT * FROM zlodziej;

--3
INSERT INTO employees (
    first_name, last_name, email, hire_date, job_id, salary
)
VALUES (
    'Anna', 'Auto', 'ANNA_AUTO', SYSDATE, 'AD_VP', 5000
);

SELECT employee_id FROM employees WHERE last_name = 'Auto';

--4
INSERT INTO job_grades VALUES ('X', 1000, 2000);

UPDATE job_grades SET MIN_SALARY  = 1;

DELETE FROM job_grades;

--5
UPDATE jobs
SET min_salary = 1, max_salary = 99999
WHERE job_id = 'AD_VP';

SELECT min_salary, max_salary
FROM jobs
WHERE job_id = 'AD_VP';

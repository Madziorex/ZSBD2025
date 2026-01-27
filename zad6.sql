----1
CREATE OR REPLACE PROCEDURE add_job (
    p_job_id jobs.job_id%TYPE,
    p_job_title jobs.job_title%TYPE
) IS
BEGIN
    INSERT INTO jobs (job_id, job_title)
    VALUES (p_job_id, p_job_title);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error adding job');
END;

----2
CREATE OR REPLACE PROCEDURE update_job_title (
    p_job_id jobs.job_id%TYPE,
    p_new_title jobs.job_title%TYPE
) IS
    no_jobs_updated EXCEPTION;
BEGIN
    UPDATE jobs
    SET job_title = p_new_title
    WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE no_jobs_updated;
    END IF;

EXCEPTION
    WHEN no_jobs_updated THEN
        DBMS_OUTPUT.PUT_LINE('No job to update');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error job');
END;

----3
CREATE OR REPLACE PROCEDURE delete_job (
    p_job_id jobs.job_id%TYPE
) IS
    no_jobs_deleted EXCEPTION;
BEGIN
    DELETE FROM jobs
    WHERE job_id = p_job_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE no_jobs_deleted;
    END IF;

EXCEPTION
    WHEN no_jobs_deleted THEN
        DBMS_OUTPUT.PUT_LINE('No job to remove');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error job');
END;

----4
CREATE OR REPLACE PROCEDURE get_employee_data (
    p_emp_id   employees.employee_id%TYPE,
    p_lastname OUT employees.last_name%TYPE,
    p_salary   OUT employees.salary%TYPE
) IS
BEGIN
    SELECT last_name, salary
    INTO p_lastname, p_salary
    FROM employees
    WHERE employee_id = p_emp_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employee');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error employee');
END;

----5
CREATE OR REPLACE PROCEDURE add_employee (
    p_first_name employees.first_name%TYPE DEFAULT NULL,
    p_last_name  employees.last_name%TYPE,
    p_salary     employees.salary%TYPE,
    p_job_id     employees.job_id%TYPE,
    p_department employees.department_id%TYPE DEFAULT NULL
) IS
    salary_too_high EXCEPTION;
    v_emp_id employees.employee_id%TYPE;
BEGIN
    IF p_salary > 20000 THEN
        RAISE salary_too_high;
    END IF;

    SELECT MAX(employee_id) + 1
    INTO v_emp_id
    FROM employees;

    INSERT INTO employees (
        employee_id,
        first_name,
        last_name,
        email,
        hire_date,
        salary,
        job_id,
        department_id
    )
    VALUES (
        v_emp_id,
        p_first_name,
        p_last_name,
        p_last_name || v_emp_id || TO_CHAR(SYSDATE,'SS'),
        SYSDATE,
        p_salary,
        p_job_id,
        p_department
    );

EXCEPTION
    WHEN salary_too_high THEN
        DBMS_OUTPUT.PUT_LINE('Salary too high');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error employee');
END;

----6
CREATE OR REPLACE PROCEDURE avg_salary_by_manager (
    p_manager_id employees.manager_id%TYPE,
    p_avg_salary OUT NUMBER
) IS
BEGIN
    SELECT AVG(salary)
    INTO p_avg_salary
    FROM employees
    WHERE manager_id = p_manager_id;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No employees');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error');
END;

----7
CREATE OR REPLACE PROCEDURE raise_salary_department (
    p_department_id employees.department_id%TYPE,
    p_percent NUMBER
) IS
    dep_not_exists EXCEPTION;
    PRAGMA EXCEPTION_INIT(dep_not_exists, -2291);
BEGIN
    UPDATE employees e
    SET salary = salary + salary * p_percent / 100
    WHERE department_id = p_department_id
      AND salary + salary * p_percent / 100 BETWEEN
          (SELECT min_salary FROM jobs WHERE job_id = e.job_id)
          AND
          (SELECT max_salary FROM jobs WHERE job_id = e.job_id);

EXCEPTION
    WHEN dep_not_exists THEN
        DBMS_OUTPUT.PUT_LINE('Department does not exist');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error salary update');
END;

----8
CREATE OR REPLACE PROCEDURE move_employee (
    p_employee_id employees.employee_id%TYPE,
    p_new_department_id departments.department_id%TYPE
) IS
    no_employee EXCEPTION;
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM departments
    WHERE department_id = p_new_department_id;

    IF v_count = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Department does not exist');
        RETURN;
    END IF;

    UPDATE employees
    SET department_id = p_new_department_id
    WHERE employee_id = p_employee_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE no_employee;
    END IF;

EXCEPTION
    WHEN no_employee THEN
        DBMS_OUTPUT.PUT_LINE('Employee does not exist');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error moving employee');
END;

----9
CREATE OR REPLACE PROCEDURE delete_department (
    p_department_id departments.department_id%TYPE
) IS
BEGIN
    DELETE FROM departments
    WHERE department_id = p_department_id;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Cannot delete department');
END;

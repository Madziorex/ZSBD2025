----1
CREATE OR REPLACE FUNCTION get_job_name (
    p_job_id jobs.job_id%TYPE
) RETURN jobs.job_title%TYPE IS
    v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT job_title
    INTO v_job_title
    FROM jobs
    WHERE job_id = p_job_id;

    RETURN v_job_title;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'No job');
END;

----2
CREATE OR REPLACE FUNCTION yearly_salary (
    p_employee_id employees.employee_id%TYPE
) RETURN NUMBER IS
    v_salary employees.salary%TYPE;
    v_comm   employees.commission_pct%TYPE;
BEGIN
    SELECT salary, commission_pct
    INTO v_salary, v_comm
    FROM employees
    WHERE employee_id = p_employee_id;

    RETURN v_salary * 12 + v_salary * NVL(v_comm, 0);

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'No employee');
END;

----3
CREATE OR REPLACE FUNCTION phone_area (
    p_phone VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN '(' || SUBSTR(p_phone, 1, 3) || ')';
END;

----4
CREATE OR REPLACE FUNCTION change_letters (
    p_text VARCHAR2
) RETURN VARCHAR2 IS
    v_len NUMBER;
BEGIN
    v_len := LENGTH(p_text);

    IF v_len = 1 THEN
        RETURN UPPER(p_text);
    END IF;

    RETURN UPPER(SUBSTR(p_text, 1, 1)) ||
           LOWER(SUBSTR(p_text, 2, v_len - 2)) ||
           UPPER(SUBSTR(p_text, v_len, 1));
END;

----5
CREATE OR REPLACE FUNCTION pesel_to_date (
    p_pesel VARCHAR2
) RETURN VARCHAR2 IS
    v_year   NUMBER;
    v_month  NUMBER;
    v_day    NUMBER;
BEGIN
    v_year  := TO_NUMBER(SUBSTR(p_pesel, 1, 2));
    v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
    v_day   := TO_NUMBER(SUBSTR(p_pesel, 5, 2));

    IF v_month > 20 THEN
        v_year  := 2000 + v_year;
        v_month := v_month - 20;
    ELSE
        v_year := 1900 + v_year;
    END IF;

    RETURN TO_CHAR(
        TO_DATE(v_year || '-' || v_month || '-' || v_day, 'YYYY-MM-DD'),
        'YYYY-MM-DD'
    );
END;

----6
CREATE OR REPLACE FUNCTION country_stats (
    p_country_name countries.country_name%TYPE
) RETURN VARCHAR2 IS
    v_country_id countries.country_id%TYPE;
    v_emp_count  NUMBER;
    v_dep_count  NUMBER;
BEGIN
    SELECT country_id
    INTO v_country_id
    FROM countries
    WHERE country_name = p_country_name;

    SELECT COUNT(DISTINCT d.department_id),
           COUNT(e.employee_id)
    INTO v_dep_count, v_emp_count
    FROM departments d
    LEFT JOIN employees e ON e.department_id = d.department_id
    JOIN locations l ON d.location_id = l.location_id
    WHERE l.country_id = v_country_id;

    RETURN v_emp_count || ',' || v_dep_count;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'No country');
END;

----7
CREATE OR REPLACE FUNCTION access_id (
    p_first_name VARCHAR2,
    p_last_name  VARCHAR2,
    p_phone      VARCHAR2
) RETURN VARCHAR2 IS
BEGIN
    RETURN
        UPPER(SUBSTR(p_last_name, 1, 3)) ||
        SUBSTR(p_phone, LENGTH(p_phone) - 3, 4) ||
        UPPER(SUBSTR(p_first_name, 1, 1));
END;

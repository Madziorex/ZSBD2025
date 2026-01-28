----1
CREATE OR REPLACE PACKAGE pkg_hr_tools IS

    PROCEDURE add_job (
        p_job_id jobs.job_id%TYPE,
        p_job_title jobs.job_title%TYPE
    );

    PROCEDURE update_job_title (
        p_job_id jobs.job_id%TYPE,
        p_new_title jobs.job_title%TYPE
    );

    PROCEDURE delete_job (
        p_job_id jobs.job_id%TYPE
    );

    FUNCTION get_job_name (
        p_job_id jobs.job_id%TYPE
    ) RETURN jobs.job_title%TYPE;

    FUNCTION yearly_salary (
        p_employee_id employees.employee_id%TYPE
    ) RETURN NUMBER;

END pkg_hr_tools;

CREATE OR REPLACE PACKAGE BODY pkg_hr_tools IS

    PROCEDURE add_job (
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

    PROCEDURE update_job_title (
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

    PROCEDURE delete_job (
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

    FUNCTION get_job_name (
        p_job_id jobs.job_id%TYPE
    ) RETURN jobs.job_title%TYPE IS
        v_title jobs.job_title%TYPE;
    BEGIN
        SELECT job_title
        INTO v_title
        FROM jobs
        WHERE job_id = p_job_id;

        RETURN v_title;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20101, 'No job');
    END;

    FUNCTION yearly_salary (
        p_employee_id employees.employee_id%TYPE
    ) RETURN NUMBER IS
        v_salary employees.salary%TYPE;
        v_comm employees.commission_pct%TYPE;
    BEGIN
        SELECT salary, commission_pct
        INTO v_salary, v_comm
        FROM employees
        WHERE employee_id = p_employee_id;

        RETURN v_salary * 12 + v_salary * NVL(v_comm, 0);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20102, 'No employee');
    END;

END pkg_hr_tools;

----2
CREATE OR REPLACE PACKAGE pkg_regions IS

    PROCEDURE add_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    );

    PROCEDURE update_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    );

    PROCEDURE delete_region (
        p_region_id regions.region_id%TYPE
    );

    FUNCTION get_region_name (
        p_region_id regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE;

    FUNCTION get_region_id (
        p_region_name regions.region_name%TYPE
    ) RETURN regions.region_id%TYPE;

END pkg_regions;

CREATE OR REPLACE PACKAGE BODY pkg_regions IS

    PROCEDURE add_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    ) IS
    BEGIN
        INSERT INTO regions (region_id, region_name)
        VALUES (p_region_id, p_region_name);
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error adding region');
    END;

    PROCEDURE update_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    ) IS
    BEGIN
        UPDATE regions
        SET region_name = p_region_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region to update');
        END IF;
    END;

    PROCEDURE delete_region (
        p_region_id regions.region_id%TYPE
    ) IS
    BEGIN
        DELETE FROM regions
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region to delete');
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error deleting region');
    END;

    FUNCTION get_region_name (
        p_region_id regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name
        INTO v_name
        FROM regions
        WHERE region_id = p_region_id;

        RETURN v_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

    FUNCTION get_region_id (
        p_region_name regions.region_name%TYPE
    ) RETURN regions.region_id%TYPE IS
        v_id regions.region_id%TYPE;
    BEGIN
        SELECT region_id
        INTO v_id
        FROM regions
        WHERE region_name = p_region_name;

        RETURN v_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END;

END pkg_regions;

----3
CREATE OR REPLACE PACKAGE pkg_regions IS

    e_region_exists EXCEPTION;
    e_region_has_countries EXCEPTION;

    PROCEDURE add_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    );

    PROCEDURE update_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    );

    PROCEDURE delete_region (
        p_region_id regions.region_id%TYPE
    );

    FUNCTION get_region_name (
        p_region_id regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE;

    FUNCTION get_region_id (
        p_region_name regions.region_name%TYPE
    ) RETURN regions.region_id%TYPE;

END pkg_regions;

CREATE OR REPLACE PACKAGE BODY pkg_regions IS

    PROCEDURE add_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM regions
        WHERE region_name = p_region_name;

        IF v_count > 0 THEN
            RAISE e_region_exists;
        END IF;

        INSERT INTO regions (region_id, region_name)
        VALUES (p_region_id, p_region_name);

    EXCEPTION
        WHEN e_region_exists THEN
            log_error('PKG_REGIONS.ADD_REGION', 'Region name exists');
            DBMS_OUTPUT.PUT_LINE('Region with this name already exists');

        WHEN OTHERS THEN
            log_error('PKG_REGIONS.ADD_REGION', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error adding region');
    END add_region;


    PROCEDURE update_region (
        p_region_id regions.region_id%TYPE,
        p_region_name regions.region_name%TYPE
    ) IS
    BEGIN
        UPDATE regions
        SET region_name = p_region_name
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region to update');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            log_error('PKG_REGIONS.UPDATE_REGION', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error updating region');
    END update_region;


    PROCEDURE delete_region (
        p_region_id regions.region_id%TYPE
    ) IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM countries
        WHERE region_id = p_region_id;

        IF v_count > 0 THEN
            RAISE e_region_has_countries;
        END IF;

        DELETE FROM regions
        WHERE region_id = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            DBMS_OUTPUT.PUT_LINE('No region to delete');
        END IF;

    EXCEPTION
        WHEN e_region_has_countries THEN
            log_error('PKG_REGIONS.DELETE_REGION', 'Region has countries');
            DBMS_OUTPUT.PUT_LINE('Region has assigned countries');

        WHEN OTHERS THEN
            log_error('PKG_REGIONS.DELETE_REGION', SQLERRM);
            DBMS_OUTPUT.PUT_LINE('Error deleting region');
    END delete_region;


    FUNCTION get_region_name (
        p_region_id regions.region_id%TYPE
    ) RETURN regions.region_name%TYPE IS
        v_name regions.region_name%TYPE;
    BEGIN
        SELECT region_name
        INTO v_name
        FROM regions
        WHERE region_id = p_region_id;

        RETURN v_name;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_region_name;


    FUNCTION get_region_id (
        p_region_name regions.region_name%TYPE
    ) RETURN regions.region_id%TYPE IS
        v_id regions.region_id%TYPE;
    BEGIN
        SELECT region_id
        INTO v_id
        FROM regions
        WHERE region_name = p_region_name;

        RETURN v_id;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;
    END get_region_id;

END pkg_regions;

----4
CREATE OR REPLACE PACKAGE pkg_stats IS

    FUNCTION avg_salary_department (
        p_department_id employees.department_id%TYPE
    ) RETURN NUMBER;

    PROCEDURE min_max_salary_job (
        p_job_id jobs.job_id%TYPE,
        p_min_salary OUT NUMBER,
        p_max_salary OUT NUMBER
    );

    PROCEDURE generate_report (
        p_department_id employees.department_id%TYPE
    );

END pkg_stats;

CREATE OR REPLACE PACKAGE BODY pkg_stats IS

    FUNCTION avg_salary_department (
        p_department_id employees.department_id%TYPE
    ) RETURN NUMBER IS
        v_avg NUMBER;
    BEGIN
        SELECT AVG(salary)
        INTO v_avg
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_avg;
    END avg_salary_department;


    PROCEDURE min_max_salary_job (
        p_job_id jobs.job_id%TYPE,
        p_min_salary OUT NUMBER,
        p_max_salary OUT NUMBER
    ) IS
    BEGIN
        SELECT MIN(salary), MAX(salary)
        INTO p_min_salary, p_max_salary
        FROM employees
        WHERE job_id = p_job_id;
    END min_max_salary_job;


    PROCEDURE generate_report (
        p_department_id employees.department_id%TYPE
    ) IS
        v_avg NUMBER;
        v_min NUMBER;
        v_max NUMBER;
        v_job employees.job_id%TYPE;
    BEGIN
        DBMS_OUTPUT.PUT_LINE('--- REPORT FOR DEPARTMENT ' || p_department_id || ' ---');

        v_avg := avg_salary_department(p_department_id);
        DBMS_OUTPUT.PUT_LINE('Average salary: ' || v_avg);

        FOR r IN (
            SELECT DISTINCT job_id
            FROM employees
            WHERE department_id = p_department_id
        ) LOOP
            min_max_salary_job(r.job_id, v_min, v_max);
            DBMS_OUTPUT.PUT_LINE(
                'Job ' || r.job_id ||
                ' | Min salary: ' || v_min ||
                ' | Max salary: ' || v_max
            );
        END LOOP;

        DBMS_OUTPUT.PUT_LINE('--- END OF REPORT ---');
    END generate_report;

END pkg_stats;

----5
CREATE OR REPLACE PACKAGE pkg_auto_data IS

    PROCEDURE fix_phone_numbers;

    PROCEDURE raise_salary_for_job (
        p_job_id jobs.job_id%TYPE,
        p_percent NUMBER
    );

END pkg_auto_data;

CREATE OR REPLACE PACKAGE BODY pkg_auto_data IS

    PROCEDURE fix_phone_numbers IS
    BEGIN
        UPDATE employees
        SET phone_number =
            SUBSTR(REPLACE(phone_number, '.', ''), 1, 3) || '-' ||
            SUBSTR(REPLACE(phone_number, '.', ''), 4, 3) || '-' ||
            SUBSTR(REPLACE(phone_number, '.', ''), 7, 4)
        WHERE phone_number IS NOT NULL;
    END fix_phone_numbers;


    PROCEDURE raise_salary_for_job (
        p_job_id jobs.job_id%TYPE,
        p_percent NUMBER
    ) IS
    BEGIN
        UPDATE employees
        SET salary = salary + salary * p_percent / 100
        WHERE job_id = p_job_id;
    END raise_salary_for_job;

END pkg_auto_data;

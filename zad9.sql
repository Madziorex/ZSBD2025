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

----1
DECLARE
    numer_max departments.department_id%TYPE;
    nowy_departament departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO numer_max
    FROM departments;

    DBMS_OUTPUT.PUT_LINE(numer_max);

    INSERT INTO departments (department_id, department_name)
    VALUES (numer_max + 10, nowy_departament);
END;

----2
DECLARE
    numer_max departments.department_id%TYPE;
    nowy_departament departments.department_name%TYPE := 'EDUCATION';
BEGIN
    SELECT MAX(department_id)
    INTO numer_max
    FROM departments;

    DBMS_OUTPUT.PUT_LINE(numer_max);

    INSERT INTO departments (department_id, department_name)
    VALUES (numer_max + 10, nowy_departament);
    
    UPDATE departments
    SET location_id = 3000
    WHERE department_id = numer_max + 10;
END;

----3
CREATE TABLE nowa (
    liczby VARCHAR2(10)
);

DECLARE
    i NUMBER;
BEGIN
    FOR i IN 1..10 LOOP
        IF i NOT IN (4,6) THEN
            INSERT INTO nowa (liczby) VALUES (i);
        END IF;
    END LOOP;
END;


----4
DECLARE
    kraj countries%ROWTYPE;
BEGIN
    SELECT *
    INTO kraj
    FROM countries
    WHERE country_id = 'CA';

    DBMS_OUTPUT.PUT_LINE(kraj.country_name);
    DBMS_OUTPUT.PUT_LINE(kraj.region_id);
END;

----5
DECLARE
    j jobs%ROWTYPE;
    liczba NUMBER;
BEGIN
    liczba := 0;

    FOR j IN (SELECT * FROM jobs WHERE job_title LIKE '%Manager%') LOOP
        UPDATE jobs
        SET min_salary = j.min_salary * 1.05
        WHERE job_id = j.job_id;

        liczba := liczba + 1;
    END LOOP;

    DBMS_OUTPUT.PUT_LINE(liczba);
END;

--a
ROLLBACK;

--
UPDATE jobs
SET min_salary = ROUND(min_salary / 1.05, 2)
WHERE job_title LIKE '%Manager%';
COMMIT;


----6
DECLARE
    j jobs%ROWTYPE;
BEGIN
    SELECT *
    INTO j
    FROM jobs
    WHERE max_salary = (SELECT MAX(max_salary) FROM jobs);

    DBMS_OUTPUT.PUT_LINE(j.job_id);
    DBMS_OUTPUT.PUT_LINE(j.job_title);
    DBMS_OUTPUT.PUT_LINE(j.max_salary);
END;

----7
DECLARE
    CURSOR kraje_cur (p_region_id NUMBER) IS
        SELECT country_id, country_name
        FROM countries
        WHERE region_id = p_region_id;

    v_country_id   countries.country_id%TYPE;
    v_country_name countries.country_name%TYPE;
    v_count        NUMBER;
BEGIN
    OPEN kraje_cur(1);

    LOOP
        FETCH kraje_cur INTO v_country_id, v_country_name;
        EXIT WHEN kraje_cur%NOTFOUND;

        SELECT COUNT(*) INTO v_count
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        JOIN locations l ON d.location_id = l.location_id
        WHERE l.country_id = v_country_id;

        DBMS_OUTPUT.PUT_LINE(v_country_name || ' - ' || v_count);
    END LOOP;

    CLOSE kraje_cur;
END;

----8
DECLARE
    CURSOR wynagrodzenia IS
        SELECT last_name, salary
        FROM employees
        WHERE department_id = 50;

    naz employees.last_name%TYPE;
    wyn employees.salary%TYPE;
BEGIN
    OPEN wynagrodzenia;

    FETCH wynagrodzenia INTO naz, wyn;
    WHILE wynagrodzenia%FOUND LOOP

        IF wyn > 3100 THEN
            DBMS_OUTPUT.PUT_LINE(naz || ' - nie dawać podwyżki');
        ELSE
            DBMS_OUTPUT.PUT_LINE(naz || ' - dać podwyżkę');
        END IF;

        FETCH wynagrodzenia INTO naz, wyn;
    END LOOP;

    CLOSE wynagrodzenia;
END;

----9
--a
DECLARE
    CURSOR pracownicy (p_min NUMBER, p_max NUMBER, p_imie VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min AND p_max
          AND LOWER(first_name) LIKE '%' || LOWER(p_imie) || '%';

    imie   employees.first_name%TYPE;
    nazw   employees.last_name%TYPE;
    zarob  employees.salary%TYPE;
BEGIN
    OPEN pracownicy(1000, 5000, 'a');

    FETCH pracownicy INTO imie, nazw, zarob;
    WHILE pracownicy%FOUND LOOP

        DBMS_OUTPUT.PUT_LINE(imie || ' ' || nazw || ' - ' || zarob);

        FETCH pracownicy INTO imie, nazw, zarob;
    END LOOP;

    CLOSE pracownicy;
END;

--b
DECLARE
    CURSOR pracownicy (p_min NUMBER, p_max NUMBER, p_imie VARCHAR2) IS
        SELECT first_name, last_name, salary
        FROM employees
        WHERE salary BETWEEN p_min AND p_max
          AND LOWER(first_name) LIKE '%' || LOWER(p_imie) || '%';

    imie   employees.first_name%TYPE;
    nazw   employees.last_name%TYPE;
    zarob  employees.salary%TYPE;
BEGIN
    OPEN pracownicy(5000, 20000, 'u');

    FETCH pracownicy INTO imie, nazw, zarob;
    WHILE pracownicy%FOUND LOOP

        DBMS_OUTPUT.PUT_LINE(imie || ' ' || nazw || ' - ' || zarob);

        FETCH pracownicy INTO imie, nazw, zarob;
    END LOOP;

    CLOSE pracownicy;
END;

----10
CREATE TABLE MANAGERS_STATISTICS (
    MANAGER_ID NUMBER,
    NUMBER_OF_SUBJECTS NUMBER,
    SALARY_DIFFERENCE NUMBER
);

DECLARE
    CURSOR menedzerzy IS
        SELECT DISTINCT manager_id
        FROM employees
        WHERE manager_id IS NOT NULL;

    v_manager_id employees.manager_id%TYPE;
    v_count NUMBER;
    v_min   NUMBER;
    v_max   NUMBER;
BEGIN
    OPEN menedzerzy;

    FETCH menedzerzy INTO v_manager_id;
    WHILE menedzerzy%FOUND LOOP

        SELECT COUNT(*),
               MIN(salary),
               MAX(salary)
        INTO v_count, v_min, v_max
        FROM employees
        WHERE manager_id = v_manager_id;

        DBMS_OUTPUT.PUT_LINE(
            'Manager ' || v_manager_id ||
            ': podwładnych = ' || v_count ||
            ', różnica pensji = ' || (v_max - v_min)
        );
        
        INSERT INTO MANAGERS_STATISTICS
        VALUES 	(v_manager_id,
        		v_count,
        		(v_max - v_min));

        FETCH menedzerzy INTO v_manager_id;
    END LOOP;

    CLOSE menedzerzy;
END;

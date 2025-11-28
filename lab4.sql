----1
CREATE OR REPLACE VIEW v_ranking_pensji AS
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS ranking
FROM employees;

----2
CREATE OR REPLACE VIEW v_ranking_pensji AS
SELECT
    employee_id,
    first_name,
    last_name,
    salary,
    DENSE_RANK() OVER (ORDER BY salary DESC) AS ranking,
    SUM(salary) OVER () AS suma_wszystkich_pensji
FROM employees;


----3
SELECT
    e.last_name,
    p.product_name,
    SUM(s.quantity * s.price)
        OVER (PARTITION BY e.employee_id
              ORDER BY s.sale_date
              ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
        AS skumulowana_wartosc_sprzedazy,
    RANK() OVER (ORDER BY (s.quantity * s.price) DESC)
        AS ranking_sprzedazy
FROM sales s
JOIN employees e
    ON s.employee_id = e.employee_id
JOIN products p
    ON s.product_id = p.product_id
ORDER BY e.last_name, s.sale_date;


----4
SELECT
    e.last_name,
    p.product_name,
    s.price AS cena_produktu,
    COUNT(*) OVER (PARTITION BY s.product_id, s.sale_date) AS liczba_transakcji_produktu_danego_dnia,
    SUM(s.quantity * s.price) OVER (PARTITION BY s.product_id, s.sale_date) AS suma_zaplacona_za_produkt_danego_dnia,
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS poprzednia_cena,
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS nastepna_cena
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id
JOIN products p ON s.product_id = p.product_id
ORDER BY s.product_id, s.sale_date;


----5
SELECT
    p.product_name,
    s.price AS cena_produktu,
    SUM(s.quantity * s.price) OVER (
        PARTITION BY p.product_id, TRUNC(s.sale_date, 'MM')
    ) AS suma_miesieczna,
    SUM(s.quantity * s.price) OVER (
        PARTITION BY p.product_id, TRUNC(s.sale_date, 'MM')
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS suma_miesieczna_kumulacyjna
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_id, s.sale_date;

----6
SELECT
    p.product_name,
    p.product_category,
    s22.price AS cena_2022,
    s23.price AS cena_2023,
    (s23.price - s22.price) AS roznica_cen
FROM sales s22
JOIN sales s23
    ON s22.product_id = s23.product_id
    AND TO_CHAR(s22.sale_date, 'MM-DD') = TO_CHAR(s23.sale_date, 'MM-DD')
    AND EXTRACT(YEAR FROM s22.sale_date) = 2022
    AND EXTRACT(YEAR FROM s23.sale_date) = 2023
JOIN products p
    ON p.product_id = s22.product_id
ORDER BY p.product_id, TO_CHAR(s22.sale_date, 'MM-DD');


----7
SELECT
    p.product_category,
    p.product_name,
    s.price AS cena_produktu,
    MIN(s.price) OVER (
        PARTITION BY p.product_category
    ) AS minimalna_cena_kategorii,
    MAX(s.price) OVER (
        PARTITION BY p.product_category
    ) AS maksymalna_cena_kategorii,
    ( MAX(s.price) OVER (PARTITION BY p.product_category)
    - MIN(s.price) OVER (PARTITION BY p.product_category) )
    AS roznica_max_min
FROM sales s
JOIN products p ON s.product_id = p.product_id
ORDER BY p.product_category, p.product_name, s.sale_date;

----8
SELECT
    p.product_name,
    s.sale_date,
    s.price AS cena_biezaca,
    AVG(s.price) OVER (
        PARTITION BY p.product_id
        ORDER BY s.sale_date
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS srednia_kroczaca
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
ORDER BY p.product_id, s.sale_date;

----9
SELECT
    p.product_name,
    p.product_category,
    s.price,
    RANK() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS ranking_cen,
    ROW_NUMBER() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS numer_wiersza,
    DENSE_RANK() OVER (
        PARTITION BY p.product_category
        ORDER BY s.price
    ) AS ranking_gesty
FROM sales s
JOIN products p
    ON s.product_id = p.product_id
ORDER BY p.product_category, s.price;

----10
SELECT
    e.last_name,
    p.product_name,
    s.sale_date,
    (s.price * s.quantity) AS wartosc_transakcji,
    SUM(s.price * s.quantity) OVER (
        PARTITION BY s.employee_id
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS wartosc_rosnaca_pracownika,
    RANK() OVER (
        ORDER BY (s.price * s.quantity) DESC
    ) AS ranking_globalny
FROM sales s
JOIN employees e 
    ON s.employee_id = e.employee_id
JOIN products p
    ON s.product_id = p.product_id
ORDER BY s.employee_id, s.sale_date;

----11
SELECT DISTINCT
    e.first_name,
    e.last_name,
    j.job_title
FROM sales s
JOIN employees e 
    ON s.employee_id = e.employee_id
JOIN jobs j
    ON e.job_id = j.job_id
ORDER BY e.last_name, e.first_name;

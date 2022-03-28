Групповой проект.
Блок №5 Зарплатные транзакции

--1

WITH Salary_M AS
    (
    SELECT
        gfit.client_id, 
        TO_NUMBER(SUBSTR(gfit.income_month, 6, 2)) AS In_M,
        SUM(income_sum_amt) AS Sum_amt_cl_m,
        COUNT(income_sum_amt) AS Cnt_amt_cl_m
    FROM de_common.GROUP_FCT_INCOME_TRANSACTIONS gfit
    INNER JOIN de_common.GROUP_DICT_INCOME_TYPE gdit
        ON gfit.income_type = gdit.income_type
    WHERE gdit.income_nm = 'Зарплатное начисление'
        AND TO_NUMBER(SUBSTR(gfit.income_month, 6, 2)) < 12
    GROUP BY gfit.client_id,TO_NUMBER(SUBSTR(gfit.income_month, 6, 2))
    ORDER BY gfit.client_id,TO_NUMBER(SUBSTR(gfit.income_month, 6, 2))
    )
SELECT DISTINCT
    a.client_id,
    COALESCE(b.Sum_amt_cl_m, 0) AS SALARY_1M_AMT,
    COALESCE(c.Sum_amt_cl_m, 0) AS SALARY_2M_AMT,
    COALESCE(d.Sum_amt_cl_m, 0) AS SALARY_3M_AMT,
    COALESCE(e.Sum_amt_cl_m, 0) AS SALARY_4M_AMT,
    COALESCE(f.Sum_amt_cl_m, 0) AS SALARY_5M_AMT,
    COALESCE(g.Sum_amt_cl_m, 0) AS SALARY_6M_AMT,
    COALESCE(b.Cnt_amt_cl_m, 0) AS SALARY_1M_CNT,
    COALESCE(c.Cnt_amt_cl_m, 0) AS SALARY_2M_CNT,
    COALESCE(d.Cnt_amt_cl_m, 0) AS SALARY_3M_CNT,
    COALESCE(e.Cnt_amt_cl_m, 0) AS SALARY_4M_CNT,
    COALESCE(f.Cnt_amt_cl_m, 0) AS SALARY_5M_CNT,
    COALESCE(g.Cnt_amt_cl_m, 0) AS SALARY_6M_CNT,
    ROUND(COALESCE(b.Sum_amt_cl_m, 0)/(COALESCE(b.Sum_amt_cl_m, 0) + 
        COALESCE(c.Sum_amt_cl_m, 0) + COALESCE(d.Sum_amt_cl_m, 0)), 2) 
        AS SALARY_1M_TO_3M_AMT_PCT,
    ROUND(COALESCE(b.Sum_amt_cl_m, 0)/(COALESCE(b.Sum_amt_cl_m, 0) + 
        COALESCE(c.Sum_amt_cl_m, 0) + COALESCE(d.Sum_amt_cl_m, 0) + 
        COALESCE(e.Sum_amt_cl_m, 0) + COALESCE(f.Sum_amt_cl_m, 0) + 
        COALESCE(g.Sum_amt_cl_m, 0)), 2) AS SALARY_1M_TO_6M_AMT_PCT,
    ROUND(COALESCE(b.Cnt_amt_cl_m, 0)/(COALESCE(b.Cnt_amt_cl_m, 0) + 
        COALESCE(c.Cnt_amt_cl_m, 0) + COALESCE(d.Cnt_amt_cl_m, 0)), 2) 
        AS SALARY_1M_TO_3M_CNT_PCT,
    ROUND(COALESCE(b.Cnt_amt_cl_m, 0)/(COALESCE(b.Cnt_amt_cl_m, 0) + 
        COALESCE(c.Cnt_amt_cl_m, 0) + COALESCE(d.Cnt_amt_cl_m, 0) + 
        COALESCE(e.Cnt_amt_cl_m, 0) + COALESCE(f.Cnt_amt_cl_m, 0) + 
        COALESCE(g.Cnt_amt_cl_m, 0)), 2) AS SALARY_1M_TO_6M_CNT_PCT,
    COUNT(a.Sum_amt_cl_m) OVER (PARTITION BY a.client_id, a.in_m) AS SALARY_DURING_6M_CNT,
    12 - MAX(a.in_m) OVER (PARTITION BY a.client_id) AS LAST_SAL_TRANS_MONTH_CNT,
    12 - MIN(a.in_m) OVER (PARTITION BY a.client_id) AS FIRST_SAL_TRANS_MONTH_CNT
FROM Salary_M a
LEFT JOIN Salary_M b
    ON a.client_id = b.client_id
    AND b.in_m = extract(month from(add_months('2021-12-01',-1)))
LEFT JOIN Salary_M c
    ON a.client_id = c.client_id
    AND c.in_m = extract(month from(add_months('2021-12-01',-2)))
LEFT JOIN Salary_M d
    ON a.client_id = d.client_id
    AND d.in_m = extract(month from(add_months('2021-12-01',-3)))
LEFT JOIN Salary_M e
    ON a.client_id = e.client_id
    AND e.in_m = extract(month from(add_months('2021-12-01',-4)))
LEFT JOIN Salary_M f
    ON a.client_id = f.client_id
    AND f.in_m = extract(month from(add_months('2021-12-01',-5)))
LEFT JOIN Salary_M g
    ON a.client_id = g.client_id
    AND g.in_m = extract(month from(add_months('2021-12-01',-6)))
LEFT JOIN Salary_M h
    ON a.client_id = h.client_id
    AND (h.in_m BETWEEN extract(month from(add_months('2021-12-01',-6))) AND extract(month from(add_months('2021-12-01',-1)))
    AND a.Sum_amt_cl_m > 0)
ORDER BY a.client_id

--2

WITH tgfit AS
    (
    SELECT
        gfit.client_id, 
        MONTHS_BETWEEN(to_date('2021-12-01','YYYY-MM-DD'), to_date(gfit.income_month,'YYYY-MM')) AS In_m,
        gfit.income_sum_amt,
        gfit.transaction_id
    FROM de_common.GROUP_FCT_INCOME_TRANSACTIONS gfit
    INNER JOIN de_common.GROUP_DICT_INCOME_TYPE gdit
        ON gfit.income_type = gdit.income_type
        AND (gdit.income_nm = 'Зарплатное начисление'
        AND TO_DATE('2021-12-01','YYYY-MM-DD')>TO_DATE(gfit.income_month,'YYYY-MM'))
    )
SELECT
    a.client_id,
    SUM(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE 0 END) AS SALARY_1M_AMT,
    SUM(CASE WHEN a.In_m=2 THEN a.income_sum_amt ELSE 0 END) AS SALARY_2M_AMT,
    SUM(CASE WHEN a.In_m=3 THEN a.income_sum_amt ELSE 0 END) AS SALARY_3M_AMT,
    SUM(CASE WHEN a.In_m=4 THEN a.income_sum_amt ELSE 0 END) AS SALARY_4M_AMT,
    SUM(CASE WHEN a.In_m=5 THEN a.income_sum_amt ELSE 0 END) AS SALARY_5M_AMT,
    SUM(CASE WHEN a.In_m=6 THEN a.income_sum_amt ELSE 0 END) AS SALARY_6M_AMT,
    COUNT(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE NULL END) AS SALARY_1M_CNT,
    COUNT(CASE WHEN a.In_m=2 THEN a.income_sum_amt ELSE NULL END) AS SALARY_2M_CNT,
    COUNT(CASE WHEN a.In_m=3 THEN a.income_sum_amt ELSE NULL END) AS SALARY_3M_CNT,
    COUNT(CASE WHEN a.In_m=4 THEN a.income_sum_amt ELSE NULL END) AS SALARY_4M_CNT,
    COUNT(CASE WHEN a.In_m=5 THEN a.income_sum_amt ELSE NULL END) AS SALARY_5M_CNT,
    COUNT(CASE WHEN a.In_m=6 THEN a.income_sum_amt ELSE NULL END) AS SALARY_6M_CNT,
    ROUND(SUM(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE 0 END)/
        SUM(CASE WHEN a.In_m<=3 THEN a.income_sum_amt ELSE 0 END), 2) 
        AS SALARY_1M_TO_3M_AMT_PCT,
    ROUND(SUM(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE 0 END)/
        SUM(CASE WHEN a.In_m<=6 THEN a.income_sum_amt ELSE 0 END), 2) 
        AS SALARY_1M_TO_6M_AMT_PCT,
    ROUND(COUNT(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE NULL END)/
        COUNT(CASE WHEN a.In_m<=3 THEN a.income_sum_amt ELSE NULL END),2) 
        AS SALARY_1M_TO_3M_CNT_PCT,
    ROUND(COUNT(CASE WHEN a.In_m=1 THEN a.income_sum_amt ELSE NULL END)/
        COUNT(CASE WHEN a.In_m<=6 THEN a.income_sum_amt ELSE NULL END),2) 
        AS SALARY_1M_TO_6M_CNT_PCT,
    COUNT(DISTINCT CASE WHEN a.In_m<=6 THEN a.In_m ELSE NULL END) AS SALARY_DURING_6M_CNT,
    MIN(In_m) AS LAST_SAL_TRANS_MONTH_CNT,
    MAX(In_m) AS FIRST_SAL_TRANS_MONTH_CNT
FROM tgfit a
GROUP BY a.client_id
ORDER BY a.client_id

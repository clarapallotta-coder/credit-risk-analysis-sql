--CREDIT-RISK-Analysis.sql
-- Author: Clara Pallotta
--Goal: Rebuild and validate a credit risk segmentation model using SQL, ensuring that risk levels are aligned with actual default behavior and can support data-driven credit decisions (since it was demonstrated that it was falling, in previous powerbi analysis of dataset)


--conteo gral
SELECT COUNT(*) FROM loan_data;

--distribucion default y no default
SELECT loan_status, COUNT(*) as total
FROM loan_data
GROUP BY loan_status;

--default rate : kpi principal
SELECT 
    CAST(COUNT(CASE WHEN TRIM(loan_status) = '1' THEN 1 END) AS FLOAT) 
    / COUNT(*) AS default_rate
FROM loan_data;

--ANALISIS X VARIABLE
--income vs riesgo // creamos los 3 segmentos de high-medium-low 
SELECT 
    CASE income_group
        WHEN 1 THEN 'Low Income'
        WHEN 2 THEN 'Medium Income'
        WHEN 3 THEN 'High Income'
    END as income_segment,
    
    COUNT(*) as total_loans,
    
    CAST(COUNT(CASE WHEN TRIM(loan_status) = '1' THEN 1 END) AS FLOAT)
    / COUNT(*) AS default_rate

FROM (
    SELECT 
        NTILE(3) OVER (ORDER BY person_income) AS income_group,
        loan_status
    FROM loan_data
) t

GROUP BY income_group
ORDER BY income_group;

--debt-to-income --> DTI

SELECT 
    CASE dti_group
        WHEN 1 THEN 'Low DTI'
        WHEN 2 THEN 'Medium DTI'
        WHEN 3 THEN 'High DTI'
    END as dti_segment,
    
    COUNT(*) as total_loans,
    
    CAST(COUNT(CASE WHEN TRIM(loan_status) = '1' THEN 1 END) AS FLOAT)
    / COUNT(*) AS default_rate

FROM (
    SELECT 
        NTILE(3) OVER (ORDER BY loan_percent_income) AS dti_group,
        loan_status
    FROM loan_data
) t

GROUP BY dti_group
ORDER BY dti_group;



--crear high risk profile


WITH base AS (
    SELECT 
        loan_status,
        NTILE(3) OVER (ORDER BY person_income) AS income_group,
        NTILE(3) OVER (ORDER BY loan_percent_income) AS dti_group
    FROM loan_data
),

risk AS (
    SELECT *,
        CASE 
            WHEN income_group = 1 AND dti_group = 3 THEN 'HIGH RISK'
            WHEN dti_group = 3 THEN 'MEDIUM-HIGH RISK'
            WHEN dti_group = 2 THEN 'MEDIUM RISK'
            ELSE 'LOW RISK'
        END AS risk_profile
    FROM base
)

SELECT 
    risk_profile,
    COUNT(*) as total_loans,
    
    CAST(COUNT(CASE WHEN TRIM(loan_status) = '1' THEN 1 END) AS FLOAT)
    / COUNT(*) AS default_rate

FROM risk
GROUP BY risk_profile
ORDER BY default_rate DESC;

--validar si modelo tiene sentido

CREATE TABLE risk AS
WITH base AS (
    SELECT 
        loan_status,
        NTILE(3) OVER (ORDER BY person_income) AS income_group,
        NTILE(3) OVER (ORDER BY loan_percent_income) AS dti_group
    FROM loan_data
)
SELECT *,
    CASE 
        WHEN income_group = 1 AND dti_group = 3 THEN 'HIGH RISK'
        WHEN dti_group = 3 THEN 'MEDIUM-HIGH RISK'
        WHEN dti_group = 2 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_profile
FROM base;

SELECT * FROM risk;

WITH base AS (
    SELECT 
        loan_status,
        NTILE(3) OVER (ORDER BY person_income) AS income_group,
        NTILE(3) OVER (ORDER BY loan_percent_income) AS dti_group
    FROM loan_data
),

risk AS (
    SELECT *,
        CASE 
            WHEN income_group = 1 AND dti_group = 3 THEN 'HIGH RISK'
            WHEN dti_group = 3 THEN 'MEDIUM-HIGH RISK'
            WHEN dti_group = 2 THEN 'MEDIUM RISK'
            ELSE 'LOW RISK'
        END AS risk_profile
    FROM base
)

SELECT 
    risk_profile,
    ROUND(
        CAST(SUM(CASE WHEN TRIM(loan_status) = '1' THEN 1 ELSE 0 END) AS FLOAT)
        / COUNT(*), 
        3
    ) AS default_rate
FROM risk
GROUP BY risk_profile
ORDER BY default_rate DESC;

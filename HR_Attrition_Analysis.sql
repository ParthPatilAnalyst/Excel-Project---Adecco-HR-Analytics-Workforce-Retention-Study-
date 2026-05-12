-- =============================================================================
--  HR EMPLOYEE ATTRITION  — COMPLETE MYSQL ANALYSIS SCRIPT
--  Dataset : IBM Watson HR Analytics (1,470 employees × 35 features)
--  Author  : Senior Data Analyst (15+ years experience)
--  Engine  : MySQL 8.0+  (uses CTEs, Window Functions, JSON_OBJECT)
-- =============================================================================

-- ─────────────────────────────────────────────────────────────────────────────
-- SECTION 0 : DATABASE & TABLE SETUP
-- ─────────────────────────────────────────────────────────────────────────────

CREATE DATABASE IF NOT EXISTS hr_analytics
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE hr_analytics;

DROP TABLE IF EXISTS employee_attrition;

CREATE TABLE employee_attrition (
    EmployeeNumber          INT            PRIMARY KEY,
    Age                     TINYINT        NOT NULL,
    Attrition               ENUM('Yes','No') NOT NULL,
    BusinessTravel          VARCHAR(30),
    DailyRate               SMALLINT,
    Department              VARCHAR(50),
    DistanceFromHome        TINYINT,
    Education               TINYINT        COMMENT '1=Below College, 2=College, 3=Bachelor, 4=Master, 5=Doctor',
    EducationField          VARCHAR(50),
    EnvironmentSatisfaction TINYINT        COMMENT '1=Low, 2=Medium, 3=High, 4=Very High',
    Gender                  ENUM('Male','Female'),
    HourlyRate              SMALLINT,
    JobInvolvement          TINYINT        COMMENT '1=Low, 2=Medium, 3=High, 4=Very High',
    JobLevel                TINYINT,
    JobRole                 VARCHAR(60),
    JobSatisfaction         TINYINT        COMMENT '1=Low, 2=Medium, 3=High, 4=Very High',
    MaritalStatus           VARCHAR(20),
    MonthlyIncome           INT,
    MonthlyRate             INT,
    NumCompaniesWorked      TINYINT,
    OverTime                ENUM('Yes','No'),
    PercentSalaryHike       TINYINT,
    PerformanceRating       TINYINT        COMMENT '1=Low, 2=Good, 3=Excellent, 4=Outstanding',
    RelationshipSatisfaction TINYINT,
    StockOptionLevel        TINYINT        COMMENT '0=None, 1=Low, 2=Medium, 3=High',
    TotalWorkingYears       TINYINT,
    TrainingTimesLastYear   TINYINT,
    WorkLifeBalance         TINYINT        COMMENT '1=Bad, 2=Good, 3=Better, 4=Best',
    YearsAtCompany          TINYINT,
    YearsInCurrentRole      TINYINT,
    YearsSinceLastPromotion TINYINT,
    YearsWithCurrManager    TINYINT,

    INDEX idx_dept          (Department),
    INDEX idx_role          (JobRole),
    INDEX idx_attrition     (Attrition),
    INDEX idx_overtime      (OverTime),
    INDEX idx_income        (MonthlyIncome)
);

-- ─────────────────────────────────────────────────────────────────────────────
-- NOTE: Load data using MySQL CLI or Workbench:
--   LOAD DATA INFILE '/path/to/WA_Fn-UseC_-HR-Employee-Attrition.csv'
--   INTO TABLE employee_attrition
--   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--   LINES TERMINATED BY '\n'
--   IGNORE 1 ROWS
--   (Age, Attrition, BusinessTravel, DailyRate, Department, DistanceFromHome,
--    Education, EducationField, @emp_count, EmployeeNumber,
--    EnvironmentSatisfaction, Gender, HourlyRate, JobInvolvement, JobLevel,
--    JobRole, JobSatisfaction, MaritalStatus, MonthlyIncome, MonthlyRate,
--    NumCompaniesWorked, @over18, OverTime, PercentSalaryHike, PerformanceRating,
--    RelationshipSatisfaction, @std_hours, StockOptionLevel, TotalWorkingYears,
--    TrainingTimesLastYear, WorkLifeBalance, YearsAtCompany, YearsInCurrentRole,
--    YearsSinceLastPromotion, YearsWithCurrManager);
-- ─────────────────────────────────────────────────────────────────────────────


-- =============================================================================
-- SECTION 1 : DATA QUALITY CHECKS
-- =============================================================================

-- 1.1  Row counts and attrition split
SELECT
    COUNT(*)                                              AS total_employees,
    SUM(Attrition = 'Yes')                               AS total_left,
    SUM(Attrition = 'No')                                AS total_stayed,
    ROUND(AVG(Attrition = 'Yes') * 100, 2)               AS attrition_rate_pct
FROM employee_attrition;

-- 1.2  Check for NULL values in critical columns
SELECT
    SUM(Age IS NULL)                    AS null_age,
    SUM(MonthlyIncome IS NULL)          AS null_income,
    SUM(Department IS NULL)             AS null_dept,
    SUM(JobRole IS NULL)                AS null_role,
    SUM(JobSatisfaction IS NULL)        AS null_job_sat,
    SUM(EnvironmentSatisfaction IS NULL) AS null_env_sat,
    SUM(WorkLifeBalance IS NULL)        AS null_wlb
FROM employee_attrition;

-- 1.3  Value distribution sanity checks
SELECT 'Gender'        AS field, Gender        AS value, COUNT(*) AS cnt FROM employee_attrition GROUP BY Gender
UNION ALL
SELECT 'OverTime',               OverTime,               COUNT(*) FROM employee_attrition GROUP BY OverTime
UNION ALL
SELECT 'BusinessTravel',         BusinessTravel,         COUNT(*) FROM employee_attrition GROUP BY BusinessTravel
ORDER BY field, cnt DESC;

-- 1.4  Numeric range checks
SELECT
    MIN(Age)                  AS min_age,    MAX(Age)                  AS max_age,
    MIN(MonthlyIncome)        AS min_income, MAX(MonthlyIncome)        AS max_income,
    MIN(YearsAtCompany)       AS min_tenure, MAX(YearsAtCompany)       AS max_tenure,
    MIN(JobSatisfaction)      AS min_jsat,   MAX(JobSatisfaction)      AS max_jsat,
    MIN(PerformanceRating)    AS min_perf,   MAX(PerformanceRating)    AS max_perf
FROM employee_attrition;


-- =============================================================================
-- SECTION 2 : DESCRIPTIVE STATISTICS
-- =============================================================================

-- 2.1  Comprehensive numeric summary
SELECT
    'Age'               AS metric,
    ROUND(AVG(Age),2)         AS mean_val,
    ROUND(STDDEV(Age),2)      AS std_dev,
    MIN(Age)                  AS min_val,
    MAX(Age)                  AS max_val
FROM employee_attrition
UNION ALL SELECT 'MonthlyIncome', ROUND(AVG(MonthlyIncome),2), ROUND(STDDEV(MonthlyIncome),2),
    MIN(MonthlyIncome), MAX(MonthlyIncome) FROM employee_attrition
UNION ALL SELECT 'YearsAtCompany', ROUND(AVG(YearsAtCompany),2), ROUND(STDDEV(YearsAtCompany),2),
    MIN(YearsAtCompany), MAX(YearsAtCompany) FROM employee_attrition
UNION ALL SELECT 'TotalWorkingYears', ROUND(AVG(TotalWorkingYears),2), ROUND(STDDEV(TotalWorkingYears),2),
    MIN(TotalWorkingYears), MAX(TotalWorkingYears) FROM employee_attrition
UNION ALL SELECT 'PercentSalaryHike', ROUND(AVG(PercentSalaryHike),2), ROUND(STDDEV(PercentSalaryHike),2),
    MIN(PercentSalaryHike), MAX(PercentSalaryHike) FROM employee_attrition
UNION ALL SELECT 'DistanceFromHome', ROUND(AVG(DistanceFromHome),2), ROUND(STDDEV(DistanceFromHome),2),
    MIN(DistanceFromHome), MAX(DistanceFromHome) FROM employee_attrition;

-- 2.2  Workforce composition
SELECT
    Department,
    COUNT(*)                              AS headcount,
    ROUND(COUNT(*)*100.0/(SELECT COUNT(*) FROM employee_attrition),1) AS pct_of_workforce,
    ROUND(AVG(MonthlyIncome),0)           AS avg_monthly_income,
    ROUND(AVG(Age),1)                     AS avg_age,
    ROUND(AVG(YearsAtCompany),1)          AS avg_tenure_yrs
FROM employee_attrition
GROUP BY Department
ORDER BY headcount DESC;

-- 2.3  Age band distribution
SELECT
    CASE
        WHEN Age < 25  THEN 'Under 25'
        WHEN Age < 35  THEN '25-34'
        WHEN Age < 45  THEN '35-44'
        WHEN Age < 55  THEN '45-54'
        ELSE               '55+'
    END                                   AS age_band,
    COUNT(*)                              AS headcount,
    ROUND(AVG(MonthlyIncome),0)           AS avg_income,
    ROUND(AVG(Attrition='Yes')*100,1)     AS attrition_rate_pct
FROM employee_attrition
GROUP BY age_band
ORDER BY MIN(Age);


-- =============================================================================
-- SECTION 3 : ATTRITION ANALYSIS
-- =============================================================================

-- 3.1  Overall attrition rate by department
SELECT
    Department,
    COUNT(*)                                   AS total,
    SUM(Attrition='Yes')                       AS left_count,
    SUM(Attrition='No')                        AS stayed_count,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                AS avg_income
FROM employee_attrition
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 3.2  Attrition rate by Job Role (ranked)
SELECT
    JobRole,
    COUNT(*)                                   AS total,
    SUM(Attrition='Yes')                       AS left_count,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                AS avg_income,
    RANK() OVER (ORDER BY AVG(Attrition='Yes') DESC) AS attrition_rank
FROM employee_attrition
GROUP BY JobRole
ORDER BY attrition_rate_pct DESC;

-- 3.3  Overtime impact — strongest individual predictor
SELECT
    OverTime,
    COUNT(*)                                   AS total,
    SUM(Attrition='Yes')                       AS left_count,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                AS avg_income,
    ROUND(AVG(WorkLifeBalance),2)              AS avg_wlb_score
FROM employee_attrition
GROUP BY OverTime;

-- 3.4  Multi-dimensional attrition: Dept × Overtime
SELECT
    Department,
    OverTime,
    COUNT(*)                                   AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                AS avg_income
FROM employee_attrition
GROUP BY Department, OverTime
ORDER BY Department, attrition_rate_pct DESC;

-- 3.5  Business travel frequency vs attrition
SELECT
    BusinessTravel,
    COUNT(*)                                   AS total,
    SUM(Attrition='Yes')                       AS left_count,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct
FROM employee_attrition
GROUP BY BusinessTravel
ORDER BY attrition_rate_pct DESC;

-- 3.6  Marital status & attrition
SELECT
    MaritalStatus,
    COUNT(*)                                   AS total,
    ROUND(AVG(Attrition='Yes')*100,2)          AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                AS avg_income,
    ROUND(AVG(StockOptionLevel),2)             AS avg_stock_option
FROM employee_attrition
GROUP BY MaritalStatus
ORDER BY attrition_rate_pct DESC;

-- 3.7  Stock option levels and attrition
SELECT
    StockOptionLevel,
    CASE StockOptionLevel WHEN 0 THEN 'None' WHEN 1 THEN 'Low'
                          WHEN 2 THEN 'Medium' ELSE 'High' END AS option_label,
    COUNT(*)                                                   AS total,
    ROUND(AVG(Attrition='Yes')*100,2)                          AS attrition_rate_pct
FROM employee_attrition
GROUP BY StockOptionLevel
ORDER BY StockOptionLevel;

-- 3.8  Job level and attrition
SELECT
    JobLevel,
    CASE JobLevel WHEN 1 THEN 'Junior' WHEN 2 THEN 'Mid'
                  WHEN 3 THEN 'Senior' WHEN 4 THEN 'Lead' ELSE 'Director' END AS level_label,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income
FROM employee_attrition
GROUP BY JobLevel
ORDER BY JobLevel;


-- =============================================================================
-- SECTION 4 : COMPENSATION ANALYSIS
-- =============================================================================

-- 4.1  Salary distribution by department and gender (gender pay gap proxy)
SELECT
    Department,
    Gender,
    COUNT(*)                        AS headcount,
    ROUND(AVG(MonthlyIncome),0)     AS avg_monthly_income,
    ROUND(MIN(MonthlyIncome),0)     AS min_income,
    ROUND(MAX(MonthlyIncome),0)     AS max_income,
    ROUND(STDDEV(MonthlyIncome),0)  AS income_std_dev
FROM employee_attrition
GROUP BY Department, Gender
ORDER BY Department, Gender;

-- 4.2  Income quartile analysis with attrition rates
WITH income_quartiles AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY MonthlyIncome) AS income_quartile
    FROM employee_attrition
)
SELECT
    income_quartile,
    CASE income_quartile
        WHEN 1 THEN 'Q1 — Low (Bottom 25%)'
        WHEN 2 THEN 'Q2 — Mid-Low'
        WHEN 3 THEN 'Q3 — Mid-High'
        WHEN 4 THEN 'Q4 — High (Top 25%)'
    END                                          AS quartile_label,
    COUNT(*)                                     AS headcount,
    ROUND(MIN(MonthlyIncome),0)                  AS min_income,
    ROUND(MAX(MonthlyIncome),0)                  AS max_income,
    ROUND(AVG(MonthlyIncome),0)                  AS avg_income,
    ROUND(AVG(Attrition='Yes')*100,2)            AS attrition_rate_pct
FROM income_quartiles
GROUP BY income_quartile
ORDER BY income_quartile;

-- 4.3  Salary hike by performance rating
SELECT
    PerformanceRating,
    CASE PerformanceRating WHEN 1 THEN 'Low' WHEN 2 THEN 'Good'
                           WHEN 3 THEN 'Excellent' ELSE 'Outstanding' END AS perf_label,
    COUNT(*)                                  AS employees,
    ROUND(AVG(PercentSalaryHike),2)           AS avg_hike_pct,
    MIN(PercentSalaryHike)                    AS min_hike_pct,
    MAX(PercentSalaryHike)                    AS max_hike_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct
FROM employee_attrition
GROUP BY PerformanceRating
ORDER BY PerformanceRating;

-- 4.4  Identify underpaid employees relative to their role median (flight risk)
WITH role_median AS (
    SELECT
        JobRole,
        AVG(MonthlyIncome) AS role_avg_income   -- MySQL lacks native MEDIAN; using AVG as proxy
    FROM employee_attrition
    GROUP BY JobRole
)
SELECT
    e.EmployeeNumber,
    e.JobRole,
    e.Department,
    e.MonthlyIncome,
    ROUND(rm.role_avg_income,0)                                  AS role_avg_income,
    ROUND((e.MonthlyIncome - rm.role_avg_income)/rm.role_avg_income*100,1) AS pct_vs_role_avg,
    e.Attrition,
    e.OverTime
FROM employee_attrition e
JOIN role_median rm ON e.JobRole = rm.JobRole
WHERE e.MonthlyIncome < rm.role_avg_income * 0.80   -- >20% below role average
  AND e.Attrition = 'Yes'
ORDER BY pct_vs_role_avg ASC
LIMIT 25;


-- =============================================================================
-- SECTION 5 : SATISFACTION & ENGAGEMENT ANALYSIS
-- =============================================================================

-- 5.1  Average satisfaction scores by attrition group
SELECT
    Attrition,
    ROUND(AVG(JobSatisfaction),2)          AS avg_job_satisfaction,
    ROUND(AVG(EnvironmentSatisfaction),2)  AS avg_env_satisfaction,
    ROUND(AVG(RelationshipSatisfaction),2) AS avg_rel_satisfaction,
    ROUND(AVG(WorkLifeBalance),2)          AS avg_work_life_balance,
    ROUND(AVG(JobInvolvement),2)           AS avg_job_involvement
FROM employee_attrition
GROUP BY Attrition;

-- 5.2  Employees with all satisfaction scores at minimum (critically disengaged)
SELECT
    EmployeeNumber, Department, JobRole, Attrition,
    JobSatisfaction, EnvironmentSatisfaction,
    RelationshipSatisfaction, WorkLifeBalance, JobInvolvement,
    MonthlyIncome, OverTime
FROM employee_attrition
WHERE JobSatisfaction         = 1
  AND EnvironmentSatisfaction = 1
  AND RelationshipSatisfaction= 1
  AND WorkLifeBalance         = 1
ORDER BY Attrition DESC, MonthlyIncome;

-- 5.3  Satisfaction by department — engagement deep dive
SELECT
    Department,
    ROUND(AVG(JobSatisfaction),2)          AS avg_job_sat,
    ROUND(AVG(EnvironmentSatisfaction),2)  AS avg_env_sat,
    ROUND(AVG(WorkLifeBalance),2)          AS avg_wlb,
    ROUND(AVG(JobInvolvement),2)           AS avg_involvement,
    ROUND(AVG(Attrition='Yes')*100,2)      AS attrition_rate_pct
FROM employee_attrition
GROUP BY Department
ORDER BY attrition_rate_pct DESC;

-- 5.4  Work-life balance breakdown
SELECT
    WorkLifeBalance,
    CASE WorkLifeBalance WHEN 1 THEN 'Bad' WHEN 2 THEN 'Good'
                         WHEN 3 THEN 'Better' ELSE 'Best' END AS wlb_label,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income,
    SUM(OverTime='Yes')                       AS overtime_count
FROM employee_attrition
GROUP BY WorkLifeBalance
ORDER BY WorkLifeBalance;


-- =============================================================================
-- SECTION 6 : TENURE & CAREER PROGRESSION
-- =============================================================================

-- 6.1  Attrition rate by tenure band (survival-style view)
SELECT
    CASE
        WHEN YearsAtCompany = 0            THEN '< 1 Year'
        WHEN YearsAtCompany BETWEEN 1 AND 3  THEN '1 – 3 Years'
        WHEN YearsAtCompany BETWEEN 4 AND 5  THEN '4 – 5 Years'
        WHEN YearsAtCompany BETWEEN 6 AND 10 THEN '6 – 10 Years'
        WHEN YearsAtCompany BETWEEN 11 AND 20 THEN '11 – 20 Years'
        ELSE                                   '20+ Years'
    END                                          AS tenure_band,
    COUNT(*)                                     AS headcount,
    SUM(Attrition='Yes')                         AS left_count,
    ROUND(AVG(Attrition='Yes')*100,2)            AS attrition_rate_pct
FROM employee_attrition
GROUP BY tenure_band
ORDER BY MIN(YearsAtCompany);

-- 6.2  Promotion stagnation vs attrition
SELECT
    YearsSinceLastPromotion,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income,
    ROUND(AVG(JobSatisfaction),2)             AS avg_job_sat
FROM employee_attrition
GROUP BY YearsSinceLastPromotion
ORDER BY YearsSinceLastPromotion;

-- 6.3  Training frequency vs attrition
SELECT
    TrainingTimesLastYear,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income
FROM employee_attrition
GROUP BY TrainingTimesLastYear
ORDER BY TrainingTimesLastYear;

-- 6.4  Number of companies worked (job-hopper profile)
SELECT
    NumCompaniesWorked,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)               AS avg_income,
    ROUND(AVG(YearsAtCompany),1)              AS avg_tenure_here
FROM employee_attrition
GROUP BY NumCompaniesWorked
ORDER BY NumCompaniesWorked;

-- 6.5  Manager relationship effect
SELECT
    YearsWithCurrManager,
    COUNT(*)                                  AS headcount,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct
FROM employee_attrition
GROUP BY YearsWithCurrManager
ORDER BY YearsWithCurrManager;


-- =============================================================================
-- SECTION 7 : ADVANCED ANALYSIS (CTEs + WINDOW FUNCTIONS)
-- =============================================================================

-- 7.1  Ranked Job Roles within each Department by attrition rate
WITH role_dept_stats AS (
    SELECT
        Department,
        JobRole,
        COUNT(*)                           AS headcount,
        ROUND(AVG(Attrition='Yes')*100,2)  AS attrition_rate_pct,
        ROUND(AVG(MonthlyIncome),0)        AS avg_income
    FROM employee_attrition
    GROUP BY Department, JobRole
)
SELECT
    Department,
    JobRole,
    headcount,
    attrition_rate_pct,
    avg_income,
    RANK() OVER (PARTITION BY Department ORDER BY attrition_rate_pct DESC) AS rank_in_dept
FROM role_dept_stats
ORDER BY Department, rank_in_dept;

-- 7.2  Running cumulative attrition by years at company
WITH tenure_groups AS (
    SELECT
        YearsAtCompany,
        COUNT(*)                                  AS total,
        SUM(Attrition='Yes')                      AS attrited
    FROM employee_attrition
    GROUP BY YearsAtCompany
)
SELECT
    YearsAtCompany,
    total,
    attrited,
    ROUND(attrited*100.0/total,2)                                   AS period_attrition_pct,
    SUM(attrited) OVER (ORDER BY YearsAtCompany)                    AS cumulative_attrited,
    SUM(total) OVER (ORDER BY YearsAtCompany)                       AS cumulative_total,
    ROUND(SUM(attrited) OVER (ORDER BY YearsAtCompany)*100.0/
          SUM(total)    OVER (ORDER BY YearsAtCompany),2)           AS cumulative_attrition_pct
FROM tenure_groups
ORDER BY YearsAtCompany;

-- 7.3  Income percentile rank per employee within their department
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome,
    Attrition,
    ROUND(PERCENT_RANK() OVER (PARTITION BY Department ORDER BY MonthlyIncome)*100,1) AS income_pctile_in_dept,
    ROUND(PERCENT_RANK() OVER (ORDER BY MonthlyIncome)*100,1)                         AS income_pctile_overall
FROM employee_attrition
ORDER BY Department, income_pctile_in_dept
LIMIT 30;

-- 7.4  Multi-factor HIGH RISK employee segmentation (composite risk score)
WITH risk_scored AS (
    SELECT
        EmployeeNumber,
        Department,
        JobRole,
        MonthlyIncome,
        Attrition,
        OverTime,
        JobSatisfaction,
        WorkLifeBalance,
        YearsSinceLastPromotion,
        StockOptionLevel,
        -- Each flag adds risk; total = composite risk score (0-7)
        (OverTime             = 'Yes')      +
        (JobSatisfaction      <= 2)         +
        (WorkLifeBalance      <= 2)         +
        (EnvironmentSatisfaction <= 2)      +
        (StockOptionLevel      = 0)         +
        (YearsSinceLastPromotion >= 5)      +
        (NumCompaniesWorked    >= 5)        AS risk_score
    FROM employee_attrition
)
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome,
    Attrition,
    risk_score,
    CASE
        WHEN risk_score >= 5 THEN '🔴 Very High'
        WHEN risk_score >= 4 THEN '🟠 High'
        WHEN risk_score >= 3 THEN '🟡 Medium'
        ELSE                      '🟢 Low'
    END AS risk_band
FROM risk_scored
ORDER BY risk_score DESC, Attrition DESC
LIMIT 40;

-- 7.5  Retention rate over years — cohort-style
WITH cohorts AS (
    SELECT
        CASE WHEN YearsAtCompany <= 2  THEN 'Early (0-2yr)'
             WHEN YearsAtCompany <= 5  THEN 'Growing (3-5yr)'
             WHEN YearsAtCompany <= 10 THEN 'Mid (6-10yr)'
             ELSE                           'Veteran (10+yr)' END AS cohort,
        Attrition
    FROM employee_attrition
)
SELECT
    cohort,
    COUNT(*)                                  AS total,
    SUM(Attrition='No')                       AS retained,
    SUM(Attrition='Yes')                      AS attrited,
    ROUND(AVG(Attrition='No')*100,2)          AS retention_rate_pct,
    ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct
FROM cohorts
GROUP BY cohort
ORDER BY MIN(cohort);


-- =============================================================================
-- SECTION 8 : EXECUTIVE SUMMARY VIEWS
-- =============================================================================

-- 8.1  Top 10 attrition risk roles (volume × rate combined)
SELECT
    JobRole,
    Department,
    COUNT(*)                                    AS total_employees,
    SUM(Attrition='Yes')                        AS left_count,
    ROUND(AVG(Attrition='Yes')*100,2)           AS attrition_rate_pct,
    ROUND(AVG(MonthlyIncome),0)                 AS avg_income,
    SUM(OverTime='Yes')                         AS overtime_employees,
    ROUND(AVG(JobSatisfaction),2)               AS avg_job_sat
FROM employee_attrition
GROUP BY JobRole, Department
HAVING COUNT(*) >= 10                            -- Only roles with meaningful headcount
ORDER BY attrition_rate_pct DESC
LIMIT 10;

-- 8.2  Executive KPI summary (single-row dashboard)
SELECT
    COUNT(*)                                       AS total_employees,
    ROUND(AVG(Attrition='Yes')*100,1)              AS overall_attrition_pct,
    ROUND(AVG(MonthlyIncome),0)                    AS avg_monthly_income,
    ROUND(AVG(YearsAtCompany),1)                   AS avg_tenure_yrs,
    ROUND(AVG(JobSatisfaction),2)                  AS avg_job_satisfaction,
    ROUND(AVG(WorkLifeBalance),2)                  AS avg_work_life_balance,
    ROUND(AVG(OverTime='Yes')*100,1)               AS pct_on_overtime,
    ROUND(AVG(CASE WHEN OverTime='Yes' THEN Attrition='Yes' END)*100,1) AS overtime_attrition_pct,
    ROUND(AVG(CASE WHEN OverTime='No'  THEN Attrition='Yes' END)*100,1) AS no_overtime_attrition_pct,
    SUM(StockOptionLevel=0)                        AS employees_no_stock_options,
    ROUND(AVG(PercentSalaryHike),2)                AS avg_salary_hike_pct
FROM employee_attrition;

-- 8.3  Department health scorecard
SELECT
    Department,
    COUNT(*)                                     AS headcount,
    ROUND(AVG(Attrition='Yes')*100,1)            AS attrition_pct,
    ROUND(AVG(MonthlyIncome),0)                  AS avg_income,
    ROUND(AVG(JobSatisfaction),2)                AS avg_job_sat,
    ROUND(AVG(WorkLifeBalance),2)                AS avg_wlb,
    ROUND(AVG(OverTime='Yes')*100,1)             AS overtime_pct,
    ROUND(AVG(PercentSalaryHike),1)              AS avg_hike_pct,
    ROUND(AVG(TrainingTimesLastYear),1)          AS avg_trainings,
    -- Composite health score (higher is worse)
    ROUND(
        (AVG(Attrition='Yes')*100 * 0.4) +
        ((5 - AVG(JobSatisfaction)) * 5 * 0.3) +
        (AVG(OverTime='Yes') * 30 * 0.3)
    ,1)                                          AS dept_health_risk_score
FROM employee_attrition
GROUP BY Department
ORDER BY dept_health_risk_score DESC;

-- 8.4  Action list — immediate retention priorities (current employees at high risk)
SELECT
    e.EmployeeNumber,
    e.Department,
    e.JobRole,
    e.Age,
    e.MonthlyIncome,
    e.OverTime,
    e.JobSatisfaction,
    e.WorkLifeBalance,
    e.YearsSinceLastPromotion,
    e.StockOptionLevel,
    e.Attrition,
    'Flag for manager 1:1 + compensation review' AS recommended_action
FROM employee_attrition e
WHERE e.Attrition        = 'No'          -- Still with company
  AND e.OverTime         = 'Yes'
  AND e.JobSatisfaction  <= 2
  AND e.StockOptionLevel  = 0
ORDER BY e.YearsSinceLastPromotion DESC, e.MonthlyIncome ASC
LIMIT 20;


-- =============================================================================
-- SECTION 9 : STORED PROCEDURE — ATTRITION REPORT BY DEPARTMENT
-- =============================================================================

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_attrition_report $$

CREATE PROCEDURE sp_attrition_report(IN p_department VARCHAR(50))
BEGIN
    DECLARE v_dept VARCHAR(50);
    SET v_dept = IFNULL(p_department, '%');

    SELECT
        Department,
        JobRole,
        Gender,
        COUNT(*)                                  AS headcount,
        ROUND(AVG(Attrition='Yes')*100,2)         AS attrition_rate_pct,
        ROUND(AVG(MonthlyIncome),0)               AS avg_income,
        ROUND(AVG(JobSatisfaction),2)             AS avg_job_sat,
        ROUND(AVG(WorkLifeBalance),2)             AS avg_wlb,
        SUM(OverTime='Yes')                       AS overtime_count
    FROM employee_attrition
    WHERE Department LIKE v_dept
    GROUP BY Department, JobRole, Gender
    ORDER BY Department, attrition_rate_pct DESC;
END $$

DELIMITER ;

-- Usage:
-- CALL sp_attrition_report('Sales');          -- Filter by department
-- CALL sp_attrition_report(NULL);             -- All departments


-- =============================================================================
-- SECTION 10 : ANALYTICAL VIEWS FOR BI TOOLS
-- =============================================================================

CREATE OR REPLACE VIEW vw_attrition_summary AS
SELECT
    Department,
    JobRole,
    Gender,
    MaritalStatus,
    OverTime,
    BusinessTravel,
    CASE
        WHEN Age < 25  THEN 'Under 25'
        WHEN Age < 35  THEN '25-34'
        WHEN Age < 45  THEN '35-44'
        WHEN Age < 55  THEN '45-54'
        ELSE               '55+'
    END                                           AS age_band,
    CASE
        WHEN YearsAtCompany <= 2  THEN 'Early (0-2yr)'
        WHEN YearsAtCompany <= 5  THEN 'Growing (3-5yr)'
        WHEN YearsAtCompany <= 10 THEN 'Mid (6-10yr)'
        ELSE                           'Veteran (10+yr)'
    END                                           AS tenure_band,
    NTILE(4) OVER (ORDER BY MonthlyIncome)        AS income_quartile,
    Attrition,
    MonthlyIncome,
    JobSatisfaction,
    EnvironmentSatisfaction,
    WorkLifeBalance,
    JobInvolvement,
    PerformanceRating,
    StockOptionLevel,
    YearsSinceLastPromotion,
    TrainingTimesLastYear
FROM employee_attrition;

CREATE OR REPLACE VIEW vw_high_risk_employees AS
SELECT
    EmployeeNumber,
    Department,
    JobRole,
    MonthlyIncome,
    OverTime,
    JobSatisfaction,
    WorkLifeBalance,
    StockOptionLevel,
    YearsSinceLastPromotion,
    Attrition,
    (OverTime='Yes') + (JobSatisfaction<=2) + (WorkLifeBalance<=2) +
    (StockOptionLevel=0) + (YearsSinceLastPromotion>=5) AS risk_score
FROM employee_attrition
HAVING risk_score >= 4
ORDER BY risk_score DESC;

-- =============================================================================
--  END OF SCRIPT
--  Run sections independently or sequentially as needed.
--  Estimated analysis coverage: 40+ KPIs, 20+ segmentation cuts,
--  cohort retention, compensation equity, engagement scoring,
--  composite risk banding, stored procedures, and BI-ready views.
-- =============================================================================

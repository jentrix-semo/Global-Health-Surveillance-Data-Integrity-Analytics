-- ============================================================================
-- POWER BI KPI VIEW 1: Global Executive Summary Cards
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_global_kpis AS
SELECT 
    SUM(total_cases) AS global_total_cases,
    COUNT(DISTINCT iso3) AS total_countries_evaluated,
    SUM(high_burden_flag) AS total_high_burden_nations,
    ROUND(AVG(ci_relative_width)::numeric, 2) AS global_avg_uncertainty_pct,
    MAX(total_cases) AS max_country_burden
FROM vw_tb_country_totals;

-- ============================================================================
-- POWER BI KPI VIEW 2: Regional Performance & Share Matrix
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_regional_breakdown AS
WITH regional_summary AS (
    SELECT 
        who_region,
        COUNT(DISTINCT iso3) AS country_count,
        SUM(high_burden_flag) AS hbc_count,
        SUM(total_cases) AS regional_cases,
        ROUND(AVG(ci_relative_width)::numeric, 2) AS avg_uncertainty_pct
    FROM vw_tb_country_totals
    GROUP BY who_region
)
SELECT 
    who_region,
    country_count,
    hbc_count,
    regional_cases,
    -- FIXED: Cast the entire quotient to numeric before rounding
    ROUND((regional_cases / (SELECT SUM(total_cases) FROM vw_tb_country_totals) * 100)::numeric, 2) AS pct_global_burden,
    avg_uncertainty_pct,
    RANK() OVER (ORDER BY regional_cases DESC) AS regional_rank
FROM regional_summary;

-- ============================================================================
-- POWER BI KPI VIEW 3: Risk Factor Attributable Burden
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_risk_attribution AS
WITH risk_totals AS (
    SELECT 
        risk_factor,
        COUNT(DISTINCT iso3) AS reporting_countries,
        SUM(best) AS total_attributable_cases
    FROM tb_burden_2024_engineered
    WHERE risk_factor != 'all'
    GROUP BY risk_factor
)
SELECT 
    CASE risk_factor
        WHEN 'und' THEN 'Undernutrition'
        WHEN 'dia' THEN 'Diabetes Mellitus'
        WHEN 'alc' THEN 'Alcohol Use Disorder'
        WHEN 'smk' THEN 'Smoking'
        WHEN 'hiv' THEN 'HIV Co-infection'
    END AS risk_factor_name,
    risk_factor AS risk_factor_code,
    reporting_countries,
    total_attributable_cases,
    -- FIXED: Cast the entire quotient to numeric before rounding
    ROUND((total_attributable_cases / SUM(total_attributable_cases) OVER () * 100)::numeric, 2) AS pct_risk_share
FROM risk_totals;

-- ============================================================================
-- POWER BI KPI VIEW 4: Kenya & East Africa Benchmark
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_kenya_eac_benchmark AS
SELECT 
    country,
    iso3,
    total_cases,
    lower_bound,
    upper_bound,
    ci_relative_width AS uncertainty_pct,
    high_burden_flag,
    income_group,
    RANK() OVER (ORDER BY total_cases DESC) AS regional_rank,
    CASE WHEN country = 'Kenya' THEN 1 ELSE 0 END AS is_kenya_flag
FROM vw_tb_country_totals
WHERE east_africa_flag = 1;

-- ============================================================================
-- POWER BI KPI VIEW 5: Demographic Age-Sex Distribution
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_demographic_pyramid AS
SELECT 
    age_group,
    SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END) AS male_cases,
    SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END) AS female_cases,
    -1 * SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END) AS male_cases_pyramid,
    -- FIXED: Cast division to numeric before rounding
    ROUND(
        (SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END) / 
        NULLIF(SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END), 0))::numeric, 2
    ) AS male_to_female_ratio
FROM tb_burden_2024_engineered
WHERE sex IN ('Male', 'Female')
  AND age_group IN ('15-24', '25-34', '35-44', '45-54', '55-64', '65plus')
  AND risk_factor = 'all'
GROUP BY age_group;

-- ============================================================================
-- POWER BI KPI VIEW 6: Income Tier & Quality Audit Matrix
-- ============================================================================
CREATE OR REPLACE VIEW vw_pbi_data_quality_audit AS
SELECT 
    income_group,
    COUNT(DISTINCT iso3) AS country_count,
    ROUND(AVG(total_cases)::numeric, 0) AS mean_cases,
    ROUND(AVG(ci_width)::numeric, 0) AS avg_ci_width,
    ROUND(AVG(ci_relative_width)::numeric, 2) AS avg_uncertainty_pct
FROM vw_tb_country_totals
GROUP BY income_group;

-- ============================================================================
-- MASTER VERIFICATION SUITE: 6-VIEW DATA MART
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TEST 1: Schema Existence Check
-- Verifies that all 6 views compiled cleanly in the database schema
-- ----------------------------------------------------------------------------
SELECT 
    table_name AS view_name, 
    'EXISTS' AS status
FROM information_schema.views
WHERE table_schema = 'public' 
  AND table_name IN (
      'vw_pbi_global_kpis', 
      'vw_pbi_regional_breakdown', 
      'vw_pbi_risk_attribution', 
      'vw_pbi_kenya_eac_benchmark',
      'vw_pbi_demographic_pyramid',
      'vw_pbi_data_quality_audit'
  )
ORDER BY table_name;


-- ----------------------------------------------------------------------------
-- TEST 2: Data Sampling & Row Counts
-- Inspects top rows and verifies record counts per view
-- ----------------------------------------------------------------------------

-- View 1: Global Executive Summary Cards (Should return 1 row)
SELECT '1. vw_pbi_global_kpis' AS active_test, COUNT(*) AS row_count FROM vw_pbi_global_kpis;
SELECT * FROM vw_pbi_global_kpis;

-- View 2: Regional Breakdown (Should return 7 WHO regions)
SELECT '2. vw_pbi_regional_breakdown' AS active_test, COUNT(*) AS row_count FROM vw_pbi_regional_breakdown;
SELECT * FROM vw_pbi_regional_breakdown ORDER BY regional_rank;

-- View 3: Risk Factor Attribution (Should return 5 comorbidities)
SELECT '3. vw_pbi_risk_attribution' AS active_test, COUNT(*) AS row_count FROM vw_pbi_risk_attribution;
SELECT * FROM vw_pbi_risk_attribution ORDER BY total_attributable_cases DESC;

-- View 4: Kenya & East Africa Benchmark (Should return ~10 EAC countries)
SELECT '4. vw_pbi_kenya_eac_benchmark' AS active_test, COUNT(*) AS row_count FROM vw_pbi_kenya_eac_benchmark;
SELECT * FROM vw_pbi_kenya_eac_benchmark ORDER BY regional_rank;

-- View 5: Demographic Pyramid (Should return 6 age brackets: 15-24 through 65plus)
SELECT '5. vw_pbi_demographic_pyramid' AS active_test, COUNT(*) AS row_count FROM vw_pbi_demographic_pyramid;
SELECT * FROM vw_pbi_demographic_pyramid ORDER BY age_group;

-- View 6: Data Quality & Income Tier Audit (Should return 5 income groups)
SELECT '6. vw_pbi_data_quality_audit' AS active_test, COUNT(*) AS row_count FROM vw_pbi_data_quality_audit;
SELECT * FROM vw_pbi_data_quality_audit ORDER BY avg_uncertainty_pct DESC;


-- ----------------------------------------------------------------------------
-- TEST 3: Mathematical Integrity & Reconciliation Audits
-- ----------------------------------------------------------------------------

-- Check 3A: Do regional burden percentages sum to 100%?
SELECT 
    'Regional % Reconciliation' AS test_name,
    SUM(pct_global_burden) AS total_sum,
    CASE WHEN ROUND(SUM(pct_global_burden)::numeric, 0) = 100 THEN 'PASS ' ELSE 'FAIL ' END AS audit_status
FROM vw_pbi_regional_breakdown;

-- Check 3B: Do risk factor percentages sum to 100%?
SELECT 
    'Risk Factor % Reconciliation' AS test_name,
    SUM(pct_risk_share) AS total_sum,
    CASE WHEN ROUND(SUM(pct_risk_share)::numeric, 0) = 100 THEN 'PASS ' ELSE 'FAIL ' END AS audit_status
FROM vw_pbi_risk_attribution;

-- Check 3C: Pyramid Negativity Check (Ensures male pyramid values are negative for Power BI)
SELECT 
    'Pyramid Orientation Check' AS test_name,
    MIN(male_cases_pyramid) AS min_pyramid_val,
    CASE WHEN MIN(male_cases_pyramid) <= 0 THEN 'PASS ' ELSE 'FAIL ' END AS audit_status
FROM vw_pbi_demographic_pyramid;
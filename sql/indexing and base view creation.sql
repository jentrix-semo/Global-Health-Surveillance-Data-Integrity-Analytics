-- ============================================================================
-- 1. DATABASE INDEXING FOR EDA PERFORMANCE
-- Goal: Create composite and single-column indexes on high-cardinality 
--       filtering attributes to eliminate full-table scans during EDA queries.
-- ============================================================================

-- Index on primary demographic and risk factor dimensions used in GROUP BY clauses
CREATE INDEX IF NOT EXISTS idx_tb_demographics 
    ON tb_burden_2024_engineered (sex, age_group, risk_factor);

-- Index on geographic region for regional Pareto aggregations
CREATE INDEX IF NOT EXISTS idx_tb_region 
    ON tb_burden_2024_engineered (who_region);

-- Index on ISO3 country codes for joins and mapping
CREATE INDEX IF NOT EXISTS idx_tb_iso3 
    ON tb_burden_2024_engineered (iso3);


-- ============================================================================
-- 2. EDA BASE VIEW CREATION (NATIONAL BASELINE ABSTRACTION)
-- Goal: Abstract national total estimates (sex='a', age_group='all', risk_factor='all')
--       into a clean relational view, avoiding repeated boilerplate filtering.
-- ============================================================================

CREATE OR REPLACE VIEW vw_tb_country_totals AS
SELECT 
    country,
    iso3,
    who_region,
    income_group,
    high_burden_flag,
    east_africa_flag,
    best AS total_cases,
    lo AS lower_bound,
    hi AS upper_bound,
    ci_width,
    ci_relative_width
FROM tb_burden_2024_engineered
WHERE sex = 'a' 
  AND age_group = 'all' 
  AND risk_factor = 'all';


-- ============================================================================
-- 3. SANITY AUDIT & FEATURE POPULATION CHECK
-- Goal: Confirm engineered binary flags and regions map correctly without missing values.
-- ============================================================================

SELECT 
    who_region, 
    income_group, 
    COUNT(*) AS total_records,
    SUM(high_burden_flag) AS high_burden_count,
    SUM(east_africa_flag) AS east_africa_count
FROM tb_burden_2024_engineered
GROUP BY who_region, income_group
ORDER BY high_burden_count DESC, total_records DESC;
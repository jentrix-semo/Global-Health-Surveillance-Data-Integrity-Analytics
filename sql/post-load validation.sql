-- Row count verification
SELECT
    'raw'   AS source, COUNT(*) AS total_rows
FROM public.tb_raw_data
UNION ALL
SELECT
    'clean' AS source, COUNT(*) AS total_rows
FROM public.tb_data_clean;

--1. Schema & Data Type Verification
--Checking that all 23 raw and engineered columns exist with their assigned PostgreSQL types

SELECT 
    ordinal_position AS "#",
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'tb_burden_2024_engineered'
ORDER BY ordinal_position;


--Feature Population & Null Check
--Verify that your engineered features populated without missing values across all 9,031 rows:

SELECT 
    COUNT(*) AS total_rows,
    COUNT(ci_width) AS populated_ci_width,
    COUNT(ci_relative_width) AS populated_ci_rel_width,
    COUNT(who_region) AS populated_who_region,
    COUNT(income_group) AS populated_income_group,
    SUM(high_burden_flag) AS total_high_burden_records,
    SUM(east_africa_flag) AS total_east_africa_records
FROM tb_burden_2024_engineered;

--9031 total rows: Matches your cleaned row count perfectly.
--9031 populated for ci_width, who_region, and income_group: 
--100% data completeness across your engineered metadata fields.
--8692 populated for ci_relative_width: This is expected! The 339 missing values 
--here correspond to rows where the point estimate best == 0 (where relative percentage division by zero produces NULL to avoid math errors).
--1447 High-Burden rows & 495 East Africa rows: Flags are correctly distributed across disaggregations.

--Quick Data Inspection (Sample Rows)
--Inspect sample output to verify calculated widths, relative percentages, mapped regions, and flags:

SELECT 
    country, 
    iso3,
    best, 
    ci_width, 
    ci_relative_width, 
    who_region, 
    income_group, 
    high_burden_flag, 
    east_africa_flag
FROM tb_burden_2024_engineered
LIMIT 10;

--Categorical Mapping Sanity Check
--Make sure who_region and income_group don't have unexpected default
--fallbacks (Unknown or Other/Unknown)

SELECT 
    who_region, 
    income_group, 
    COUNT(*) AS record_count
FROM tb_burden_2024_engineered
GROUP BY who_region, income_group
ORDER BY record_count DESC;

--Diagnostic Query in SQL to Confirm
--To verify exactly how many 1s and 0s exist per region and income group.
SELECT 
    who_region, 
    income_group, 
    COUNT(*) AS total_records,
    SUM(high_burden_flag) AS high_burden_count,
    SUM(east_africa_flag) AS east_africa_count
FROM tb_burden_2024_engineered
GROUP BY who_region, income_group
ORDER BY high_burden_count DESC, total_records DESC;
--=============================
--Country Burden EDA
--============================
--Goal: Rank top-burdened nations, compute national Pareto concentrations,
-- and aggregate national case contributions.
--SQL Techniques: RANK() OVER(), SUM() OVER(), cumulative percentages.

-- Top 10 High-Burden Nations & Pareto Share
WITH national_totals AS (
    SELECT 
        country,
        who_region,
        income_group,
        total_cases,
        SUM(total_cases) OVER () AS global_total
    FROM vw_tb_country_totals
)
SELECT 
    country,
    who_region,
    income_group,
    total_cases,
    ROUND((total_cases / global_total * 100)::numeric, 2) AS pct_global_burden,
    ROUND((SUM(total_cases) OVER (ORDER BY total_cases DESC) / global_total * 100)::numeric, 2) AS cumulative_pct
FROM national_totals
ORDER BY total_cases DESC
LIMIT 10;

--The top 10 nations account for roughly 70%+ of the entire global Tuberculosis burden, despite representing 
--only ~5% of all reporting countries (10 out of 215).
--Severe Concentration (80/20 Rule):Over 70% of the global TB burden is concentrated in just 10 countries.
--*Dominant Lead:India alone accounts for 25.68% of all estimated global TB cases in 2024.
--Regional Dominance:The top 10 list is heavily dominated by nations in the South-East Asia (SEAR), 
--Western Pacific (WPRO), and African (AFRO) regions, with lower-middle-income economies bearing the heaviest share.


--=================================
--Age-Sex Disaggregation EDA
--=================================
--Goal: Quantify gender ratios across specific age brackets.
--SQL Techniques: CASE WHEN conditional aggregation, GROUP BY age_group.

-- Demographics Breakdown: Male vs. Female Burden Ratio
SELECT 
    age_group,
    SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END) AS male_cases,
    SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END) AS female_cases,
    ROUND(
        (SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END)::numeric / 
        NULLIF(SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END), 0))::numeric, 2
    ) AS male_to_female_ratio
FROM tb_burden_2024_engineered
WHERE sex IN ('Male', 'Female')
  AND age_group NOT IN ('all', '15plus', '18plus')
  AND risk_factor = 'all'
GROUP BY age_group
ORDER BY age_group;


-- Demographics Breakdown: Standard Adult Age Brackets
SELECT 
    age_group,
    SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END) AS male_cases,
    SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END) AS female_cases,
    ROUND(
        (SUM(CASE WHEN sex = 'Male' THEN best ELSE 0 END)::numeric / 
        NULLIF(SUM(CASE WHEN sex = 'Female' THEN best ELSE 0 END), 0))::numeric, 2
    ) AS male_to_female_ratio
FROM tb_burden_2024_engineered
WHERE sex IN ('Male', 'Female')
  AND age_group IN ('15-24', '25-34', '35-44', '45-54', '55-64', '65plus')
  AND risk_factor = 'all'
GROUP BY age_group
ORDER BY age_group;

--Adult Male Disparity: While pediatric age groups exhibit relative parity (~1.00 to 1.08 male-to-female ratio), 
--adult brackets reveal a progressive increase in male burden.

--===============================
--Risk Factor Attribution EDA
--===============================
--Goal: Rank leading comorbidity drivers across reporting nations (hiv, und, smk, alc, dia).
--SQL Techniques: Multi-metric grouping, relative percentage share.

-- Risk Factor Burden & Reporting Penetration
SELECT 
    risk_factor,
    COUNT(DISTINCT iso3) AS reporting_countries,
    ROUND(SUM(best)::numeric, 0) AS total_attributable_cases,
    ROUND(AVG(best)::numeric, 0) AS avg_cases_per_country
FROM tb_burden_2024_engineered
WHERE risk_factor != 'all'
GROUP BY risk_factor
ORDER BY total_attributable_cases DESC;

--Leading Comorbidity: Undernutrition (und) leads both in total attributable cases (~960k) 
--and reporting country count (177), closely followed by Diabetes (dia) (~919k).
--Behavioral & Clinical Drivers: Alcohol use disorders (alc), smoking (smk), and HIV
--(hiv) make up the remaining major risk categories, with HIV showing the lowest average
--cases per country among the group (3,463), reflecting the concentration of HIV-associated TB in specific
--geographic sub-regions (like Sub-Saharan Africa).

--==================================-=
--Kenya & East Africa Focus EDA
--=====================================
--Goal: Compare Kenya's incidence profile against regional East African peers.
--SQL Techniques: Filtering by east_africa_flag = 1, comparative ranking.

-- East Africa Regional Comparison & Kenya Benchmark
SELECT 
    country,
    total_cases,
    lower_bound,
    upper_bound,
    ci_relative_width AS uncertainty_pct,
    RANK() OVER (ORDER BY total_cases DESC) AS regional_rank
FROM vw_tb_country_totals
WHERE east_africa_flag = 1
ORDER BY total_cases DESC;

--1.Kenya's Regional Rank: Kenya ranks 3 in East Africa with an estimated 117,000 cases,
-- positioned right behind Tanzania (2, 118,000 cases) and Ethiopia (1, 186,000 cases).

--2.Uncertainty & Surveillance Audit:

--Highest Precision: Smaller nations like Eritrea (36.59%) and Djibouti (37.93%), along
--with Rwanda (68.18%), show much tighter confidence interval relative widths, signaling
--higher estimation stability.

--Higher Variance: Tanzania (150.85%), Somalia (147.24%), and South Sudan (126.32%) show wide
--confidence intervals, pointing to higher measurement uncertainty or surveillance gaps in those regions.

--Kenya Baseline: Kenya's uncertainty sits at 111.11% ($\text{CI Range}: 52,000 - 182,000$),
-- reflecting moderate confidence bounds consistent with large mixed urban/rural surveillance sampling.

--======================================
--5. Uncertainty & Data Quality Audit
--======================================
--Goal: Evaluate surveillance confidence intervals across World Bank income classifications.
--SQL Techniques: Standard deviation, average interval spread.

---- Quality Audit: Surveillance Precision by Income Level
SELECT 
    income_group,
    COUNT(DISTINCT iso3) AS country_count,
    ROUND(AVG(total_cases)::numeric, 0) AS mean_cases,
    ROUND(AVG(ci_width)::numeric, 0) AS avg_ci_width,
    ROUND(AVG(ci_relative_width)::numeric, 2) AS avg_uncertainty_pct
FROM vw_tb_country_totals
GROUP BY income_group
ORDER BY avg_uncertainty_pct DESC;
    income_group,
    COUNT(DISTINCT iso3) AS country_count,
    ROUND(AVG(total_cases)::numeric, 0) AS mean_cases,
    ROUND(AVG(ci_width)::numeric, 0) AS avg_ci_width,
    ROUND(AVG(ci_relative_width)::numeric, 2) AS avg_uncertainty_pct
FROM vw_tb_country_totals
GROUP BY income_group
ORDER BY avg_uncertainty_pct DESC;

--1. Inverse Income-Uncertainty Relationship: There is a clear, monotonic trend where relative 
--uncertainty scales inversely with income level:
--Low Income: Highest uncertainty (112.38% average relative width)
--Lower-Middle Income: 77.71%
--Upper-Middle Income: 65.40%
--High Income: Lowest uncertainty (25.06% average relative width)

--2. Surveillance Capacity Impact: High-income nations have national reporting infrastructures
--capable of producing tightly bounded point estimates ($\pm 25\%$), whereas low-income economies
--face wider estimation intervals ($\pm 112\%$) due to reliance on spatial modeling and 
--sample-based surveillance surveys.

--3. Data Completeness Alert (Unknown Group): The presence of 150 countries mapped to 
--"Unknown" income status indicates that metadata enrichment from external sources 
--(e.g., World Bank income tables) covers a subset of key target countries
--(e.g., the 32 core HBC/focus countries), leaving non-target or territory records unmapped.

--=======================================
--Regional Summary & Global Baseline EDA
--=======================================
--Goal: Summarize regional totals and high-burden country (HBC) flags.
--SQL Techniques: Rollup totals, conditional counts.

-- WHO Regional Aggregations
SELECT 
    who_region,
    COUNT(DISTINCT iso3) AS total_countries,
    SUM(high_burden_flag) AS high_burden_countries,
    ROUND(SUM(total_cases)::numeric, 0) AS total_cases,
    ROUND(AVG(ci_relative_width)::numeric, 2) AS avg_uncertainty_pct
FROM vw_tb_country_totals
GROUP BY who_region
ORDER BY total_cases DESC;

--The top three regions (SEARO, AFRO, and WPRO) collectively account for over 8.6 million 
--cases, representing more than 80% of total global TB incidence.
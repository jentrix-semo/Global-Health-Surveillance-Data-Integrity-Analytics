# Global Health Surveillance & Data Integrity Analytics
### End-to-End WHO Tuberculosis Epidemiological Modeling & Power BI Executive Dashboard

![Python](https://img.shields.io/badge/Python-pandas%20%7C%20numpy%20%7C%20scipy-3776AB)
![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-336791)
![Power BI](https://img.shields.io/badge/Dashboard-Power%20BI-F2C811)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Project Overview

This project delivers an end-to-end global health data analytics pipeline analyzing **10.6 million estimated tuberculosis cases** across **215 countries and territories**, based on surveillance data from the **World Health Organization (WHO)**. The analysis moves from raw epidemiological data through professional-grade profiling, cleaning, feature engineering, statistical validation, and PostgreSQL database modeling to a 3-page interactive executive Power BI dashboard.

The project was built to demonstrate analytical thinking, statistical validation, SQL engineering, and executive dashboard design for decision-making in **NGO, global health, and health informatics** environments.

---

---

### 🖼️ Dashboard Overview & Interface

#### Page 1: Executive Summary & Regional Focus
![Global Executive Summary](dashboard/page1_executive_summary.png)

#### Page 2: Demographic Distribution & Data Integrity Audit
![Demographic Distribution and Data Integrity](dashboard/page2_demographic_integrity.png)

#### Page 3: Strategic Decision Brief (Executive Roadmap)
![Strategic Decision Brief](dashboard/page3_decision_brief.png)

---


## Table of Contents

- [Analytical Questions](#analytical-questions)
- [Dataset](#dataset)
- [Tool Stack and Responsibilities](#tool-stack-and-responsibilities)
- [Pipeline Architecture](#pipeline-architecture)
- [Key Findings](#key-findings)
- [Statistical Validation Summary](#statistical-validation-summary)
- [Recommendations](#recommendations)
- [Project Structure](#project-structure)
- [Data Cleaning & Feature Engineering Decisions](#data-cleaning--feature-engineering-decisions)
- [Analytical Views (PostgreSQL)](#analytical-views-postgresql)
- [Dashboard Pages](#dashboard-pages)
- [Limitations](#limitations)
- [How to Reproduce](#how-to-reproduce)
- [Author](#author)
- [License](#license)

---

## Analytical Questions

This project was designed to answer ten specific epidemiological and operational questions:

| # | Question |
|---|----------|
| Q1 | What is the total estimated global case burden, and how many countries are evaluated? |
| Q2 | Which WHO regions bear the majority of the global disease burden? |
| Q3 | Which non-TB comorbidity drivers (undernutrition, diabetes, HIV, alcohol, smoking) contribute most to attributable cases? |
| Q4 | How does Kenya's epidemiological burden compare against its peer nations in the East African Community (EAC)? |
| Q5 | Which specific age bands and gender groups carry the highest disease incidence? |
| Q6 | Is there a statistically significant disparity in case volume between males and females across adult age brackets? |
| Q7 | What is the global baseline margin of reporting uncertainty across surveillance data? |
| Q8 | How does reporting uncertainty vary across World Bank country income classifications? |
| Q9 | Which income tier presents the highest operational risk for supply chain forecasting due to wide confidence interval bounds? |
| Q10 | What concrete short-, medium-, and long-term policy interventions should global health leadership execute based on these findings? |

---

## Dataset

| Attribute | Detail |
|---|---|
| **Source** | World Health Organization (WHO) Global Tuberculosis Programme |
| **Dataset** | Global Tuberculosis Surveillance & Country Burden Estimates |
| **Scope** | 215 countries & territories · 200+ surveillance features · 6 WHO Regions |
| **Target Variables** | Estimated incidence (`e_inc_num`), Low/High confidence bounds (`e_inc_num_lo`, `e_inc_num_hi`), Risk factors (`e_inc_tb_tbhiv`, `e_inc_tb_nut`, `e_inc_tb_dia`, etc.) |
| **Download** | [WHO Global Tuberculosis Report Data](https://www.who.int/teams/global-tuberculosis-programme/data) |

---

## Tool Stack and Responsibilities

| Tool | Role | Why |
|---|---|---|
| **Python** (pandas, numpy, scipy) | Profiling, cleaning, feature engineering, statistical validation, visualization | Data cleaning, relative uncertainty calculation, and hypothesis testing |
| **PostgreSQL** | Analytical views, aggregations, data quality audits | Production-grade data modeling and optimized query performance for Power BI |
| **Power BI** | Executive 3-page dashboard | Dynamic DAX measures, executive dark/slate theme, and interactive decision support |
| **Jupyter Notebook** | Development environment | End-to-end, 7-step reproducible data science workflow |

---

## Pipeline Architecture

```text
RAW TABLE (PostgreSQL: tb_raw_data — original WHO surveillance records)
    │
    ▼  Python: profile → clean → engineer features → validate → export
    │
CLEAN TABLE (PostgreSQL: tb_data_clean)
    │
    ├── Jupyter Notebooks (00_setup to 06_python_visualization)
    ├── Python statistical validation (scipy.stats: Chi-Square, Mann-Whitney U)
    │
    ▼  SQL: Analytical views (CREATE VIEW)
    │
ANALYTICAL VIEWS (vw_pbi_global_kpis, vw_pbi_data_quality_audit)
    │
    ▼  Power BI Import / DirectQuery → 3-page interactive dashboard
```

---

## Key Findings

### Global Burden & Regional Concentration
- **Total Global Cases:** 10.6 million estimated cases across 182 fully evaluated high-burden and reporting nations (215 total territories).
- **High Burden Concentration:** Over 60% of all global cases are concentrated in just two WHO regions — **SEARO** (South-East Asia, ~4.6M cases) and **AFRO** (Africa, ~2.2M cases).
- **High Burden Nations:** 29 countries account for the vast majority of global transmission.

### Comorbidity Risk Attribution
- **Primary Risk Driver:** Undernutrition is the single largest comorbidity driver (~0.96M attributable cases), surpassing Diabetes Mellitus (~0.92M), Alcohol Use Disorder (~0.73M), Smoking (~0.68M), and HIV Co-infection (~0.57M).
- **Clinical Insight:** Nutritional support co-located with diagnostic testing represents a higher-leverage intervention than single-disease management.

### East African Community (EAC) Spotlight
- **Kenya Ranking:** Kenya ranks #3 in the EAC (~117k cases), behind Ethiopia (~190k) and Tanzania (~120k).
- **Data Reliability:** Kenya demonstrates significantly lower relative reporting uncertainty compared to regional neighbors like South Sudan and Somalia, making its surveillance data a reliable baseline for cross-border policy.

### Demographic Vulnerability & Gender Disparity
- **Peak Incidence:** Transmission heavily peaks among working-age adults (25–54), posing a direct threat to economic productivity in developing nations.
- **Gender Disparity:** Male case volume consistently outpaces female case volume across every adult age bracket, reaching a male-to-female ratio of nearly **1.6:1** in core working-age groups.

### Data Quality & Surveillance Uncertainty Audit
- **Overall Uncertainty:** Global average relative uncertainty bound sits at **63.3%**.
- **Income Tier Risk:** Low-income nations bear a mean relative uncertainty of **112.4%**, with upper confidence bounds exceeding the estimated mean cases.
- **Supply Chain Impact:** Wide uncertainty bounds in low-income settings pose extreme financial and stockout risks for drug procurement and diagnostic kit forecasting.

---

## Statistical Validation Summary

| Test | Method | Finding | P-Value | Significant |
|---|---|---|---|---|
| Regional Burden Inequality | Chi-Square Goodness-of-Fit | SEARO/AFRO account for >60% of global burden | < 0.000001 | ✅ Yes |
| Comorbidity Attribution | One-way ANOVA / Kruskal-Wallis | Undernutrition attribution significantly > HIV/Smoking | < 0.000001 | ✅ Yes |
| Male vs. Female Incidence | Mann-Whitney U Test | Adult male case counts significantly exceed female counts | < 0.0001 | ✅ Yes |
| Age Band Distribution | Chi-Square Test | Cases disproportionately concentrated in 25–54 age group | < 0.000001 | ✅ Yes |
| Uncertainty by Income Tier | Kruskal-Wallis Test | Low-income uncertainty (112.4%) vs. high-income (25.1%) | < 0.000001 | ✅ Yes |

---

## Recommendations

1. **Targeted Capital Deployment** *(Short-Term, 0–6 Months)* — Pivot international donor funding away from strict per-capita models toward targeted diagnostic supply chain allocation in SEARO and AFRO high-burden clusters.
2. **Integrated Comorbidity Care** *(Medium-Term, 6–18 Months)* — Establish co-located nutritional support units and diabetes screening directly within community-level TB diagnostic and treatment centers.
3. **Male-Focused Workplace Interventions** *(Medium-Term, 6–18 Months)* — Launch targeted occupational health screening programs tailored to high-risk, male-dominated industries (e.g., mining, transport, agriculture).
4. **Surveillance Infrastructure Investments** *(Long-Term, 18+ Months)* — Allocate health systems strengthening funds toward digital surveillance and laboratory upgrades in low-income countries to reduce reporting margin of error below 30%.
5. **EAC Cross-Border Policy Harmonization** *(Long-Term, 18+ Months)* — Implement standardized cross-border screening and data-sharing protocols along trade corridors shared by Kenya, Tanzania, and Uganda.

---

## Project Structure

```text
who-tb-surveillance-analytics/
│
├── config.py                          ← Central configuration (paths, database settings, global parameters)
├── project_brief.md                   ← Analytical scope, business questions, and target deliverables
│
├── notebooks/
│   ├── 00_setup.ipynb                  ← Environment setup, dependencies, & PostgreSQL connection
│   ├── 01_data_profiling.ipynb         ← Structural audit, null checks, cardinality, & sentinel detection
│   ├── 02_data_cleaning.ipynb          ← Missing value imputation, data type casting, & deduplication
│   ├── 03_feature_engineering.ipynb    ← Calculation of CI widths, uncertainty %, and age/income groupings
│   ├── 04_eda_analysis.ipynb           ← Exploratory data analysis across regions, comorbidities, & EAC
│   ├── 05_statistical_validation.ipynb ← Hypothesis testing (Chi-square, Mann-Whitney U, Kruskal-Wallis)
│   └── 06_python_visualization.ipynb   ← Exploratory plots (Seaborn/Plotly distributions & heatmaps)
│
├── sql/
│   ├── 01_schema_setup.sql             ← DDL for raw WHO surveillance tables
│   ├── 02_vw_pbi_global_kpis.sql       ← SQL view for top-level KPI metrics
│   └── 03_vw_data_quality_audit.sql    ← SQL view for country income group uncertainty audit
│
├── dax/
│   └── dax_measures.dax                ← Dynamic measures for KPI cards and percentage formatting
│
├── outputs/
│   ├── profile_reports/                ← Data profiling CSV exports
│   └── charts/                         ← Matplotlib/Seaborn static chart exports
│
├── dashboard/
│   ├── tuberculosis_project.pbix ← 3-page interactive Power BI dashboard
│   ├── page1_executive_summary.png     ← Screenshot of Page 1
│   ├── page2_demographic_integrity.png ← Screenshot of Page 2
│   └── page3_decision_brief.png        ← Screenshot of Page 3
│
├── .env                                ← Database credentials file (git-ignored)
├── .gitignore
└── README.md                           ← Main project documentation
```

---

## Data Cleaning & Feature Engineering Decisions

| Issue / Feature | Column(s) | Strategy / Definition | Clinical & Operational Reason |
|---|---|---|---|
| Missing Confidence Bounds | `e_inc_num_lo`, `e_inc_num_hi` | Imputed using regional median uncertainty ratio | Preserves sample size for global spatial calculations without distorting variance |
| Income Group Nulls | `income_group` | Categorized as `"Unknown"` | Avoids discarding reporting territories with unclassified economic status |
| CI Width | `ci_width` | `e_inc_num_hi - e_inc_num_lo` | Absolute span of measurement uncertainty around case estimates |
| Relative Uncertainty % | `avg_uncertainty_pct` | `(ci_width / e_inc_num) * 100` | Normalizes uncertainty against case volume to evaluate surveillance accuracy across country tiers |
| EAC Flag | `is_eac_member` | `1` if ISO3 in `(KEN, TZA, UGA, ETH, RWA, BDI, SSD, SOM, DJI, ERI)` | Enables fast filtered queries and spotlight visuals for East Africa benchmarking |

---

## Analytical Views (PostgreSQL)

| View Name | Primary Business Purpose | Output Granularity |
|---|---|---|
| `vw_pbi_global_kpis` | Powers Page 1 top KPI cards (Total Cases, Countries Evaluated, High Burden Count, Avg Uncertainty) | 1 summary row |
| `vw_pbi_data_quality_audit` | Powers Page 2 matrix table (mean cases, CI width, and uncertainty % by World Bank income tier) | 5 income tier rows |
| `vw_eac_regional_benchmark` | Powers Page 1 EAC spotlight visual comparing East African nations against Kenya | 10 country rows |

---

## Dashboard Pages

| Page | Key Visuals | Primary Business Finding |
|---|---|---|
| **Page 1: Global Executive Summary & Regional Focus** | 4 KPI cards + regional burden bar + comorbidity attribution bar + EAC spotlight bar | Over 60% of cases reside in SEARO/AFRO; undernutrition is the #1 comorbidity driver; Kenya ranks #3 in EAC (~117k cases) |
| **Page 2: Demographic Distribution & Data Integrity** | Age-sex tornado pyramid + data quality audit matrix table with heatmap | Working-age males (25–54) bear the highest burden; low-income nations face 112.4% relative uncertainty, creating severe supply chain forecast risks |
| **Page 3: Strategic Decision Brief** | Executive action roadmap + risk matrix + prioritized policy framework | Synthesizes technical data into 0–6 month, 6–18 month, and 18+ month actionable investment roadmaps for leadership |

---

## Limitations

- **Observational Data:** Findings reflect statistical associations and population-level estimates, not direct individual-level causal pathways.
- **Surveillance Gaps:** Low-income settings rely on mathematical model estimations due to missing laboratory diagnostic infrastructure, driving relative uncertainty above 100%.
- **Comorbidity Overlap:** Comorbidity estimates (e.g., undernutrition and diabetes) are evaluated independently within WHO reported estimates and may share overlapping patient populations.
- **Reporting Delays:** Annual surveillance reporting relies on national health ministry submissions, creating inherent lagging indicators compared to real-time clinical data.

---

## How to Reproduce

### Prerequisites

```bash
pip install pandas numpy sqlalchemy psycopg2-binary scipy matplotlib seaborn python-dotenv
```

### Database Setup

1. Download official WHO Global Tuberculosis datasets from the [WHO data portal](https://www.who.int/teams/global-tuberculosis-programme/data).
2. Create a database in PostgreSQL: `tuberculosis_db`.
3. Create table before loading importing the CSV file into postgreSQL.
4. Import raw CSV files into PostgreSQL via the pgAdmin GUI.

### Pipeline Execution

1. Run Jupyter notebooks in sequential order:

   `00_setup.ipynb` → `01_data_profiling.ipynb` → `02_data_cleaning.ipynb` → `03_feature_engineering.ipynb` → `04_eda_analysis.ipynb` → `05_statistical_validation.ipynb` → `06_python_visualization.ipynb`

2. Execute SQL views:

   Run `sql/02_vw_pbi_global_kpis.sql` and `sql/03_vw_data_quality_audit.sql` in PostgreSQL.

3. Connect Power BI:

   Open `dashboard/tuberculosis project.pbix` in Power BI Desktop, then update database credentials under **Transform Data → Data Source Settings** to point to your local PostgreSQL instance.

---

## Author

**Jentrix Semo**
Public Health Professional | Healthcare Data Analyst

Specializing in health informatics, SQL/Python pipeline engineering, and executive BI solutions for global health organizations and NGOs.

---

## License

This project utilizes publicly available epidemiological surveillance data provided by the World Health Organization (WHO). All code, SQL scripts, DAX measures, and documentation in this repository are published under the [MIT License](LICENSE).

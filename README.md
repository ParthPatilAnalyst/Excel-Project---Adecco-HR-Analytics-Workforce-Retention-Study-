# 🧑‍💼 HR Employee Attrition — End-to-End Data Analysis

![Python](https://img.shields.io/badge/Python-3.10%2B-blue?logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0%2B-orange?logo=mysql&logoColor=white)
![Jupyter](https://img.shields.io/badge/Jupyter-Notebook-F37626?logo=jupyter&logoColor=white)
![scikit-learn](https://img.shields.io/badge/scikit--learn-1.3%2B-F7931E?logo=scikit-learn&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

> A production-grade HR analytics project analyzing **1,470 employees × 35 features** to uncover attrition drivers, build predictive models, and deliver executive-ready insights — using Python (Jupyter) and MySQL.

---

## 📋 Table of Contents

- [Situation](#-situation)
- [Task](#-task)
- [Action](#-action)
- [Result](#-result)
- [Project Structure](#-project-structure)
- [Tech Stack](#-tech-stack)
- [Quick Start](#-quick-start)
- [Key Visualizations](#-key-visualizations)
- [Dataset](#-dataset)
- [Recommendations](#-recommendations)
- [Author](#-author)

---

## ⚙️ Situation

**TechSolutions Inc.**, a mid-sized technology company, was facing a growing people management crisis:

- **16.1% overall attrition rate** — well above the industry benchmark of 10–12%
- HR leadership had **no data-driven visibility** into why employees were leaving
- People decisions were being made on gut feel — with no early-warning system for flight risks
- The cost of replacing a single employee ranges from **50% to 200% of annual salary**, making unmanaged attrition a direct bottom-line threat

The business needed answers fast: *Who is leaving? Why? And who is about to leave next?*

---

## 🎯 Task

As the **lead data analyst**, the objective was to:

1. **Audit and validate** the HR dataset for quality and completeness
2. **Identify the root causes** of attrition across departments, roles, and demographics
3. **Quantify the impact** of compensation, satisfaction, overtime, and career progression on turnover
4. **Build a predictive model** to score every active employee's attrition risk
5. **Deliver an executive dashboard** with prioritized, actionable recommendations

The entire analysis had to be reproducible, version-controlled, and usable by both the data team (Python/Jupyter) and the HR operations team (MySQL/BI tools).

---

## 🔧 Action

The project was executed across **10 structured analytical phases**, combining Python and SQL:

### Phase 1 — Data Quality Assessment
- Detected and removed **3 constant/zero-variance columns** (`EmployeeCount`, `Over18`, `StandardHours`)
- Confirmed **zero missing values** across all 35 features
- Validated numeric ranges and categorical value distributions

### Phase 2 — Exploratory Data Analysis (EDA)
- Generated distribution plots for Age, MonthlyIncome, and YearsAtCompany segmented by attrition
- Built a **full 32×32 correlation heatmap** to surface multicollinearity and attrition signals
- Identified top correlated features: `OverTime`, `MonthlyIncome`, `StockOptionLevel`, `JobInvolvement`

### Phase 3 — Attrition Deep-Dive
- Sliced attrition rates across **9 dimensions**: Department, JobRole, OverTime, BusinessTravel, MaritalStatus, JobLevel, StockOptionLevel, Gender, and EducationField
- Built a Department × Overtime heatmap revealing compounding risk factors
- Identified **Sales Representatives at ~40% attrition** — the highest of any role

### Phase 4 — Compensation Analysis
- Conducted income quartile analysis: bottom 25% earners leave at **3× the rate** of top earners
- Built a gender pay proxy breakdown by department and job role
- Correlated salary hike percentage with performance ratings and attrition

### Phase 5 — Satisfaction & Engagement Scoring
- Analysed all 5 engagement dimensions: JobSatisfaction, EnvironmentSatisfaction, RelationshipSatisfaction, WorkLifeBalance, JobInvolvement
- Found employees scoring ≤ 2 on JobSatisfaction have **2.4× higher attrition** than those scoring 4

### Phase 6 — Tenure & Career Progression
- Mapped attrition across tenure bands — **first 3 years are the critical window**
- Showed promotion stagnation (≥5 years without promotion) drives material attrition uplift
- Revealed employees with **0 training sessions** leave at nearly double the rate of those trained 3+ times

### Phase 7 — Predictive Modelling
Trained and cross-validated three models using `StratifiedKFold (k=5)`:

| Model | CV AUC | Test AUC |
|---|---|---|
| Logistic Regression | 0.82 ± 0.03 | 0.83 |
| **Random Forest** | **0.85 ± 0.02** | **0.85** |
| Gradient Boosting | 0.84 ± 0.02 | 0.84 |

Used `class_weight="balanced"` to handle the **84:16 class imbalance**.

### Phase 8 — Feature Importance & Risk Scoring
- Extracted Random Forest feature importances and Logistic Regression coefficients
- Built a **7-flag composite risk score** per employee (OverTime + Low Satisfaction + No Stock Options + Promotion Stagnation + etc.)
- Scored all 1,470 employees into 5 risk bands: Very Low → Very High

### Phase 9 — MySQL Analysis (40+ queries)
- Full DDL with proper types, ENUMs, and indexes
- Window functions: `RANK()`, `PERCENT_RANK()`, `NTILE()`, cumulative attrition
- CTEs for cohort retention analysis and multi-factor risk segmentation
- Stored procedure `sp_attrition_report(department)` for HR ops team
- Two BI-ready views: `vw_attrition_summary` and `vw_high_risk_employees`

### Phase 10 — Executive Dashboard
- 5-KPI summary card layout rendered in Matplotlib
- Department health scorecard combining attrition rate, satisfaction, OT exposure
- Immediate action list: active employees flagged for retention intervention

---

## 📊 Result

| KPI | Value |
|---|---|
| Overall Attrition Rate | **16.1%** |
| Highest Risk Role | **Sales Representative (~40%)** |
| Overtime Attrition Rate | **30.5%** vs 10.4% (no OT) |
| Bottom Income Quartile Attrition | **~3× higher** than top quartile |
| Employees with No Stock Options Leaving | **Significantly higher** than option holders |
| Best Predictive Model | **Random Forest — AUC 0.85** |
| High / Very High Risk Employees Identified | **~18% of workforce** flagged for intervention |
| SQL Queries Delivered | **40+ analytical queries** |
| Charts Generated | **15 production-quality figures** |

### Top 8 Actionable Findings

| # | Finding | Priority | Recommendation |
|---|---------|----------|----------------|
| 1 | Overtime is the #1 attrition driver | 🔴 High | Enforce OT caps; add headcount in bottleneck teams |
| 2 | Sales Reps attrition ~40% | 🔴 High | Redesign comp + junior mentoring programmes |
| 3 | Bottom income quartile leaves at 3× rate | 🔴 High | Salary benchmarking; fix below-market bands |
| 4 | Single employees + frequent travel = elevated risk | 🟠 Medium | Remote/flexible options; reduce travel requirements |
| 5 | Job satisfaction ≤ 2 → 2.4× higher attrition | 🟠 Medium | Quarterly pulse surveys + manager coaching |
| 6 | First 3 years are the critical attrition window | 🟠 Medium | Structured 90-day & 1-year onboarding + mentoring |
| 7 | No stock options = strong attrition predictor | 🟠 Medium | Extend ESOP eligibility; tie vesting to 3-year tenure |
| 8 | Low training frequency linked to higher attrition | 🟡 Low-Med | Mandate ≥3 training events/year; invest in L&D budget |

---

## 📁 Project Structure

```
hr-attrition-analysis/
│
├── data/
│   └── WA_Fn-UseC_-HR-Employee-Attrition.csv   # Source dataset (IBM Watson)
│
├── notebooks/
│   └── HR_Attrition_Analysis.ipynb              # Full Jupyter notebook (executed)
│
├── sql/
│   └── HR_Attrition_Analysis.sql                # MySQL DDL + 40+ analytical queries
│
├── figures/                                     # Auto-generated by notebook
│   ├── fig_01_attrition_overview.png
│   ├── fig_02_distributions.png
│   ├── fig_03_correlation_heatmap.png
│   ├── fig_04_attrition_dept_role.png
│   ├── fig_05_attrition_categorical.png
│   ├── fig_06_overtime_heatmap.png
│   ├── fig_07_salary_analysis.png
│   ├── fig_08_hike_income.png
│   ├── fig_09_satisfaction.png
│   ├── fig_10_tenure_promotion.png
│   ├── fig_11_training_companies.png
│   ├── fig_12_roc_cm.png
│   ├── fig_13_feature_importance.png
│   ├── fig_14_risk_scores.png
│   └── fig_15_kpi_dashboard.png
│
└── README.md
```

---

## 🛠️ Tech Stack

| Layer | Tool / Library |
|---|---|
| Language | Python 3.10+, SQL (MySQL 8.0+) |
| Notebook | Jupyter Notebook / JupyterLab |
| Data Manipulation | pandas, numpy |
| Visualisation | matplotlib, seaborn |
| Machine Learning | scikit-learn (LR, RF, GBM) |
| SQL Features | CTEs, Window Functions, Stored Procedures, Views |
| Version Control | Git / GitHub |

---

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/yourusername/hr-attrition-analysis.git
cd hr-attrition-analysis
```

### 2. Install Python dependencies
```bash
pip install pandas numpy matplotlib seaborn scikit-learn jupyter
```

### 3. Launch the notebook
```bash
jupyter notebook notebooks/HR_Attrition_Analysis.ipynb
```

### 4. Set up MySQL
```bash
# Connect to MySQL and run the SQL script
mysql -u root -p < sql/HR_Attrition_Analysis.sql
```

> **Note:** Update the dataset path inside the notebook if your CSV is in a different location.  
> The notebook expects `WA_Fn-UseC_-HR-Employee-Attrition.csv` in the working directory.

---

## 📈 Key Visualizations

| Figure | Description |
|---|---|
| `fig_01` | Attrition class balance — pie + bar |
| `fig_03` | Full correlation heatmap (32×32) |
| `fig_04` | Attrition rate by Department & Job Role |
| `fig_05` | Attrition across 5 categorical features |
| `fig_06` | Department × Overtime attrition heatmap |
| `fig_09` | All 5 satisfaction scores vs attrition |
| `fig_12` | ROC curves (3 models) + Confusion matrix |
| `fig_13` | RF feature importances + LR coefficients |
| `fig_14` | Workforce risk band distribution |
| `fig_15` | Executive KPI dashboard |

---

## 📂 Dataset

**IBM Watson HR Analytics Employee Attrition & Performance**

| Property | Value |
|---|---|
| Source | [Kaggle — IBM HR Analytics](https://www.kaggle.com/datasets/pavansubhasht/ibm-hr-analytics-attrition-dataset) |
| Rows | 1,470 employees |
| Features | 35 columns |
| Target | `Attrition` (Yes / No) — 16.1% positive class |
| License | Open / Public domain |

Key features include: Age, Department, JobRole, MonthlyIncome, OverTime, JobSatisfaction, EnvironmentSatisfaction, WorkLifeBalance, YearsAtCompany, YearsSinceLastPromotion, StockOptionLevel, TrainingTimesLastYear, and more.

---

## 💡 Recommendations

Based on this analysis, the three highest-ROI interventions for HR leadership are:

1. **Overtime Policy Reform** — The single biggest lever. Capping overtime and redistributing workload in Sales and R&D could reduce attrition by an estimated 8–10 percentage points in those departments alone.

2. **Compensation Benchmarking** — Bottom-quartile earners are a flight risk. A structured salary review targeting the lowest 25% of earners per role, with adjustments to market rate, directly addresses the income-attrition relationship.

3. **Early-Tenure Engagement Programme** — Since the first 3 years are the highest-risk window, a structured onboarding programme, regular check-ins at 90 days / 6 months / 1 year, and fast-tracked stock option eligibility for new joiners can materially improve retention.

---

## 👤 Author

**PARTH PATIL**  
 

[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-blue?logo=linkedin)](https://linkedin.com/in/yourprofile)
[![GitHub](https://img.shields.io/badge/GitHub-Follow-black?logo=github)](https://github.com/yourusername)
[![Email](https://img.shields.io/badge/Email-Contact-red?logo=gmail)](mailto:your@email.com)

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

*If this project helped you, please consider giving it a ⭐ on GitHub!*

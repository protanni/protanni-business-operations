# PROTANNI — SQL Business-Question Pack

**Status:** Phase 1 validated  
**Dataset:** fully synthetic / modelled portfolio data  
**Validation:** all 30 queries executed successfully against the committed synthetic dataset in an isolated temporary schema; the validation schema was not connected to production tables.

The purpose of this pack is not to demonstrate SQL syntax in isolation. Each query starts from a Business Operations question, produces a reproducible metric, and states how the result would support a decision.

## Query map

| # | Business question | Area | Main SQL concepts |
|---|---|---|---|
| Q01 | Sign-ups by week | Acquisition | DATE_TRUNC, GROUP BY |
| Q02 | Visitor → Sign-up Conversion | Acquisition | FILTER, ratio |
| Q03 | Visitor conversion by channel | Acquisition | GROUP BY, conditional aggregation |
| Q04 | Signup mix by market | Acquisition | Window aggregate |
| Q05 | Onboarding by market | Funnel | FILTER, segmentation |
| Q06 | Largest funnel drop-offs | Funnel | CTE, UNION ALL, LAG |
| Q07 | Overall onboarding completion | Activation | FILTER |
| Q08 | Activation Rate | Activation | CTE, EXISTS |
| Q09 | Time to First Value | Activation | MIN, timestamp difference, percentile |
| Q10 | WAU trend | Engagement | DATE_TRUNC, DISTINCT |
| Q11 | WCVU trend | Engagement | event filters, DISTINCT |
| Q12 | Routine, AI and core-value depth | Engagement | CTE, EXISTS, UNION ALL |
| Q13 | D7 retention by weekly cohort | Retention | cohort logic, EXISTS |
| Q14 | D30 retention by monthly cohort | Retention | cohort logic |
| Q15 | Activation vs D30 | Retention | CTE, segmentation |
| Q16 | Routine Adoption vs D30 | Retention | EXISTS, cohort comparison |
| Q17 | AI Adoption vs D30 | Retention | EXISTS, cohort comparison |
| Q18 | Monthly retention matrix | Cohorts | cohort indexing, date math |
| Q19 | Activated → Trial | Conversion | CTE, ratio |
| Q20 | Trial → Paid | Conversion | conditional DISTINCT |
| Q21 | Active paid subscribers by month | Revenue | GROUP BY |
| Q22 | MRR and New MRR | Revenue | SUM, FILTER |
| Q23 | ARPU | Revenue | SUM / DISTINCT users |
| Q24 | Observed subscriber churn | Revenue | conditional DISTINCT |
| Q25 | Activation by channel | GTM | DISTINCT ON, joins |
| Q26 | Trial/Paid conversion by channel | GTM / RevOps | joins, funnel rates |
| Q27 | D30 by channel | GTM / Retention | attribution + cohort logic |
| Q28 | MRR contribution by channel | GTM / Revenue | window aggregate |
| Q29 | Brazil vs International funnel | Market | multi-stage segmentation |
| Q30 | Revenue mix by plan | Commercial | CTE, window share |

## Files

- [Acquisition & Funnel](./acquisition_funnel.sql) — Q01–Q06
- [Activation & Engagement](./activation_engagement.sql) — Q07–Q12
- [Retention & Cohorts](./retention_cohorts.sql) — Q13–Q18
- [Revenue & Conversion](./revenue_conversion.sql) — Q19–Q24
- [Market & Channel Analysis](./market_channel_analysis.sql) — Q25–Q30

## Selected synthetic findings

These results exist to demonstrate analytical reasoning. They are **not actual PROTANNI performance**.

- Visitor → Sign-up: **26.67%**.
- Onboarding Completion: **82.50%**.
- Activation Rate: **63.75%**.
- Median Time to First Value: **35.00 hours**.
- Routine Adoption among activated users: **64.71%**.
- AI Feature Adoption among activated users: **41.18%**.
- Activated users show **82.35%** synthetic D30 retention vs **6.90%** for non-activated users.
- Trial Start among activated users: **49.02%**.
- Trial → Paid: **48.00%**.
- Synthetic June MRR: **$90**, with **11** active paid subscribers.
- Observed synthetic subscriber churn: **8.33%**.
- Search leads Visitor → Sign-up at **36.00%**, while direct leads activation at **76.92%**.
- International synthetic users outperform Brazil on activation, signup→paid, and D30 in this generated fixture.

## Interpretation rules

1. Synthetic correlations are hypotheses, not causal evidence.
2. Small cohorts should always be read with their cohort size.
3. Synthetic pricing/revenue values are analytical fixtures, not PROTANNI pricing decisions.
4. `market_key`, `acquisition_touches`, `product_events`, and normalized revenue are modelled analytical sources where production instrumentation is currently incomplete.
5. The same queries should be revalidated against production analytical sources only after instrumentation and privacy controls are in place.

## How to run

Load the dataset first:

```sql
\i ../02-data/synthetic-dataset/synthetic_dataset.sql
```

Then run the relevant SQL file. The queries are written for PostgreSQL-compatible SQL.

## What this demonstrates

The pack applies:

- aggregation and conditional aggregation;
- joins and `EXISTS`;
- CTEs;
- window functions (`LAG`, window totals);
- time/date logic;
- cohort analysis;
- percentile logic;
- funnel analysis;
- revenue and retention analysis;
- business interpretation and decision framing.

The next Phase 1 task is the **Phase 1 release**, which links the KPI Framework, Data Dictionary, Analytical Data Model, Synthetic Dataset, SQL Pack, and credentials from the repository homepage.

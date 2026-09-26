# PROTANNI — Business Operations

End-to-end Business Operations system for PROTANNI, covering data, analytics, forecasting, financial planning, GTM, RevOps, automation, project management, and operational excellence.

## Overview

PROTANNI is a **pre-launch product in active development**: a calm personal operating system that brings tasks, routines, daily execution, progress, and AI-supported reflection into one place.

This repository documents the Business Operations infrastructure being built around PROTANNI as a real 0→1 digital product. The production application and source code remain separate and private; this repository contains portfolio-safe operating models, analytical definitions, decision frameworks, and synthetic/anonymized evidence.

## Business Challenge

The core operating question is:

> **Determine how PROTANNI should be measured, operated and prepared for launch using a repeatable Business Operations system.**

The product is more mature than the surrounding operating system. Before launch and scale, PROTANNI needs a consistent foundation for performance management, data governance, analytics, financial planning, GTM/RevOps, initiative governance, automation, and operational improvement.

## Scope

**In scope:** Business context, KPI system, data governance, analytical model, SQL, BI, forecasting, financial modeling, GTM, CRM/RevOps design, automation, project governance, operational excellence, and regional operating-model work.

**Out of scope:** Production feature development, backend refactoring, release engineering, publication of private source code, publication of real user-level data, and presentation of modeled metrics as actual traction.

## Objectives

- Build a clear Business Operations operating model from launch through scale.
- Connect strategy to measurable KPIs, targets, thresholds, owners, and review cadences.
- Create a reproducible analytics foundation for acquisition, activation, engagement, conversion, revenue, and retention.
- Develop forecasting and financial-planning models for business decisions.
- Design GTM and RevOps processes, lifecycle logic, SLAs, and operating cadences.
- Apply automation and AI to reduce manual operational work.
- Document project-management, process-improvement, and regional operating practices.

## Timeline

**Sprint:** 21 Sep–22 Nov 2026  
**Default capacity:** 10–12 hours/week; intensive weeks may reach ~14 hours.

| Phase | Weeks | Focus |
|---|---:|---|
| Data Foundation | 1–2 | Business context, KPI framework, data governance, data model, SQL |
| BI & Modeling | 3–4 | Power BI, forecasting, financial model |
| GTM & RevOps | 5–6 | ICP, launch planning, CRM architecture, lifecycle and pipeline |
| Automation & Execution | 7–8 | Automation, AI workflows, Python, project management, final case study |
| Operations Excellence | 9 | Process improvement, controls, regional operations and readiness |

## Skills Demonstrated

Current and planned evidence in this case includes:

- Business Operations and operating-model design
- KPI / performance-management design
- Project chartering and initiative governance
- Data governance and privacy-by-design
- SQL and analytical data modeling
- Power BI and executive reporting
- Forecasting, budgeting, unit economics, and business cases
- GTM, CRM, Sales/Revenue Operations concepts
- Process improvement, root-cause analysis, and change management
- Automation, APIs/webhooks, applied AI, and Python
- Executive decision support and QBR-style communication

## Repository Structure

- `credentials/` — certificates and verification links
- `01-business-context/` — business context, sprint charter, roadmap, KPI framework
- `02-data/` — data governance, analytical model, synthetic/anonymized datasets
- `03-sql/` — SQL query packs and business interpretations
- `04-bi/` — Power BI methodology, models, measures, and portfolio-safe evidence
- `05-forecasting/` — forecast methodology, assumptions, and outputs
- `06-financial-model/` — operating model, scenarios, and decision memos
- `07-gtm/` — ICP, positioning, channels, funnel, and launch plan
- `08-revops-crm/` — CRM architecture, lifecycle, pipeline, scoring, SLAs, cadence
- `09-automation-ai/` — sanitized automation and AI workflow evidence
- `10-python/` — applied Python scripts, sample data, and outputs
- `11-project-management/` — stakeholder map, risk register, decision log, retrospective
- `12-case-study/` — final executive case study
- `13-operations-excellence/` — process mapping, RCA, improvement, and control plan
- `14-regional-operations/` — regional operating model, readiness/change plan, vendor scorecard

## Privacy & Data Safety

This is a public repository. It must not contain production source code, API keys, tokens, credentials, private endpoints, customer-identifiable data, or confidential business information.

Operational data used in public artifacts will be synthetic, anonymized, aggregated, or intentionally public. User-authored text, sensitive wellness context, billing tokens/provider payloads, and production identifiers are excluded from public evidence.

## Current Progress

### Phase 1 — Data Foundation — Complete

**Release:** Data Foundation v1.0 — 26 Sep 2026

Phase 1 established the measurement and analytics foundation for PROTANNI before launch. The work connects business context, KPI definitions, source-system governance, analytical modeling, privacy-safe synthetic data, and tested SQL analysis into one reproducible operating layer.

#### Phase 1 outcomes

- defined the business context, initiative scope, stakeholders, constraints, and decision questions;
- completed PMI KICKOFF Predictive and applied a Project Charter to the real sprint;
- defined the initial North Star (**Weekly Core Value Users — WCVU**) and executive KPI tree;
- mapped KPI definitions to the live Supabase schema using metadata only, without reading production user records;
- documented source-of-truth, privacy, data-quality, refresh, and synthetic-data rules;
- designed an analytical model supporting acquisition, activation, engagement, conversion, revenue, retention, market, and cohort analysis;
- published a deterministic, fully synthetic dataset with source-compatible and clearly labelled modelled/future analytical sources;
- completed Kaggle Intro to SQL and Advanced SQL;
- built and validated a **30-question SQL Business-Question Pack** spanning funnel, activation, engagement, retention, cohorts, revenue, and market/channel analysis;
- recorded current instrumentation gaps explicitly rather than inventing unavailable production data.

#### Phase 1 evidence

- [Business Context & Scope](./01-business-context/business-model.md)
- [PMI KICKOFF Project Charter](./01-business-context/project-charter.md)
- [KPI Framework](./01-business-context/kpi-framework.md)
- [Data Dictionary & Privacy Rules](./02-data/data-dictionary.md)
- [Analytical Data Model](./02-data/data-model.md)
- [Synthetic Analytical Dataset](./02-data/synthetic-dataset/README.md)
- [SQL Business-Question Pack](./03-sql/README.md)
- [Credentials Register](./credentials/README.md)

#### Analytical validation

All 30 SQL queries were executed successfully against the committed synthetic dataset in an isolated temporary validation schema. The temporary schema was removed after validation.

Selected synthetic results are included only to demonstrate analytical reasoning and decision framing. They are **not actual PROTANNI performance, traction, revenue, retention, pricing, or forecasts**.

Current production-data gaps that remain relevant for later implementation include acquisition attribution, normalized product-event instrumentation, durable Today-path history, onboarding completion timestamps, explicit market geography, AI interaction tracking, and a normalized monetary source for MRR/ARPU.

### Next — Phase 2: BI & Modeling

The next phase turns the Data Foundation into management decision support:

1. PL-300 — Prepare data.
2. PL-300 — Model data.
3. Build Power BI performance-management dashboard v1.
4. Document dashboard decisions and KPI logic.
5. Build driver-based commercial forecast.
6. Build the operating budget / financial model, including contractor and hiring scenarios.
7. Write the executive business case and scenario memo.
8. Publish the Phase 2 release.


---

Built as an applied Business Operations system for PROTANNI.

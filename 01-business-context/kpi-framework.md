# PROTANNI — KPI Framework

**Stage:** Pre-launch product in active development  
**Business model:** Subscription-based B2C SaaS with a planned free trial  
**Market scope:** Brazil + international / English-speaking  
**Framework status:** Initial operating framework — targets and thresholds require post-launch baselines  
**Business Operations owner:** Founder / BizOps

## 1. Purpose

This framework translates PROTANNI's business context into a measurable operating system.

Its purpose is to define:

- what success means;
- which metrics should guide launch and early operating decisions;
- how product value connects to acquisition, activation, engagement, conversion, revenue, and retention;
- which metrics are leading vs. lagging indicators;
- how each KPI should be defined, sourced, owned, reviewed, and acted on;
- how pre-launch assumptions will become validated targets after real data exists.

The framework is intentionally decision-oriented. A metric belongs here only if it helps answer a business question or trigger an operating action.

## 2. Business Objective

The central Business Operations objective is:

> **Determine how PROTANNI should be measured, operated and prepared for launch using a repeatable Business Operations system.**

The KPI framework supports that objective by connecting the product value proposition — helping people turn mental overload into clear daily action — to measurable user and business outcomes.

## 3. Measurement Principles

### 3.1 Measure value, not activity for its own sake

Downloads, sessions, and raw event counts may be useful diagnostic metrics, but they do not automatically represent customer value.

PROTANNI should prioritize measures that show whether users are:

1. reaching initial value;
2. returning to the product;
3. completing meaningful planned actions;
4. building recurring usage;
5. converting when the paid experience is introduced;
6. remaining subscribed over time.

### 3.2 Do not fabricate targets

PROTANNI is pre-launch. Most commercial and behavioral metrics do not yet have a valid empirical baseline.

Targets therefore use three statuses:

- **TBD — Baseline required:** no reliable operating baseline exists yet.
- **Initial hypothesis:** planning assumption only; not treated as validated performance.
- **Validated target:** supported by sufficient real operating evidence.

Numeric targets should not be published as company performance until they are supported by real data.

### 3.3 Separate leading and lagging indicators

Leading indicators help detect problems before they reach revenue or retention.

Examples:
- onboarding completion;
- activation;
- time to first value;
- weekly core-value usage.

Lagging indicators confirm longer-term business outcomes.

Examples:
- paid conversion;
- MRR;
- subscriber retention;
- churn.

### 3.4 Keep the system small enough to operate

The executive KPI set should remain limited. Supporting metrics may exist for diagnosis, but they should not all become management KPIs.

### 3.5 Every KPI needs a decision use

A metric without an owner, review cadence, or action rule is reporting, not performance management.

## 4. North Star Metric

### Weekly Core Value Users (WCVU)

**Definition**

Unique users who complete at least one planned **Task or Routine through Today** during a 7-day period.

**Why this is the initial North Star**

PROTANNI's value proposition is not merely to store tasks or generate plans. The product is intended to help users translate planning into clear daily action.

Completing a planned Task or Routine through Today is therefore the clearest current business-level signal that the product has moved from organization to realized action.

**Formula**

```
WCVU = COUNT(DISTINCT user_id)
where core_value_action = completed
and action_source = Today
within reporting week
```

**Current status**

Initial operating definition. It must be validated after launch to confirm that this event correlates with retention, satisfaction, and paid conversion.

### Supporting depth metric: Core Value Days per WCVU

**Definition**

Average number of distinct days in a week on which a WCVU completes at least one core-value action.

**Purpose**

WCVU answers whether value occurred. Core Value Days helps show how consistently that value occurred.

## 5. KPI Tree

```
PROTANNI Business Objective
│
└── Deliver repeatable customer value and build a sustainable subscription business
    │
    ├── Acquisition
    │   ├── Qualified Visits
    │   ├── New Sign-ups
    │   └── Visitor → Sign-up Conversion
    │
    ├── Activation
    │   ├── Onboarding Completion
    │   ├── Activation Rate
    │   └── Time to First Value
    │
    ├── Engagement
    │   ├── Weekly Core Value Users ← NORTH STAR
    │   ├── Core Value Days per WCVU
    │   ├── WAU
    │   ├── Routine Adoption
    │   └── AI Feature Adoption
    │
    ├── Conversion
    │   ├── Trial Start Rate
    │   └── Trial → Paid Conversion
    │
    ├── Revenue
    │   ├── MRR
    │   ├── New MRR
    │   └── ARPU
    │
    └── Retention
        ├── D7 User Retention
        ├── D30 User Retention
        ├── Paid Subscriber Retention
        └── Subscriber Churn
```

## 6. Activation Definition

### Initial activation event

A new user is considered **activated** when the user:

1. completes onboarding;
2. creates or configures at least one Task or Routine; and
3. completes the first planned Task or Routine through Today.

This definition reflects PROTANNI's intended value loop:

> **Organize → decide what matters today → act.**

The exact event sequence and time window must be validated against real post-launch behavior.

### Time to First Value

The initial definition of first value is the user's first completed planned Task or Routine through Today.

```
Time to First Value =
timestamp(first core-value completion)
-
timestamp(account creation)
```

## 7. Executive KPI Definitions

| KPI | Business question | Definition | Formula | Initial source | Owner | Target | Threshold | Review cadence | Decision / action |
|---|---|---|---|---|---|---|---|---|---|
| New Sign-ups | Are we attracting new users? | New accounts created during the period. | Count of distinct new user IDs | Auth / user registry | Founder / BizOps | TBD — baseline required | Set after launch baseline | Weekly | Compare by source/market; investigate acquisition drops or low-quality traffic. |
| Visitor → Sign-up Conversion | Does acquisition traffic convert into accounts? | Share of qualified product/landing visitors who create an account. | New sign-ups / qualified unique visitors | Landing analytics + auth | Founder / BizOps | TBD — baseline required | Set after launch baseline | Weekly | Review message, channel quality, CTA, or onboarding entry if conversion weakens. |
| Onboarding Completion Rate | Are new users completing setup? | Share of new users who complete the defined onboarding flow. | Users completing onboarding / users starting onboarding | Product events | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Review onboarding friction, step abandonment, or unclear setup requirements. |
| Activation Rate | Are new users reaching first product value? | Share of new users who meet the activation definition. | Activated new users / new users | Product events + auth | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Diagnose onboarding, task/routine creation, Today flow, or time-to-value friction. |
| Time to First Value | How quickly does PROTANNI deliver initial value? | Time between account creation and first core-value completion. | Median first-value timestamp − signup timestamp | Product events + auth | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Reduce setup steps or improve guidance when first value takes too long. |
| Weekly Core Value Users (WCVU) | How many users receive core value each week? | Unique users completing ≥1 planned Task or Routine through Today in the week. | Distinct qualifying users | Product events | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Treat as primary product-value health metric; investigate declines by cohort and behavior. |
| Core Value Days per WCVU | How consistently are users receiving value? | Average number of distinct weekly days with a core-value completion among WCVUs. | Total core-value user-days / WCVU | Product events | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Review whether value is one-off or recurring; diagnose routine/Today adoption. |
| WAU | Is the active user base returning weekly? | Unique users with at least one defined meaningful product session/event during the week. | Distinct weekly active users | Product analytics | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly | Compare WAU with WCVU to detect usage without realized core value. |
| Routine Adoption Rate | Are users using recurring behavior support? | Share of activated users who create and use at least one Routine. | Activated users with routine usage / activated users | Product events | Founder / BizOps | TBD — baseline required | Set after baseline | Weekly / Monthly | Assess whether Routines contribute to sustained engagement and retention. |
| AI Feature Adoption Rate | Are AI-supported experiences useful enough to be used? | Share of active users who use at least one AI-supported mood, daily focus, or reflection experience. | Active users using AI feature / active users | Product events / AI logs | Founder / BizOps | TBD — baseline required | Set after baseline | Monthly | Evaluate feature usefulness, discoverability, cost, and relationship with retention. |
| Trial Start Rate | Are eligible users entering the monetization journey? | Share of eligible users who begin a free trial. | Trial starts / eligible users | Subscription/billing + product events | Founder / BizOps | TBD — launch dependent | Set after trial launch | Weekly | Review paywall placement, value communication, eligibility logic, or offer design. |
| Trial → Paid Conversion | Does the trial convert into paying customers? | Share of completed/eligible trials that become paid subscriptions. | New paid subscriptions from trial / eligible ended trials | Subscription/billing | Founder / BizOps | TBD — baseline required | Set after sufficient trial cohort | Weekly / Monthly | Review trial length, paywall, packaging, value realization, and activation quality. |
| Monthly Recurring Revenue (MRR) | Is recurring subscription revenue growing? | Normalized monthly recurring subscription revenue from active paid users. | Sum of normalized monthly subscription value | Subscription/billing | Founder / BizOps | TBD — financial plan required | Set in financial model | Monthly | Compare actual vs. plan; investigate acquisition, conversion, churn, or pricing effects. |
| New MRR | How much recurring revenue is added from new customers? | MRR added from subscriptions that became paid during the period. | Sum of MRR from new paid subscriptions | Subscription/billing | Founder / BizOps | TBD — financial plan required | Set in financial model | Monthly | Connect revenue growth to acquisition and conversion performance. |
| ARPU | How much recurring revenue is generated per paid user? | Average recurring revenue per active paid subscriber. | MRR / active paid subscribers | Subscription/billing | Founder / BizOps | TBD — pricing required | Set after pricing validation | Monthly | Evaluate packaging/pricing mix and inform unit economics. |
| D7 User Retention | Are new users returning after initial use? | Share of a signup/activation cohort active on the defined Day-7 retention window. | Retained users at D7 / cohort users | Product events + auth | Founder / BizOps | TBD — baseline required | Set after launch baseline | Weekly cohort review | Diagnose activation quality and early product-value gaps. |
| D30 User Retention | Does product value persist beyond initial novelty? | Share of a signup/activation cohort retained at Day 30. | Retained users at D30 / cohort users | Product events + auth | Founder / BizOps | TBD — baseline required | Set after sufficient cohort maturity | Monthly cohort review | Guide product/engagement priorities and identify long-term value gaps. |
| Paid Subscriber Retention | Are paid users remaining subscribed? | Share of paid subscribers retained from the beginning to the end of a period/cohort window. | Retained paid subscribers / starting paid subscribers | Subscription/billing | Founder / BizOps | TBD — baseline required | Set after paid cohort maturity | Monthly | Evaluate customer value, monetization fit, and churn risk. |
| Subscriber Churn Rate | How much of the paid base is being lost? | Share of starting paid subscribers who cancel during the period. | Churned paid subscribers / starting paid subscribers | Subscription/billing | Founder / BizOps | TBD — baseline required | Set after paid cohort maturity | Monthly | Trigger cancellation-reason analysis and retention actions. |

## 8. Supporting Diagnostic Metrics

These metrics are useful for analysis but should not automatically become executive KPIs.

### Acquisition diagnostics
- visits by channel;
- sign-ups by country/language;
- sign-ups by acquisition source;
- landing-page conversion by source.

### Activation diagnostics
- onboarding step completion;
- task creation rate;
- routine creation rate;
- first Today visit;
- first core-value completion by cohort;
- activation by market/language.

### Engagement diagnostics
- Today usage frequency;
- task completion volume;
- routine completion volume;
- Progress usage;
- mood usage;
- daily focus usage;
- reflection usage;
- AI usage frequency.

### Monetization diagnostics
- paywall view rate;
- trial eligibility;
- trial cancellation timing;
- paid conversion by activation status;
- paid conversion by market/language.

### Retention diagnostics
- retention by signup cohort;
- retention by activation status;
- retention by feature adoption;
- retention by market/language;
- WCVU retention over time.

## 9. Leading vs. Lagging Indicators

| Type | Metrics | Why they matter |
|---|---|---|
| Leading | Onboarding Completion, Activation Rate, Time to First Value, WCVU, Core Value Days, Routine Adoption | Show whether users are reaching and repeating product value before commercial outcomes fully appear. |
| Intermediate | WAU, Trial Start Rate, AI Feature Adoption | Show broader product usage and movement toward monetization, but require interpretation alongside core-value metrics. |
| Lagging | Trial → Paid Conversion, MRR, New MRR, ARPU, D30 Retention, Paid Retention, Churn | Confirm whether product value translates into sustainable commercial outcomes. |

## 10. Target & Threshold Policy

Because PROTANNI is pre-launch, this framework does not fabricate numeric performance targets.

### Phase 1 — Baseline

After launch, collect enough real data to establish a usable baseline for each KPI.

### Phase 2 — Initial operating target

Set an initial target using:

- actual baseline;
- cohort maturity;
- business model and financial plan;
- market/channel context;
- product constraints.

### Phase 3 — Validated target

A target becomes **validated** only after repeated operating evidence shows that it is useful for planning and decision-making.

### Traffic-light logic

Once numeric targets exist:

- **Green:** at or above validated target;
- **Watch:** below target but above the intervention threshold;
- **Action:** at or below the intervention threshold.

Until then, the KPI should be labeled **TBD — Baseline required**, not assigned an arbitrary number.

## 11. KPI Ownership

PROTANNI is founder-led. During the current sprint, the **Founder / BizOps owner** is the accountable owner for the executive KPI system.

Operationally:

- Business Operations defines metric logic, review cadence, targets, and decisions.
- Product/engineering instrumentation provides the event data required to calculate product KPIs.
- Billing/subscription systems provide monetization and revenue data.
- GTM systems provide acquisition-source and campaign context when those processes are implemented.

Ownership should be reassigned as the operating team grows.

## 12. Review Cadence

### Weekly Business Review (WBR)

Primary purpose: detect operating changes early and assign actions.

Review:

1. New Sign-ups
2. Visitor → Sign-up Conversion
3. Onboarding Completion
4. Activation Rate
5. Time to First Value
6. WCVU
7. Core Value Days per WCVU
8. WAU
9. Trial Start / Trial → Paid when monetization is live
10. Major anomalies, decisions, owners, and follow-ups

Recommended output:

```
Metric → Current → Baseline/Target → Status → Why → Action → Owner → Due Date
```

### Monthly Business Review

Primary purpose: understand trends and commercial health.

Review:

- acquisition and activation trends;
- engagement and core-value cohorts;
- D7 / D30 retention;
- conversion;
- MRR / New MRR / ARPU;
- paid retention / churn;
- forecast vs. actual when a financial plan exists;
- major product/GTM decisions.

### Quarterly Business Review (QBR)

Primary purpose: strategic performance and resource allocation.

Review:

- KPI trends and target changes;
- cohort performance;
- revenue and retention;
- strategic initiative performance;
- forecast and scenario implications;
- operating risks;
- priorities for the next period.

## 13. Decision Rules

The following rules govern how metrics should be used.

### Rule 1 — Diagnose the funnel, not only the headline

If WCVU falls, review:

1. acquisition quality;
2. onboarding completion;
3. activation;
4. time to first value;
5. Today usage;
6. task/routine completion;
7. cohort retention.

### Rule 2 — Do not optimize revenue before confirming value

A monetization improvement should not be treated as healthy if activation, WCVU, or retention deteriorates materially.

### Rule 3 — Compare cohorts whenever possible

Aggregate numbers can hide changes in user quality or behavior. Activation and retention should be reviewed by cohort once sample size allows.

### Rule 4 — Separate market segments before drawing conclusions

Brazil and international / English-speaking users may behave differently. Results should be segmented before assuming one operating benchmark applies to both.

### Rule 5 — Validate AI by business impact

AI adoption is not success by itself. AI features should be evaluated by whether they improve value realization, engagement, retention, or user experience relative to their operating cost.

### Rule 6 — Record actions with every material variance

A material KPI issue should produce:

- diagnosis or investigation;
- owner;
- action;
- due date;
- follow-up result.

## 14. Source-System Map

This is the initial logical source map. Exact schemas and fields will be defined in the Data Dictionary.

| Metric area | Logical source |
|---|---|
| Acquisition | Landing/web analytics and campaign/source tracking |
| Accounts | Auth / user registry |
| Activation | Product event instrumentation |
| Today / Tasks / Routines / Progress | Product event instrumentation |
| AI — mood / daily focus / reflection | Product events and AI usage logs |
| Trial / subscription | Subscription and billing records |
| Revenue | Subscription/billing records |
| Retention | Product events + auth + subscription data |

## 15. Data & Privacy Rules

This KPI framework is public, but the production data required to calculate it is not.

Public portfolio work must use:

- synthetic data;
- anonymized data;
- aggregated data;
- intentionally public information.

The public case must not expose:

- user-identifiable information;
- production credentials;
- API keys or tokens;
- private endpoints;
- raw sensitive event data;
- confidential financial information not intentionally disclosed.

Synthetic/modelled performance must be clearly labeled and must never be represented as actual company traction.

## 16. Open Validation Questions

The framework is complete enough to operate as the initial measurement design, but the following items require evidence after launch:

1. Does completing a Task or Routine through Today reliably correlate with retention?
2. Should the North Star require value on more than one day per week?
3. Which activation sequence best predicts recurring usage?
4. What time window should define activation?
5. Which product behaviors most strongly predict D30 retention?
6. Does Routine adoption increase retention beyond task-only usage?
7. Do mood, daily focus, and reflection improve core-value realization or retention?
8. How do Brazil and international / English-speaking cohorts differ?
9. What pricing and trial structure produce sustainable conversion and retention?
10. Which acquisition sources bring the highest-quality activated and retained users?

These are research questions, not missing documentation. They should be answered through later product, SQL, BI, financial-modeling, and GTM work.

## 17. Definition of Done

This KPI framework is considered complete for the current sprint task when:

- the North Star Metric is defined;
- acquisition, activation, engagement, conversion, revenue, and retention are connected in one KPI tree;
- each executive KPI has a definition, formula, source, owner, target status, threshold policy, review cadence, and decision use;
- leading and lagging indicators are distinguished;
- WBR, monthly review, and QBR logic are established;
- targets are not fabricated before a real baseline exists;
- source systems and privacy rules are documented;
- open validation questions are explicitly separated from confirmed definitions.

This framework becomes the measurement source for the next deliverables: **Data Dictionary, analytical data model, SQL analysis, Power BI dashboard, forecasting, financial model, GTM operating model, and final QBR.**

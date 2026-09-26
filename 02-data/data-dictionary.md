# PROTANNI — Data Dictionary & Privacy Rules

**Source system:** Supabase — `PROTANNI SaaS`  
**Schema basis:** Current production schema metadata reviewed 26 Sep 2026  
**Business context:** Pre-launch product in active development  
**Purpose:** Define the analytical data contract required to measure PROTANNI safely and consistently  
**Public portfolio policy:** No production user-level data is required to reproduce this case

## 1. Purpose

This document connects the PROTANNI KPI Framework to the real application data model.

It defines:

- which production sources are relevant for Business Operations;
- the physical database names that should remain consistent across analytics work;
- the business meaning of KPI-critical fields;
- which sources are authoritative for each business domain;
- data sensitivity and public-portfolio handling;
- analytical refresh expectations;
- data-quality rules;
- current instrumentation gaps that must be resolved before all KPIs can be calculated reliably.

This is **not** a dump of the full production schema. It is a Business Operations data dictionary built from the real Supabase schema.

No production user records were read to create this document. The review used schema metadata only: tables, columns, types, constraints, enum definitions, comments, views, and migrations.

## 2. Data Classification

| Classification | Definition | Examples | Public portfolio rule |
|---|---|---|---|
| **Public** | Information intentionally safe to publish. | KPI definitions, formulas, table/entity names, synthetic examples. | May be published directly. |
| **Internal** | Operational metadata that is not inherently personal but is not intended as public production data. | Status values, timestamps, feature flags, aggregate counts. | Publish only as structure, aggregation, or synthetic data. |
| **Confidential** | Commercial or operational information that could expose business performance or provider relationships. | Real revenue, real conversion, pricing assumptions not intentionally announced, provider IDs. | Replace with synthetic/modelled values or omit. |
| **Restricted / Personal** | User-identifiable, user-authored, security-sensitive, or provider-secret data. | Email, name, notes, reflections, feedback text, purchase tokens, raw billing payloads. | Never publish production values. Use synthetic placeholders or exclude entirely. |

### Core rule

> **Restricted data never enters the public portfolio. Confidential data is omitted, aggregated, or replaced by clearly labeled synthetic/modelled data.**

Removing a name or email alone is not sufficient anonymization. Combinations of timestamps, text, provider IDs, and behavioral records can still identify a person.

## 3. Source-of-Truth Conventions

| Business domain | Primary physical source | Analytical rule |
|---|---|---|
| Account creation / user identity | `auth.users` | Use `id` as the stable user key and `created_at` for signup cohorts. Email is never a portfolio field. |
| Profile / onboarding / locale / timezone | `public.profiles` | Use for onboarding state and user settings. |
| Tasks / Today task state | `public.tasks` | Current source for task creation, status, completion, Today flag, and hierarchy. |
| Current Routine domain | `public.routines`, `routine_items`, `routine_checkins`, `routine_item_checkins` | Primary Routine source for the current business model. |
| Mood | `public.mood_checkins` | Source for explicit mood check-ins. |
| Daily AI reflection | `public.daily_reflections` | AI-generated output table; content is Restricted. |
| Weekly review | `public.weekly_reviews` | User-authored weekly review; text is Restricted. |
| Weekly AI insight | `public.weekly_insights` | AI-generated output table; content is Restricted. |
| Billing plan configuration | `public.billing_plans` | Source for plan identity, interval, and trial configuration. |
| Subscription lifecycle | `public.billing_subscriptions` | Canonical subscription-state source. |
| Entitlement / access state | `public.entitlements`, `entitlement_history` | Canonical access/entitlement source. |
| Billing event history | `public.billing_events` | Provider-event and processing history; raw payload is Restricted. |
| Customer-provider mapping | `public.billing_customers` | Operational mapping only; provider IDs are Confidential/Restricted. |
| Life-area organization | `public.life_areas` | Product organization dimension. |
| Feedback | `public.feedback` | User-authored text; Restricted. |
| Dashboard summaries | `public.v_today_summary`, `v_dashboard_area_counts` | Convenience/derived views, not canonical raw sources. |
| Acquisition / landing behavior | **Not currently present in Supabase schema** | Requires web/product analytics source. |
| General product-event analytics | **Not currently present as a normalized event table** | Required for several engagement/retention KPIs. |

### Billing note

`profiles.is_paid` exists, but the normalized billing and entitlement tables provide the stronger analytical source of truth for paid status. For Business Operations reporting, use `billing_subscriptions` and/or `entitlements` rather than treating `profiles.is_paid` as the canonical commercial record.

## 4. Entity Map

| Business entity | Physical source | Business role | KPI relevance | Sensitivity |
|---|---|---|---|---|
| User | `auth.users` | Account identity and signup cohort | Sign-ups, activation denominator, retention cohorts | Restricted |
| Profile | `profiles` | Onboarding and user preferences | Onboarding Completion, locale segmentation | Internal / Restricted by field |
| Task | `tasks` | Executable user work | Activation, core-value behavior, engagement | Internal / Restricted by text field |
| Routine | `routines` | Recurring behavior container | Routine Adoption, engagement | Internal / Restricted by text field |
| Routine Item | `routine_items` | Executable routine step | Routine depth/completion | Internal / Restricted by title |
| Routine Check-in | `routine_checkins` | Daily routine participation | Routine engagement | Internal |
| Routine Item Check-in | `routine_item_checkins` | Item-level completion | Core-value depth | Internal |
| Mood Check-in | `mood_checkins` | User mood/energy/stress input | AI/mood feature use | Restricted / sensitive user content |
| Daily Reflection | `daily_reflections` | AI-generated daily output | AI feature production/use proxy | Restricted |
| Weekly Review | `weekly_reviews` | User-authored reflection | Review engagement | Restricted |
| Weekly Insight | `weekly_insights` | AI-generated weekly output | AI feature production/use proxy | Restricted |
| Subscription | `billing_subscriptions` | Monetization lifecycle | Trial, paid conversion, retention, churn | Confidential / Restricted by field |
| Plan | `billing_plans` | Commercial plan configuration | Trial structure, packaging | Confidential until intentionally public |
| Entitlement | `entitlements` | Product access state | Paid/access state | Confidential |
| Billing Event | `billing_events` | Provider lifecycle event history | Conversion/churn diagnostics | Restricted |
| Life Area | `life_areas` | User organization dimension | Product segmentation | Internal |
| Feedback | `feedback` | User-authored product feedback | Qualitative product evidence | Restricted |
| Acquisition Touch | **Missing source** | Visit/source/channel context | Visitor → Sign-up, CAC later | Not yet available |
| Product Event | **Missing normalized source** | Durable interaction/event history | WAU, WCVU validation, AI adoption, retention | Not yet available |

## 5. KPI-Critical Field Dictionary

### 5.1 Account and profile

| Physical field | Type | Business definition | KPI / use | Classification | Public handling | Analytical refresh |
|---|---|---|---|---|---|---|
| `auth.users.id` | UUID | Stable account identifier. | User joins, signup cohorts, retention. | Restricted | Replace with synthetic stable ID. | Daily / event-driven |
| `auth.users.created_at` | timestamptz | Account creation timestamp. | New Sign-ups, cohort start. | Internal | Synthetic/shifted timestamp. | Daily / event-driven |
| `auth.users.last_sign_in_at` | timestamptz | Most recent authentication sign-in. | Diagnostic only; not the preferred engagement definition. | Internal | Synthetic if used. | Daily |
| `auth.users.email` | varchar | User email address. | Identity only; not required for portfolio analytics. | Restricted | Never publish. | N/A |
| `profiles.id` | UUID | Profile key; corresponds to the user account. | Joins to product/profile context. | Restricted | Synthetic stable ID. | Daily |
| `profiles.created_at` | timestamptz | Profile creation timestamp. | Diagnostic/account setup. | Internal | Synthetic timestamp. | Daily |
| `profiles.locale` | text | User interface locale. | Language segmentation; not equivalent to country. | Internal | Synthetic/aggregate only. | Daily |
| `profiles.timezone` | text | User timezone used for local-day logic. | Daily/weekly metric boundaries. | Internal | Synthetic/aggregate only. | Daily |
| `profiles.onboarding_completed` | boolean | Whether the user completed onboarding. | Onboarding Completion Rate. | Internal | Synthetic boolean. | Daily / event-driven |
| `profiles.is_paid` | boolean | Convenience paid-state flag in profile. | Diagnostic only. | Confidential | Do not use as canonical revenue source. | Daily |
| `profiles.daily_focus_updated_at` | timestamptz | Last update timestamp for Daily Focus content. | Partial AI/Daily Focus usage proxy. | Internal | Synthetic timestamp. | Daily |
| `profiles.ai_personalization_enabled` | boolean | Whether AI personalization is enabled. | AI feature eligibility/context. | Internal | Synthetic boolean. | Daily |
| `profiles.full_name` | text | User-provided name. | No analytical requirement for this case. | Restricted | Never publish. | N/A |
| `profiles.avatar_url` | text | User avatar reference. | No analytical requirement for this case. | Restricted | Never publish. | N/A |

**Known gap:** the current schema exposes `onboarding_completed` but not a dedicated `onboarding_completed_at` field. The completion rate is measurable, but exact onboarding completion timing is not reliably available from this field alone.

### 5.2 Tasks and Today

| Physical field | Type | Business definition | KPI / use | Classification | Public handling | Analytical refresh |
|---|---|---|---|---|---|---|
| `tasks.id` | UUID | Stable task identifier. | Task-level analytics. | Internal | Synthetic ID. | Daily / event-driven |
| `tasks.user_id` | UUID | Owning user. | User-level aggregation. | Restricted | Synthetic stable ID. | Daily |
| `tasks.created_at` | timestamptz | Task creation time. | Activation diagnostics. | Internal | Synthetic timestamp. | Daily |
| `tasks.status` | `task_status` | Task lifecycle state: `todo`, `doing`, `done`, `archived`. | Completion/engagement logic. | Internal | Preserve valid enum values. | Daily |
| `tasks.completed_at` | timestamptz | Task completion timestamp. | Core-value behavior, retention activity. | Internal | Synthetic timestamp. | Daily / event-driven |
| `tasks.is_deleted` | boolean | Soft-delete flag. | Exclusion rule. | Internal | Synthetic boolean. | Daily |
| `tasks.is_today` | boolean | Current Today-selection flag. | Today diagnostics. | Internal | Synthetic boolean. | Daily / event-driven |
| `tasks.today_added_at` | timestamptz | Timestamp when task was added to Today. | Today-path diagnostics. | Internal | Synthetic timestamp. | Daily |
| `tasks.parent_task_id` | UUID | Parent task for subtask hierarchy. | Task-depth / Smart Subtask analysis. | Internal | Synthetic FK. | Daily |
| `tasks.life_area_id` | UUID | Reference to life-area dimension. | Area segmentation. | Internal | Synthetic FK. | Daily |
| `tasks.project_id` | UUID | Reference to project context. | Product-depth diagnostics. | Internal | Synthetic FK. | Daily |
| `tasks.area` | text | Task area label stored on the task. | Area segmentation / implementation compatibility. | Internal | Synthetic safe category only. | Daily |
| `tasks.title` | text | User-authored task title. | Not required for public KPI analysis. | Restricted | Never publish real values. | N/A |
| `tasks.description` | text | User-authored task description. | Not required for public KPI analysis. | Restricted | Never publish real values. | N/A |

**Measurement limitation:** `is_today` is a current-state flag. The schema does not provide a durable event stating that a specific completion happened **through Today**. Therefore the KPI Framework's WCVU definition cannot yet be calculated historically with full confidence from `tasks` alone.

### 5.3 Routines

| Physical field | Type | Business definition | KPI / use | Classification | Public handling | Analytical refresh |
|---|---|---|---|---|---|---|
| `routines.id` | UUID | Stable routine identifier. | Routine Adoption. | Internal | Synthetic ID. | Daily |
| `routines.user_id` | UUID | Owning user. | User aggregation. | Restricted | Synthetic stable ID. | Daily |
| `routines.created_at` | timestamptz | Routine creation timestamp. | Activation / adoption diagnostics. | Internal | Synthetic timestamp. | Daily |
| `routines.is_active` | boolean | Whether the routine is active. | Active routine base. | Internal | Synthetic boolean. | Daily |
| `routines.period` | text | Routine period definition. | Routine segmentation. | Internal | Preserve safe categories. | Daily |
| `routines.time_of_day` | text | Intended time-of-day grouping. | Usage segmentation. | Internal | Preserve safe categories. | Daily |
| `routines.goal_duration` | integer | Configured duration target where applicable. | Routine configuration analysis. | Internal | Synthetic value. | Daily |
| `routines.start_date` | date | Routine start date. | Adoption/cohort analysis. | Internal | Synthetic/shifted date. | Daily |
| `routines.area` | text | Routine area label. | Area segmentation. | Internal | Synthetic safe category. | Daily |
| `routines.name` | text | User-authored routine name. | Not required for public KPI analysis. | Restricted | Never publish real values. | N/A |
| `routine_items.id` | UUID | Stable routine-item identifier. | Routine depth. | Internal | Synthetic ID. | Daily |
| `routine_items.routine_id` | UUID | Parent routine. | Routine hierarchy. | Internal | Synthetic FK. | Daily |
| `routine_items.is_active` | boolean | Whether the item is active. | Active routine-item base. | Internal | Synthetic boolean. | Daily |
| `routine_items.title` | text | User-authored routine-item title. | Not required for public KPI analysis. | Restricted | Never publish real values. | N/A |
| `routine_checkins.id` | UUID | Daily routine check-in identifier. | Routine engagement. | Internal | Synthetic ID. | Daily / event-driven |
| `routine_checkins.routine_id` | UUID | Routine being checked in. | Routine engagement. | Internal | Synthetic FK. | Daily |
| `routine_checkins.checkin_date` | date | Local date of routine check-in. | Routine completion/adoption. | Internal | Synthetic date. | Daily |
| `routine_item_checkins.routine_item_id` | UUID | Routine item completed/checked. | Item-level engagement. | Internal | Synthetic FK. | Daily |
| `routine_item_checkins.is_done` | boolean | Whether the routine item was completed. | Completion depth. | Internal | Synthetic boolean. | Daily |
| `routine_item_checkins.done_at` | timestamptz | Completion timestamp. | Core-value day / engagement analysis. | Internal | Synthetic timestamp. | Daily / event-driven |

The schema enforces one routine check-in per routine/date and provides item-level completion timestamps, which is appropriate for routine engagement analysis.

**Measurement limitation:** routine completion records do not currently indicate whether the action was completed **through Today** versus another product surface.

### 5.4 Mood and AI-supported experiences

| Physical field | Type | Business definition | KPI / use | Classification | Public handling | Analytical refresh |
|---|---|---|---|---|---|---|
| `mood_checkins.checkin_date` | date | Local date of mood check-in. | Mood feature usage. | Sensitive/Internal | Synthetic date only. | Daily |
| `mood_checkins.mood` | `mood_level` | Mood category: very_low → great. | Mood feature analysis. | Restricted / sensitive | Synthetic/aggregate only. | Daily |
| `mood_checkins.energy_level` | integer | User-provided energy level, 1–10 when present. | Optional behavioral analysis. | Restricted / sensitive | Synthetic/aggregate only. | Daily |
| `mood_checkins.stress_level` | integer | User-provided stress level, 1–10 when present. | Optional behavioral analysis. | Restricted / sensitive | Synthetic/aggregate only. | Daily |
| `mood_checkins.note` | text | User-authored mood note. | No public analytical requirement. | Restricted | Never publish. | N/A |
| `daily_reflections.reflection_date` | date | Date of AI-generated daily reflection. | AI output availability. | Internal | Synthetic date. | Daily |
| `daily_reflections.language` | text | Output language (`en` or `pt-BR`). | Language segmentation. | Internal | Safe category. | Daily |
| `daily_reflections.generated_at` | timestamptz | AI generation timestamp. | Generation diagnostics. | Internal | Synthetic timestamp. | Daily |
| `daily_reflections.content` | text | AI-generated reflection content based on user context. | No public text requirement. | Restricted | Never publish production content. | N/A |
| `weekly_reviews.week_start_date` | date | Week represented by user-authored review. | Review participation. | Internal | Synthetic date. | Weekly |
| `weekly_reviews.went_well` | text | User-authored positive reflection. | Qualitative only. | Restricted | Never publish. | N/A |
| `weekly_reviews.needs_attention` | text | User-authored attention area. | Qualitative only. | Restricted | Never publish. | N/A |
| `weekly_insights.week_start_date` | date | Week represented by AI insight. | AI output availability. | Internal | Synthetic date. | Weekly |
| `weekly_insights.language` | text | Insight language. | Language segmentation. | Internal | Safe category. | Weekly |
| `weekly_insights.generated_at` | timestamptz | AI generation timestamp. | Generation diagnostics. | Internal | Synthetic timestamp. | Weekly |
| `weekly_insights.input_cutoff_at` | timestamptz | Latest input boundary used for the generated insight. | Reproducibility / freshness. | Internal | Synthetic timestamp. | Weekly |
| `weekly_insights.content` | text | AI-generated weekly insight. | No public text requirement. | Restricted | Never publish production content. | N/A |

**Important distinction:** a generated AI record is not necessarily proof that a user viewed or used the output. Current tables can support **generation metrics**, but a reliable **AI Feature Adoption Rate** still requires interaction/view events.

### 5.5 Subscription, entitlement, and billing

| Physical field | Type | Business definition | KPI / use | Classification | Public handling | Analytical refresh |
|---|---|---|---|---|---|---|
| `billing_plans.id` | UUID | Internal plan identifier. | Plan joins. | Internal | Synthetic ID. | On change |
| `billing_plans.plan_key` | text | Stable plan key. | Plan segmentation. | Internal/Confidential | Publish only if plan is intentionally public. | On change |
| `billing_plans.interval_unit` | enum | Billing interval: month/year. | ARPU/MRR normalization logic. | Internal | Synthetic/safe category. | On change |
| `billing_plans.interval_count` | integer | Number of interval units per billing cycle. | Revenue normalization. | Internal | Synthetic value. | On change |
| `billing_plans.trial_days` | integer | Configured trial duration. | Trial design / Trial Start context. | Confidential until intentionally public | Synthetic or omit until announced. | On change |
| `billing_plans.active` | boolean | Whether plan is active. | Eligible-plan base. | Internal | Synthetic boolean. | On change |
| `billing_subscriptions.id` | UUID | Internal subscription identifier. | Subscription lifecycle. | Confidential | Synthetic ID. | Event-driven |
| `billing_subscriptions.user_id` | UUID | User linked to subscription. | Conversion and retention joins. | Restricted | Synthetic stable ID. | Event-driven |
| `billing_subscriptions.provider` | `billing_provider` | Billing provider: Stripe or Google Play. | Channel/provider analysis. | Confidential | Synthetic/safe category only. | Event-driven |
| `billing_subscriptions.lifecycle_state` | enum | Subscription state: pending, trialing, active, grace_period, on_hold, paused, canceled, expired, revoked. | Trial, paid retention, churn. | Confidential | Synthetic state. | Event-driven |
| `billing_subscriptions.trial_starts_at` | timestamptz | Trial start timestamp. | Trial Start Rate / cohort. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.trial_ends_at` | timestamptz | Trial end timestamp. | Trial → Paid analysis. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.starts_at` | timestamptz | Subscription start timestamp. | Paid cohort. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.current_period_starts_at` | timestamptz | Current billing period start. | Retention/revenue timing. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.current_period_ends_at` | timestamptz | Current billing period end. | Retention/revenue timing. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.canceled_at` | timestamptz | Cancellation timestamp. | Churn. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_subscriptions.auto_renews` | boolean | Whether subscription is configured to renew. | Retention risk diagnostic. | Confidential | Synthetic boolean. | Event-driven |
| `billing_subscriptions.provider_subscription_id` | text | Provider-side subscription identifier. | Operational reconciliation only. | Restricted | Never publish. | N/A |
| `billing_subscriptions.purchase_token` | text | Provider purchase token. | Provider reconciliation only. | Restricted | Never publish. | N/A |
| `billing_subscriptions.raw_source` | jsonb | Raw provider subscription payload. | Debug/reconciliation. | Restricted | Never publish. | N/A |
| `entitlements.plan` | enum | Access plan: free, trial, pro. | Access/paid-state analysis. | Confidential | Synthetic category. | Event-driven |
| `entitlements.status` | enum | Entitlement status: active, expired, canceled. | Paid/access retention. | Confidential | Synthetic category. | Event-driven |
| `entitlements.trial_ends_at` | timestamptz | Access trial end. | Trial/access analysis. | Confidential | Synthetic timestamp. | Event-driven |
| `entitlements.access_ends_at` | timestamptz | Access end timestamp. | Churn/access loss. | Confidential | Synthetic timestamp. | Event-driven |
| `entitlement_history.new_status` | enum | New entitlement state after a change. | Lifecycle history. | Confidential | Synthetic state. | Event-driven |
| `entitlement_history.reason_code` | text | Reason associated with entitlement change. | Churn diagnostics. | Confidential | Synthetic controlled value only. | Event-driven |
| `billing_events.event_type` | text | Provider event type. | Billing lifecycle diagnostics. | Confidential | Synthetic/normalized category. | Event-driven |
| `billing_events.event_created_at` | timestamptz | Provider event timestamp. | Sequencing / lifecycle. | Confidential | Synthetic timestamp. | Event-driven |
| `billing_events.processing_status` | text | Internal event-processing state. | Ops reliability. | Internal | Synthetic category. | Event-driven |
| `billing_events.payload` | jsonb | Raw provider event payload. | Operational troubleshooting only. | Restricted | Never publish. | N/A |

**Known revenue gap:** the normalized billing tables currently identify plans, intervals, providers, and subscription lifecycle but do not expose a normalized monetary amount/price field suitable for direct MRR, New MRR, or ARPU calculation. Those KPIs require either a normalized price/revenue fact, a controlled provider-price lookup, or another approved finance source.

### 5.6 Supporting dimensions and qualitative sources

| Physical field | Type | Business definition | Use | Classification | Public handling |
|---|---|---|---|---|---|
| `life_areas.id` | UUID | Life-area identifier. | Task/product segmentation. | Internal | Synthetic ID. |
| `life_areas.slug` | text | Stable life-area slug. | Safe categorical grouping if aligned with current product taxonomy. | Internal | Synthetic/safe category. |
| `life_areas.name` | text | Display name for the user's life area. | Product segmentation. | Potentially user-specific | Use canonical/synthetic categories only. |
| `feedback.user_id` | UUID | User who submitted feedback. | Qualitative linkage. | Restricted | Synthetic ID only. |
| `feedback.message` | text | User-authored feedback. | Qualitative insight. | Restricted | Never publish production text. |
| `feedback.created_at` | timestamptz | Feedback timestamp. | Feedback volume/trend. | Internal | Synthetic timestamp. |

## 6. KPI-to-Source Mapping

| KPI | Current source | Current computability | Notes / gap |
|---|---|---|---|
| New Sign-ups | `auth.users.created_at` | **Yes** | Use account creation as signup cohort. |
| Visitor → Sign-up Conversion | No Supabase acquisition/visitor source | **No** | Requires landing/web analytics and acquisition-source data. |
| Onboarding Completion Rate | `profiles.onboarding_completed` + account population | **Yes, current-state rate** | Exact completion timestamp is missing. |
| Activation Rate | `profiles`, `tasks`, `routines*` | **Partial** | Current activation definition requires durable proof of first core-value completion through Today. |
| Time to First Value | Signup timestamp + task/routine completion data | **Partial** | Same Today-source limitation as Activation. |
| Weekly Core Value Users (WCVU) | `tasks.completed_at`, `routine_item_checkins.done_at` | **Partial** | Completion exists, but historical “through Today” source is not durable for both domains. |
| Core Value Days per WCVU | Task/routine completion timestamps | **Partial** | Can calculate completion days once core-value event definition is instrumented reliably. |
| WAU | No normalized product-event table | **Partial / definition-dependent** | Could union selected product actions, but a canonical meaningful-activity event layer is preferable. |
| Routine Adoption Rate | `routines`, `routine_checkins`, `routine_item_checkins` | **Yes** | Final denominator/activation rule must remain consistent with KPI Framework. |
| AI Feature Adoption Rate | `mood_checkins`, `daily_reflections`, `weekly_insights`, profile Daily Focus timestamp | **Partial** | Generation/existence is not equivalent to user view/use. Interaction instrumentation is needed. |
| Trial Start Rate | `billing_subscriptions.trial_starts_at`, `lifecycle_state` | **Partial** | Trial starts are available; “eligible users” denominator still needs an explicit business rule/source. |
| Trial → Paid Conversion | `billing_subscriptions`, `billing_events`, `entitlement_history` | **Yes, once paid flow is live** | Define conversion window and eligible-ended-trial cohort before reporting. |
| MRR | Billing lifecycle + **missing normalized monetary amount** | **No, not reliably from current normalized tables alone** | Add/identify approved price/revenue source. |
| New MRR | Same as MRR | **No** | Same monetary-source gap. |
| ARPU | Paid users + **missing normalized monetary amount** | **No** | Same monetary-source gap. |
| D7 User Retention | Signup cohort + defined activity source | **Partial** | Requires final active-user event definition. |
| D30 User Retention | Signup cohort + defined activity source | **Partial** | Requires mature cohorts and final active-user event definition. |
| Paid Subscriber Retention | `billing_subscriptions`, `entitlements`, lifecycle history | **Yes, once paid cohorts exist** | Use normalized billing/entitlement states. |
| Subscriber Churn | `billing_subscriptions.canceled_at`, lifecycle state/history | **Yes, once paid cohorts exist** | Define voluntary/involuntary treatment later if needed. |

## 7. Current Instrumentation / Data Gaps

These are not failures of the Business Operations documentation. They are explicit dependencies uncovered by mapping the KPI Framework to the real product schema.

### 7.1 Acquisition source is absent

The Supabase schema does not currently provide a landing-visitor or acquisition-touch dataset.

Needed later for:
- Visitor → Sign-up Conversion;
- sign-ups by channel;
- acquisition quality;
- CAC.

**Future source:** web/product analytics or campaign attribution system.

### 7.2 No canonical product-event fact table

The application stores business objects and completion records, but there is no normalized event stream such as:

`user_id | event_name | occurred_at | surface | object_type | object_id | properties`

This limits:
- canonical WAU;
- historical Today-path analysis;
- AI view/use measurement;
- funnel sequencing;
- robust retention behavior analysis.

### 7.3 “Through Today” is not durable enough for the North Star

`tasks.is_today` is current state and `tasks.today_added_at` records Today addition, while task completion is stored separately. Routine check-ins do not expose a Today source.

Therefore the initial North Star **WCVU** remains valid as a business definition, but the production schema needs a durable event/source mechanism before it can be measured historically without ambiguity.

### 7.4 Onboarding completion lacks event timestamp

`profiles.onboarding_completed` supports the completion rate but not precise Time-to-Onboarding or funnel sequencing.

### 7.5 AI output is not the same as AI adoption

The schema clearly distinguishes AI-generated output tables such as `daily_reflections` and `weekly_insights`, but there is no durable user interaction/view event proving adoption.

### 7.6 Normalized revenue amount is absent

The current normalized billing foundation contains lifecycle and provider identifiers, but not a canonical monetary amount field for MRR/ARPU.

### 7.7 Market geography is not explicitly represented

`profiles.locale` supports language segmentation but should not be treated as a reliable country/market field. Brazil vs. international analysis will need an explicit market/acquisition dimension if that segmentation becomes operationally important.

### 7.8 Routine vs. Habit structures need analytical alignment

The schema contains both:
- `routines*` tables, which align with the current product terminology;
- `habits` / `habit_logs`, which remain in the schema.

The current `v_today_summary` still counts `habit_logs` as `habits_logged_today`.

For this Business Operations case:
- **Routines** are the primary current business concept;
- `habits*` should not be treated as the primary Routine KPI source unless the product implementation explicitly requires it;
- the view/schema terminology should be reconciled before using `v_today_summary` for current Routine reporting.

## 8. Synthetic / Anonymized Data Policy

The Week 2 public dataset must preserve the **shape and analytical relationships** of the business without copying production records.

### 8.1 Identifier policy

Production UUIDs must never be published.

Example:

```
production user_id: <never exported>
public synthetic user_id: USR_000001
```

All synthetic foreign keys must preserve referential integrity.

### 8.2 Timestamp policy

Public timestamps may be fully generated or consistently shifted.

Rules:
- preserve realistic sequencing;
- preserve cohort logic;
- do not preserve a real user's unique event pattern;
- do not publish exact production timestamps.

### 8.3 User-authored text policy

The following production content must never be copied into the public dataset:

- task titles/descriptions;
- routine names/item titles;
- mood notes;
- journal content;
- weekly review text;
- feedback messages;
- Daily Focus text;
- AI reflection/insight content derived from a real user.

Use synthetic text or omit the field.

### 8.4 Sensitive wellness-context policy

Mood, energy, stress, reflection, and similar personal context may only be represented through clearly synthetic data or sufficiently aggregated public analysis.

### 8.5 Billing policy

Never export:
- provider customer IDs;
- provider subscription IDs;
- purchase tokens;
- raw provider payloads;
- real billing-event payloads.

Any revenue, price, conversion, or trial values used publicly before launch must be labeled **synthetic**, **modelled**, or **planning assumption**.

### 8.6 Small-cohort rule

Even anonymized aggregates can identify users in very small cohorts.

For public work:
- prefer synthetic data;
- avoid publishing production aggregates for very small groups;
- never expose a combination of dimensions that could reasonably re-identify an individual.

## 9. Refresh Expectations

These are analytical operating expectations, not a claim that a warehouse/ETL pipeline already exists.

| Data domain | Recommended analytical refresh |
|---|---|
| Accounts / profiles | Daily; event-driven later if needed |
| Tasks / Today | Daily for WBR; near-real-time only if product operations require it |
| Routines / check-ins | Daily |
| Mood / Daily Focus | Daily |
| Daily reflections | Daily |
| Weekly reviews / insights | Weekly |
| Subscription / entitlement lifecycle | Event-driven operationally; daily analytical snapshot |
| Billing event diagnostics | Event-driven |
| WBR dataset | Weekly frozen snapshot |
| Monthly/QBR dataset | Period-end snapshot with reproducible metric version |

## 10. Data Quality Rules

### Existing structural controls observed

The production schema already uses:
- UUID primary keys;
- foreign-key relationships;
- Row Level Security on public base tables;
- controlled enum values for task, mood, subscription, entitlement, and other states;
- unique constraints for several date/user combinations such as mood and routine check-ins;
- bounded energy/stress values where applicable.

### Analytical quality checks

Before data is used for KPIs:

1. **User uniqueness** — one stable analytical identity per account.
2. **Referential integrity** — synthetic and analytical foreign keys must resolve.
3. **Completion consistency** — a task reported as completed should have a usable completion timestamp.
4. **Soft-delete exclusion** — deleted tasks do not enter active/productivity KPIs.
5. **Local-day consistency** — daily metrics must respect user/product timezone logic.
6. **Trial sequencing** — trial end must not precede trial start.
7. **Subscription sequencing** — lifecycle dates must be chronologically coherent.
8. **No duplicate daily check-ins** — preserve existing uniqueness logic for routine/mood daily records.
9. **Metric-version consistency** — changes to Activation or WCVU definitions must be versioned and not silently backfilled as if definitions never changed.
10. **Synthetic label** — every public output using modelled/synthetic data must state that explicitly.

## 11. Physical Naming Policy

The portfolio analytics layer should preserve production nomenclature wherever practical.

Examples:
- `tasks` stays `tasks`;
- `routines` stays `routines`;
- `routine_checkins` stays `routine_checkins`;
- `billing_subscriptions` stays `billing_subscriptions`.

Business aliases may be added in documentation, but should not silently replace the physical source name.

Example:

```
Physical: routine_item_checkins.done_at
Business meaning: Routine item completion timestamp
```

This keeps the SQL, synthetic dataset, BI model, and business documentation traceable back to the real app.

## 12. Portfolio Dataset Boundary

The public Week 2 dataset will be a **separate synthetic analytical dataset**.

It will:
- mirror only KPI-relevant entities/fields;
- use the same or clearly mapped physical nomenclature;
- preserve realistic PK/FK relationships;
- include enough records for funnel, cohort, revenue, retention, and market analysis;
- contain no production user-level values;
- include explicit synthetic-data documentation.

The public dataset does **not** need to be written back into the production Supabase project.

## 13. Definition of Done

This task is complete when:

- the real Supabase schema is the source for naming and business definitions;
- all executive KPIs from the KPI Framework have a mapped source or an explicit instrumentation gap;
- KPI-critical fields have business definitions, sensitivity classifications, public handling rules, and refresh expectations;
- authoritative sources are distinguished from convenience/derived fields;
- synthetic/anonymization rules are documented;
- user-authored, wellness, billing, and credential-sensitive fields are protected;
- known measurement gaps are recorded rather than hidden;
- the public case can be reproduced without exposing production data.

This document becomes the source for the next Phase 1 work: **analytical data model → synthetic dataset → SQL business-question pack**.

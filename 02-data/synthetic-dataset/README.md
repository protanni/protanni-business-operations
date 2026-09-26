# PROTANNI — Synthetic Analytical Dataset

This folder contains a **fully synthetic** SQL dataset designed from the real PROTANNI Data Dictionary and Analytical Data Model.

No production rows were used.

## What is included

The dataset creates these analytical/source-compatible tables:

- `users`
- `profiles`
- `tasks`
- `routines`
- `routine_items`
- `routine_checkins`
- `routine_item_checkins`
- `billing_plans`
- `billing_subscriptions`
- `acquisition_touches`
- `product_events`
- `subscription_revenue`

## Synthetic scale

| Table | Rows |
|---|---:|
| `users` | 80 |
| `profiles` | 80 |
| `tasks` | 521 |
| `routines` | 40 |
| `routine_items` | 96 |
| `routine_checkins` | 632 |
| `routine_item_checkins` | 1520 |
| `billing_plans` | 2 |
| `billing_subscriptions` | 25 |
| `acquisition_touches` | 300 |
| `product_events` | 1475 |
| `subscription_revenue` | 54 |

**Synthetic period:** Jan–Jun 2026  
**Seed:** 20260926

The values are portfolio fixtures, not actual PROTANNI traction, revenue, pricing or performance.

## Production-compatible vs modelled sources

The core product/billing tables use PROTANNI naming and safe field concepts.

Three tables are intentionally **modelled future analytical sources** because the current production schema does not yet provide them in normalized form:

- `acquisition_touches` — visitor/channel/campaign attribution;
- `product_events` — durable interaction history needed for Today-path, WAU and AI-adoption measurement;
- `subscription_revenue` — normalized monetary values needed for MRR/New MRR/ARPU.

Their inclusion tests the analytical architecture. It does not claim those pipelines already exist in production.

## Privacy boundary

The dataset contains no production:

- UUIDs;
- names or emails;
- task/routine free text;
- mood, journal, reflection or feedback content;
- billing purchase tokens;
- provider customer/subscription IDs;
- raw billing payloads;
- copied user timestamps.

Synthetic IDs use formats such as `USR_0001`, `TSK_000001`, and `SUB_00001`.

## Reproducibility

The committed `synthetic_dataset.sql` is directly executable in a PostgreSQL-compatible environment.

To regenerate it with the same deterministic rules:

```bash
node generate_synthetic_dataset.mjs
```

The generator uses fixed seed **20260926**.

## Validation

- [x] profiles match users
- [x] task user keys
- [x] routine keys
- [x] routine item keys
- [x] routine checkin keys
- [x] routine item checkin keys
- [x] subscription keys
- [x] revenue keys
- [x] converted acquisition keys
- [x] trial chronology

## Business questions supported

The data is structured for the Phase 1 SQL pack: acquisition conversion, signup cohorts, onboarding, activation, Time to First Value, WCVU/Core Value Days, WAU, Routine Adoption, AI adoption, trial conversion, MRR, New MRR, ARPU, D7/D30 retention, paid retention, churn, channel performance and Brazil vs International comparisons.

See [Data Model](../data-model.md) and [Data Dictionary](../data-dictionary.md).

> Every result produced from this dataset must be labeled **synthetic/modelled** and must not be presented as actual PROTANNI performance.

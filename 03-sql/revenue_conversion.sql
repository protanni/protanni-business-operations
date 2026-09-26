-- PROTANNI — Conversion & Revenue SQL
-- Dataset: fully synthetic. Monetary values are analytical fixtures, not published PROTANNI pricing.

-- Q19 — What share of activated users start a trial?
-- Interpretation (synthetic): 25 of 51 activated users started a trial, or 49.02%.
-- Decision use: Evaluate monetization entry after users reach product value.
WITH activated AS (
  SELECT DISTINCT p.user_id
  FROM profiles p
  WHERE p.onboarding_completed
    AND EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = p.user_id
        AND e.surface = 'Today'
        AND e.event_name IN ('task_completed', 'routine_completed')
    )
),
trials AS (
  SELECT DISTINCT user_id
  FROM billing_subscriptions
)
SELECT
  (SELECT COUNT(*) FROM activated) AS activated_users,
  (SELECT COUNT(*) FROM trials) AS trial_users,
  ROUND(
    100.0 * (SELECT COUNT(*) FROM trials)
    / NULLIF((SELECT COUNT(*) FROM activated), 0),
    2
  ) AS trial_start_rate_pct;

-- Q20 — What is Trial → Paid Conversion?
-- Interpretation (synthetic): 12 of 25 trial users converted to paid, or 48.00%.
-- Decision use: Connect trial design and product value to monetization.
SELECT
  COUNT(DISTINCT user_id) AS trial_users,
  COUNT(DISTINCT user_id) FILTER (WHERE starts_at IS NOT NULL) AS paid_users,
  ROUND(
    100.0 * COUNT(DISTINCT user_id) FILTER (WHERE starts_at IS NOT NULL)
    / NULLIF(COUNT(DISTINCT user_id), 0),
    2
  ) AS trial_to_paid_pct
FROM billing_subscriptions;

-- Q21 — How many active paid subscribers are represented each month?
-- Interpretation (synthetic): Active paid subscribers grow from 2 in January to a peak of 12 in April, then 11 in May/June.
-- Decision use: Separate subscriber-base growth from revenue-per-user effects.
SELECT
  month_start_date,
  COUNT(DISTINCT user_id) AS active_paid_subscribers
FROM subscription_revenue
WHERE is_active_paid
GROUP BY month_start_date
ORDER BY month_start_date;

-- Q22 — What are MRR and New MRR by month?
-- Interpretation (synthetic): MRR reaches $99 in April and is $90 in June; no New MRR is generated in May/June.
-- Decision use: Distinguish installed recurring revenue from new-customer contribution.
SELECT
  month_start_date,
  ROUND(SUM(normalized_mrr), 2) AS mrr_usd,
  ROUND(SUM(normalized_mrr) FILTER (WHERE is_new_mrr), 2) AS new_mrr_usd
FROM subscription_revenue
WHERE is_active_paid
GROUP BY month_start_date
ORDER BY month_start_date;

-- Q23 — What is ARPU by month?
-- Interpretation (synthetic): ARPU ranges from $8.10 to $9.00 because monthly and annual normalized values differ.
-- Decision use: Monitor revenue mix and later connect pricing/package changes to unit economics.
SELECT
  month_start_date,
  COUNT(DISTINCT user_id) AS paid_users,
  ROUND(SUM(normalized_mrr), 2) AS mrr_usd,
  ROUND(
    SUM(normalized_mrr) / NULLIF(COUNT(DISTINCT user_id), 0),
    2
  ) AS arpu_usd
FROM subscription_revenue
WHERE is_active_paid
GROUP BY month_start_date
ORDER BY month_start_date;

-- Q24 — What is observed paid subscriber churn?
-- Interpretation (synthetic): 1 of 12 paid subscribers has a cancellation, or 8.33% observed churn across the synthetic window.
-- Decision use: This is a simple observed-period indicator; production reporting should use a period/cohort churn definition.
SELECT
  COUNT(DISTINCT user_id) FILTER (WHERE starts_at IS NOT NULL) AS paid_subscribers,
  COUNT(DISTINCT user_id) FILTER (
    WHERE starts_at IS NOT NULL AND canceled_at IS NOT NULL
  ) AS churned_subscribers,
  COUNT(DISTINCT user_id) FILTER (
    WHERE starts_at IS NOT NULL AND canceled_at IS NULL
  ) AS retained_active_subscribers,
  ROUND(
    100.0 * COUNT(DISTINCT user_id) FILTER (
      WHERE starts_at IS NOT NULL AND canceled_at IS NOT NULL
    )
    / NULLIF(
        COUNT(DISTINCT user_id) FILTER (WHERE starts_at IS NOT NULL),
        0
      ),
    2
  ) AS observed_churn_pct
FROM billing_subscriptions;

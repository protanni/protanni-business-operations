-- PROTANNI — Market & Channel SQL
-- Dataset: fully synthetic. Results are portfolio evidence, not actual PROTANNI performance.

-- Q25 — Which acquisition channels produce higher activation?
-- Interpretation (synthetic): Direct leads activation at 76.92%; paid social is lowest at 50.00%.
-- Decision use: Evaluate channel quality, not only top-of-funnel conversion.
WITH user_channel AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    channel
  FROM acquisition_touches
  WHERE converted_to_signup
    AND user_id IS NOT NULL
  ORDER BY user_id, occurred_at
),
activated AS (
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
)
SELECT
  uc.channel,
  COUNT(*) AS signups,
  COUNT(a.user_id) AS activated_users,
  ROUND(
    100.0 * COUNT(a.user_id)
    / NULLIF(COUNT(*), 0),
    2
  ) AS activation_rate_pct
FROM user_channel uc
LEFT JOIN activated a USING (user_id)
GROUP BY uc.channel
ORDER BY activation_rate_pct DESC, signups DESC;

-- Q26 — Which channels produce trials and paid users?
-- Interpretation (synthetic): Direct and search lead signup→paid conversion at 23.08% and 22.22%.
-- Decision use: Compare commercial quality across channels before allocating budget.
WITH user_channel AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    channel
  FROM acquisition_touches
  WHERE converted_to_signup
    AND user_id IS NOT NULL
  ORDER BY user_id, occurred_at
),
trials AS (
  SELECT DISTINCT user_id FROM billing_subscriptions
),
paid AS (
  SELECT DISTINCT user_id
  FROM billing_subscriptions
  WHERE starts_at IS NOT NULL
)
SELECT
  uc.channel,
  COUNT(*) AS signups,
  COUNT(t.user_id) AS trial_users,
  COUNT(p.user_id) AS paid_users,
  ROUND(100.0 * COUNT(t.user_id) / NULLIF(COUNT(*), 0), 2) AS signup_to_trial_pct,
  ROUND(100.0 * COUNT(p.user_id) / NULLIF(COUNT(*), 0), 2) AS signup_to_paid_pct
FROM user_channel uc
LEFT JOIN trials t USING (user_id)
LEFT JOIN paid p USING (user_id)
GROUP BY uc.channel
ORDER BY signup_to_paid_pct DESC, signups DESC;

-- Q27 — Which channels produce stronger D30 retention?
-- Interpretation (synthetic): Direct and referral lead at 69.23%; paid social is lowest at 33.33%.
-- Decision use: Avoid optimizing acquisition purely for signup volume.
WITH user_channel AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    channel
  FROM acquisition_touches
  WHERE converted_to_signup
    AND user_id IS NOT NULL
  ORDER BY user_id, occurred_at
),
base AS (
  SELECT
    u.user_id,
    u.created_at::date AS signup_date,
    uc.channel
  FROM users u
  JOIN user_channel uc USING (user_id)
),
flags AS (
  SELECT
    b.*,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = b.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN b.signup_date + 30 AND b.signup_date + 36
    ) AS retained_d30
  FROM base b
)
SELECT
  channel,
  COUNT(*) AS users,
  COUNT(*) FILTER (WHERE retained_d30) AS retained_d30_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d30)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d30_retention_pct
FROM flags
GROUP BY channel
ORDER BY d30_retention_pct DESC, users DESC;

-- Q28 — Which channels contribute June MRR?
-- Interpretation (synthetic): Direct and search each contribute 26.67% of June MRR.
-- Decision use: Connect acquisition source to downstream recurring revenue.
WITH user_channel AS (
  SELECT DISTINCT ON (user_id)
    user_id,
    channel
  FROM acquisition_touches
  WHERE converted_to_signup
    AND user_id IS NOT NULL
  ORDER BY user_id, occurred_at
),
june AS (
  SELECT
    user_id,
    SUM(normalized_mrr) AS mrr
  FROM subscription_revenue
  WHERE month_start_date = DATE '2026-06-01'
    AND is_active_paid
  GROUP BY user_id
)
SELECT
  uc.channel,
  ROUND(COALESCE(SUM(j.mrr), 0), 2) AS june_mrr_usd,
  ROUND(
    100.0 * COALESCE(SUM(j.mrr), 0)
    / NULLIF(SUM(COALESCE(SUM(j.mrr), 0)) OVER (), 0),
    2
  ) AS june_mrr_share_pct
FROM user_channel uc
LEFT JOIN june j USING (user_id)
GROUP BY uc.channel
ORDER BY june_mrr_usd DESC, uc.channel;

-- Q29 — How do Brazil and International users differ across the funnel?
-- Interpretation (synthetic): International shows higher activation (74.07% vs 58.49%),
-- signup→trial (40.74% vs 26.42%), signup→paid (22.22% vs 11.32%) and D30 (62.96% vs 50.94%).
-- Decision use: Treat market differences as hypotheses for later segmentation and GTM tests.
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
  SELECT DISTINCT user_id FROM billing_subscriptions
),
paid AS (
  SELECT DISTINCT user_id
  FROM billing_subscriptions
  WHERE starts_at IS NOT NULL
),
base AS (
  SELECT
    p.user_id,
    p.market_key,
    u.created_at::date AS signup_date,
    (a.user_id IS NOT NULL) AS activated,
    (t.user_id IS NOT NULL) AS trialed,
    (pd.user_id IS NOT NULL) AS paid
  FROM profiles p
  JOIN users u USING (user_id)
  LEFT JOIN activated a USING (user_id)
  LEFT JOIN trials t USING (user_id)
  LEFT JOIN paid pd USING (user_id)
),
flags AS (
  SELECT
    b.*,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = b.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN b.signup_date + 30 AND b.signup_date + 36
    ) AS retained_d30
  FROM base b
)
SELECT
  market_key,
  COUNT(*) AS signups,
  ROUND(100.0 * COUNT(*) FILTER (WHERE activated) / COUNT(*), 2) AS activation_rate_pct,
  ROUND(100.0 * COUNT(*) FILTER (WHERE trialed) / COUNT(*), 2) AS signup_to_trial_pct,
  ROUND(100.0 * COUNT(*) FILTER (WHERE paid) / COUNT(*), 2) AS signup_to_paid_pct,
  ROUND(100.0 * COUNT(*) FILTER (WHERE retained_d30) / COUNT(*), 2) AS d30_retention_pct
FROM flags
GROUP BY market_key
ORDER BY signups DESC;

-- Q30 — Which plan contributes more recurring revenue?
-- Interpretation (synthetic): The monthly fixture represents 80% of June MRR and 9 of 12 paid users.
-- Decision use: Understand plan mix; do not treat these synthetic values as a pricing recommendation.
WITH paid_by_plan AS (
  SELECT
    plan_id,
    COUNT(DISTINCT user_id) AS paid_users
  FROM billing_subscriptions
  WHERE starts_at IS NOT NULL
  GROUP BY plan_id
),
june AS (
  SELECT
    plan_id,
    SUM(normalized_mrr) AS june_mrr
  FROM subscription_revenue
  WHERE month_start_date = DATE '2026-06-01'
    AND is_active_paid
  GROUP BY plan_id
)
SELECT
  bp.plan_key,
  COALESCE(p.paid_users, 0) AS paid_users,
  ROUND(COALESCE(j.june_mrr, 0), 2) AS june_mrr_usd,
  ROUND(
    100.0 * COALESCE(j.june_mrr, 0)
    / NULLIF(SUM(COALESCE(j.june_mrr, 0)) OVER (), 0),
    2
  ) AS june_mrr_share_pct
FROM billing_plans bp
LEFT JOIN paid_by_plan p USING (plan_id)
LEFT JOIN june j USING (plan_id)
ORDER BY june_mrr_usd DESC;

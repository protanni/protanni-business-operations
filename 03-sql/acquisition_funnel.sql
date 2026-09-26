-- PROTANNI — Acquisition & Funnel SQL
-- Dataset: fully synthetic. Results are portfolio evidence, not actual PROTANNI performance.

-- Q01 — How many users signed up each week?
-- Interpretation (synthetic): Signup volume varies materially by cohort week; the largest synthetic week produced 14 sign-ups.
-- Decision use: Track acquisition momentum and investigate changes by source/channel.
SELECT
  date_trunc('week', created_at)::date AS signup_week,
  COUNT(*) AS signups
FROM users
GROUP BY 1
ORDER BY 1;

-- Q02 — What is Visitor → Sign-up Conversion?
-- Interpretation (synthetic): 80 of 300 qualified visits converted, or 26.67%.
-- Decision use: Establish the top-of-funnel conversion baseline for channel and landing-page review.
SELECT
  COUNT(*) FILTER (WHERE is_qualified_visit) AS qualified_visits,
  COUNT(*) FILTER (WHERE converted_to_signup) AS signups,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE converted_to_signup)
    / NULLIF(COUNT(*) FILTER (WHERE is_qualified_visit), 0),
    2
  ) AS visitor_to_signup_pct
FROM acquisition_touches;

-- Q03 — Which acquisition channels convert visitors to sign-ups most effectively?
-- Interpretation (synthetic): Search leads at 36.00%; paid social is 23.53% and referral 23.21%.
-- Decision use: Compare channel efficiency before increasing spend or effort.
SELECT
  channel,
  COUNT(*) FILTER (WHERE is_qualified_visit) AS qualified_visits,
  COUNT(*) FILTER (WHERE converted_to_signup) AS signups,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE converted_to_signup)
    / NULLIF(COUNT(*) FILTER (WHERE is_qualified_visit), 0),
    2
  ) AS visitor_to_signup_pct
FROM acquisition_touches
GROUP BY channel
ORDER BY visitor_to_signup_pct DESC, qualified_visits DESC;

-- Q04 — What share of sign-ups comes from each market?
-- Interpretation (synthetic): Brazil represents 66.25% of sign-ups; International represents 33.75%.
-- Decision use: Understand acquisition mix without treating locale as a proxy for geography.
SELECT
  market_key,
  COUNT(*) AS signups,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS signup_share_pct
FROM profiles
GROUP BY market_key
ORDER BY signups DESC;

-- Q05 — How does onboarding completion differ by market?
-- Interpretation (synthetic): International onboarding completion is 92.59% versus 77.36% in Brazil.
-- Decision use: Identify market-specific onboarding friction worth investigating.
SELECT
  market_key,
  COUNT(*) AS signups,
  COUNT(*) FILTER (WHERE onboarding_completed) AS onboarded_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE onboarding_completed)
    / NULLIF(COUNT(*), 0),
    2
  ) AS onboarding_completion_pct
FROM profiles
GROUP BY market_key
ORDER BY onboarding_completion_pct DESC;

-- Q06 — Where are the largest end-to-end funnel drop-offs?
-- Interpretation (synthetic): The largest percentage losses occur Qualified Visits → Sign-ups (73.33%),
-- Trial Started → Paid (52.00%), and Activated → Trial Started (50.98%).
-- Decision use: Prioritize investigation by stage instead of optimizing isolated metrics.
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
stages AS (
  SELECT 1 AS stage_order, 'Qualified visits'::text AS stage, COUNT(*)::numeric AS users
  FROM acquisition_touches
  WHERE is_qualified_visit
  UNION ALL
  SELECT 2, 'Sign-ups', COUNT(*) FROM users
  UNION ALL
  SELECT 3, 'Onboarding complete', COUNT(*) FROM profiles WHERE onboarding_completed
  UNION ALL
  SELECT 4, 'Activated', COUNT(*) FROM activated
  UNION ALL
  SELECT 5, 'Trial started', COUNT(DISTINCT user_id) FROM billing_subscriptions
  UNION ALL
  SELECT 6, 'Paid', COUNT(DISTINCT user_id) FROM billing_subscriptions WHERE starts_at IS NOT NULL
),
calc AS (
  SELECT *, LAG(users) OVER (ORDER BY stage_order) AS previous_users
  FROM stages
)
SELECT
  stage_order,
  stage,
  users,
  previous_users,
  ROUND(100.0 * users / NULLIF(previous_users, 0), 2) AS step_conversion_pct,
  ROUND(100.0 * (previous_users - users) / NULLIF(previous_users, 0), 2) AS step_dropoff_pct
FROM calc
ORDER BY stage_order;

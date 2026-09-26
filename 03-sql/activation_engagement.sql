-- PROTANNI — Activation & Engagement SQL
-- Dataset: fully synthetic. Results are portfolio evidence, not actual PROTANNI performance.

-- Q07 — What percentage of signed-up users complete onboarding?
-- Interpretation (synthetic): 66 of 80 users completed onboarding, or 82.50%.
-- Decision use: Monitor the first major product setup checkpoint.
SELECT
  COUNT(*) AS signups,
  COUNT(*) FILTER (WHERE onboarding_completed) AS onboarded_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE onboarding_completed)
    / NULLIF(COUNT(*), 0),
    2
  ) AS onboarding_completion_pct
FROM profiles;

-- Q08 — What is the Activation Rate?
-- Activation = onboarding complete + at least one core-value completion through Today.
-- Interpretation (synthetic): 51 of 80 users activated, or 63.75%.
-- Decision use: Connect onboarding to realized product value.
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
)
SELECT
  COUNT(*) AS signups,
  (SELECT COUNT(*) FROM activated) AS activated_users,
  ROUND(
    100.0 * (SELECT COUNT(*) FROM activated)
    / NULLIF(COUNT(*), 0),
    2
  ) AS activation_rate_pct
FROM users;

-- Q09 — How long does it take users to reach first value?
-- Interpretation (synthetic): Median TTFV is 35.00 hours; average is 124.65 hours.
-- Decision use: The large mean-vs-median gap signals a slow-value tail worth diagnosing.
WITH first_value AS (
  SELECT
    u.user_id,
    u.created_at AS signup_at,
    MIN(e.occurred_at) AS first_value_at
  FROM users u
  JOIN profiles p
    ON p.user_id = u.user_id
   AND p.onboarding_completed
  JOIN product_events e
    ON e.user_id = u.user_id
   AND e.surface = 'Today'
   AND e.event_name IN ('task_completed', 'routine_completed')
  GROUP BY u.user_id, u.created_at
),
diff AS (
  SELECT
    EXTRACT(EPOCH FROM (first_value_at - signup_at)) / 3600.0 AS hours_to_value
  FROM first_value
)
SELECT
  COUNT(*) AS activated_users,
  ROUND(AVG(hours_to_value)::numeric, 2) AS avg_ttfv_hours,
  ROUND(
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY hours_to_value)::numeric,
    2
  ) AS median_ttfv_hours
FROM diff;

-- Q10 — How many Weekly Active Users (WAU) do we have?
-- Interpretation (synthetic): WAU rises as synthetic cohorts accumulate and later declines as the generated activity window matures.
-- Decision use: Compare broad activity with core-value behavior rather than using WAU alone.
SELECT
  date_trunc('week', occurred_at)::date AS week_start,
  COUNT(DISTINCT user_id) AS wau
FROM product_events
WHERE event_name <> 'onboarding_completed'
GROUP BY 1
ORDER BY 1;

-- Q11 — How many Weekly Core Value Users (WCVU) do we have?
-- Interpretation (synthetic): WCVU peaks at 25 users in the week of 2026-04-06.
-- Decision use: Track users receiving the product's defined core value, not merely generating events.
SELECT
  date_trunc('week', occurred_at)::date AS week_start,
  COUNT(DISTINCT user_id) AS wcvu
FROM product_events
WHERE surface = 'Today'
  AND event_name IN ('task_completed', 'routine_completed')
GROUP BY 1
ORDER BY 1;

-- Q12 — How deep is core-value, Routine and AI adoption?
-- Interpretation (synthetic): Routine Adoption among activated users = 64.71%;
-- AI Adoption = 41.18%; average Core Value Days per WCVU-week = 1.46.
-- Decision use: Separate breadth of activation from depth/recurrence of value.
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
core_days AS (
  SELECT
    user_id,
    date_trunc('week', occurred_at)::date AS week_start,
    COUNT(DISTINCT event_date) AS core_value_days
  FROM product_events
  WHERE surface = 'Today'
    AND event_name IN ('task_completed', 'routine_completed')
  GROUP BY user_id, date_trunc('week', occurred_at)::date
)
SELECT
  'Routine adoption among activated users' AS metric,
  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE EXISTS (SELECT 1 FROM routines r WHERE r.user_id = a.user_id)
    ) / NULLIF(COUNT(*), 0),
    2
  ) AS value
FROM activated a
UNION ALL
SELECT
  'AI adoption among activated users',
  ROUND(
    100.0 * COUNT(*) FILTER (
      WHERE EXISTS (
        SELECT 1
        FROM product_events e
        WHERE e.user_id = a.user_id
          AND e.surface = 'AI'
      )
    ) / NULLIF(COUNT(*), 0),
    2
  )
FROM activated a
UNION ALL
SELECT
  'Average core value days per WCVU-week',
  ROUND(AVG(core_value_days)::numeric, 2)
FROM core_days;

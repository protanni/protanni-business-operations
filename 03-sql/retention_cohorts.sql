-- PROTANNI — Retention & Cohort SQL
-- Dataset: fully synthetic. Results are portfolio evidence, not actual PROTANNI performance.

-- Q13 — What is D7 retention by signup cohort week?
-- Interpretation (synthetic): Weekly cohorts vary substantially, including 0%–100%, because several cohorts are small.
-- Decision use: Use cohort size alongside rate before drawing conclusions.
WITH cohort AS (
  SELECT
    user_id,
    created_at::date AS signup_date,
    date_trunc('week', created_at)::date AS cohort_week
  FROM users
),
flags AS (
  SELECT
    c.*,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = c.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN c.signup_date + 7 AND c.signup_date + 13
    ) AS retained_d7
  FROM cohort c
)
SELECT
  cohort_week,
  COUNT(*) AS cohort_size,
  COUNT(*) FILTER (WHERE retained_d7) AS retained_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d7)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d7_retention_pct
FROM flags
GROUP BY cohort_week
ORDER BY cohort_week;

-- Q14 — What is D30 retention by signup cohort month?
-- Interpretation (synthetic): Monthly D30 ranges from 50.00% to 64.29%.
-- Decision use: Compare mature cohorts over time without mixing users at different lifecycle ages.
WITH cohort AS (
  SELECT
    user_id,
    created_at::date AS signup_date,
    date_trunc('month', created_at)::date AS cohort_month
  FROM users
),
flags AS (
  SELECT
    c.*,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = c.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN c.signup_date + 30 AND c.signup_date + 36
    ) AS retained_d30
  FROM cohort c
)
SELECT
  cohort_month,
  COUNT(*) AS cohort_size,
  COUNT(*) FILTER (WHERE retained_d30) AS retained_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d30)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d30_retention_pct
FROM flags
GROUP BY cohort_month
ORDER BY cohort_month;

-- Q15 — Does activation correlate with D30 retention?
-- Interpretation (synthetic): Activated users show 82.35% D30 retention versus 6.90% for non-activated users.
-- Decision use: Treat activation as a leading indicator to validate on real post-launch data.
WITH base AS (
  SELECT
    u.user_id,
    u.created_at::date AS signup_date,
    (
      p.onboarding_completed
      AND EXISTS (
        SELECT 1
        FROM product_events e
        WHERE e.user_id = u.user_id
          AND e.surface = 'Today'
          AND e.event_name IN ('task_completed', 'routine_completed')
      )
    ) AS activated
  FROM users u
  JOIN profiles p USING (user_id)
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
  activated,
  COUNT(*) AS users,
  COUNT(*) FILTER (WHERE retained_d30) AS retained_d30_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d30)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d30_retention_pct
FROM flags
GROUP BY activated
ORDER BY activated DESC;

-- Q16 — Does Routine adoption correlate with D30 retention?
-- Interpretation (synthetic): Activated Routine adopters show 100.00% D30 versus 50.00% for activated non-adopters.
-- Decision use: Treat this as a hypothesis for real validation, not causal proof.
WITH activated AS (
  SELECT
    u.user_id,
    u.created_at::date AS signup_date
  FROM users u
  JOIN profiles p USING (user_id)
  WHERE p.onboarding_completed
    AND EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = u.user_id
        AND e.surface = 'Today'
        AND e.event_name IN ('task_completed', 'routine_completed')
    )
),
flags AS (
  SELECT
    a.*,
    EXISTS (SELECT 1 FROM routines r WHERE r.user_id = a.user_id) AS routine_adopter,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = a.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN a.signup_date + 30 AND a.signup_date + 36
    ) AS retained_d30
  FROM activated a
)
SELECT
  routine_adopter,
  COUNT(*) AS activated_users,
  COUNT(*) FILTER (WHERE retained_d30) AS retained_d30_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d30)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d30_retention_pct
FROM flags
GROUP BY routine_adopter
ORDER BY routine_adopter DESC;

-- Q17 — Does AI Feature Adoption correlate with D30 retention?
-- Interpretation (synthetic): Activated AI adopters show 85.71% D30 versus 80.00% for non-adopters.
-- Decision use: The small synthetic difference would not justify prioritization without real sample-size and causal analysis.
WITH activated AS (
  SELECT
    u.user_id,
    u.created_at::date AS signup_date
  FROM users u
  JOIN profiles p USING (user_id)
  WHERE p.onboarding_completed
    AND EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = u.user_id
        AND e.surface = 'Today'
        AND e.event_name IN ('task_completed', 'routine_completed')
    )
),
flags AS (
  SELECT
    a.*,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = a.user_id
        AND e.surface = 'AI'
    ) AS ai_adopter,
    EXISTS (
      SELECT 1
      FROM product_events e
      WHERE e.user_id = a.user_id
        AND e.event_name <> 'onboarding_completed'
        AND e.event_date BETWEEN a.signup_date + 30 AND a.signup_date + 36
    ) AS retained_d30
  FROM activated a
)
SELECT
  ai_adopter,
  COUNT(*) AS activated_users,
  COUNT(*) FILTER (WHERE retained_d30) AS retained_d30_users,
  ROUND(
    100.0 * COUNT(*) FILTER (WHERE retained_d30)
    / NULLIF(COUNT(*), 0),
    2
  ) AS d30_retention_pct
FROM flags
GROUP BY ai_adopter
ORDER BY ai_adopter DESC;

-- Q18 — What does the monthly retention matrix look like?
-- Interpretation (synthetic): The query demonstrates cohort indexing and recurring monthly activity.
-- Decision use: Use a matrix/heatmap later in Power BI to compare retention curves.
WITH cohorts AS (
  SELECT
    user_id,
    date_trunc('month', created_at)::date AS cohort_month
  FROM users
),
activity AS (
  SELECT DISTINCT
    user_id,
    date_trunc('month', occurred_at)::date AS activity_month
  FROM product_events
  WHERE event_name <> 'onboarding_completed'
),
cohort_sizes AS (
  SELECT cohort_month, COUNT(*) AS cohort_size
  FROM cohorts
  GROUP BY cohort_month
),
joined AS (
  SELECT
    c.user_id,
    c.cohort_month,
    a.activity_month,
    (
      (EXTRACT(YEAR FROM a.activity_month) - EXTRACT(YEAR FROM c.cohort_month)) * 12
      + EXTRACT(MONTH FROM a.activity_month)
      - EXTRACT(MONTH FROM c.cohort_month)
    )::int AS month_number
  FROM cohorts c
  JOIN activity a USING (user_id)
  WHERE a.activity_month >= c.cohort_month
)
SELECT
  j.cohort_month,
  j.month_number,
  COUNT(DISTINCT j.user_id) AS active_users,
  cs.cohort_size,
  ROUND(
    100.0 * COUNT(DISTINCT j.user_id)
    / NULLIF(cs.cohort_size, 0),
    2
  ) AS retention_pct
FROM joined j
JOIN cohort_sizes cs USING (cohort_month)
WHERE j.month_number BETWEEN 0 AND 5
GROUP BY j.cohort_month, j.month_number, cs.cohort_size
ORDER BY j.cohort_month, j.month_number;

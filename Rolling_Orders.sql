-- 1. Goal: Create a subtable of orders per day
SELECT 
  date(paid_at)                   AS day,
  COUNT(DISTINCT invoice_id)      AS orders,
  COUNT(DISTINCT line_item_id)    AS line_items
FROM 
  dsv1069.orders
GROUP BY 
  date(paid_at)

--------------------------------------------------------------------------------------
-- 2. GOAL: Daily rollup, Test your joins using dates_rollup


SELECT *
FROM
  dsv1069.dates_rollup
LEFT OUTER JOIN
  (
  SELECT 
    date(paid_at)                   AS day,
    COUNT(DISTINCT invoice_id)      AS orders,
    COUNT(DISTINCT line_item_id)    AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    date(paid_at)
  ) daily_orders
ON 
  daily_orders.day = dates_rollup.date
  
--------------------------------------------------------------------------------------

-- 3. GOAL: Daily rollup, Clean up columns

SELECT
  dates_rollup.date,
  COALESCE(SUM(orders), 0)          AS orders,
  COALESCE(SUM(items_ordered), 0)   AS items_ordered
FROM
  dsv1069.dates_rollup
LEFT OUTER JOIN
  (
  SELECT 
    date(paid_at)                   AS day,
    COUNT(DISTINCT invoice_id)      AS orders,
    COUNT(DISTINCT line_item_id)    AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    date(paid_at)
  ) daily_orders
ON 
  daily_orders.day = dates_rollup.date
GROUP BY
  dates_rollup.date
  
--------------------------------------------------------------------------------------

-- 4. GOAL: Weekly rollup check join

SELECT *
FROM
  dsv1069.dates_rollup
LEFT OUTER JOIN
  (
  SELECT 
    date(paid_at)                   AS day,
    COUNT(DISTINCT invoice_id)      AS orders,
    COUNT(DISTINCT line_item_id)    AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    date(paid_at)
  ) daily_orders
-- join on these two logical statement 
-- to get weekly rollup
ON 
  dates_rollup.date >= daily_orders.day
AND
  dates_rollup.d7_ago < daily_orders.day
GROUP BY
  dates_rollup.date,
  dates_rollup.d7_ago,
  dates_rollup.d28_ago,
  daily_orders.day,
  daily_orders.orders,
  daily_orders.items_ordered
  
--------------------------------------------------------------------------------------
-- 5. GOAL: Weekly rollup, clean columns

SELECT
  dates_rollup.date,
  COALESCE(SUM(orders), 0)          AS orders,
  COALESCE(SUM(items_ordered), 0)   AS items_ordered
  -- COUNT(*) AS rows
  -- uncomment the above code to check the days
FROM
  dsv1069.dates_rollup
LEFT OUTER JOIN
  (
  SELECT 
    date(paid_at)                   AS day,
    COUNT(DISTINCT invoice_id)      AS orders,
    COUNT(DISTINCT line_item_id)    AS items_ordered
  FROM 
    dsv1069.orders
  GROUP BY 
    date(paid_at)
  ) daily_orders
-- join on these two logical statement 
-- to get weekly rollup
ON 
  dates_rollup.date >= daily_orders.day
AND
  dates_rollup.d7_ago < daily_orders.day
GROUP BY
  dates_rollup.date
  
--------------------------------------------------------------------------------------


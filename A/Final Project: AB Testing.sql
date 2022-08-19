-- 1) Data Quality Check
--We are running an experiment at an item-level, which means all users who visit will see the same page, but the layout of different item pages may differ.
--Compare this table to the assignment events we captured for user_level_testing.
--Does this table have everything you need to compute metrics like 30-day view-binary?

-- NO
-- We still missing orders table

SELECT 
  * 
FROM 
  dsv1069.final_assignments_qa
  
-------------------------------------------------------------------------------------------------------------------------

-- 2) Reformat Data
--Reformat the final_assignments_qa to look like the final_assignments table, filling in any missing values with a placeholder of the appropriate data type.

-- Here we basically put the data in final_assignment_qa to column like in final_assignment table
-- we use a dummy date 
-- and the test assignment is the data of each test_number

SELECT item_id,
       test_a AS test_assignment,
       'test_a' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_b AS test_assignment,
       'test_b' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_c AS test_assignment,
       'test_c' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_d AS test_assignment,
       'test_d' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_e AS test_assignment,
       'test_e' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa
UNION ALL
SELECT item_id,
       test_f AS test_assignment,
       'test_f' AS test_number,
       CAST('2020-01-01 00:00:00' AS timestamp) AS dummy_test_start_date
FROM dsv1069.final_assignments_qa

-------------------------------------------------------------------------------------------------------------------------

-- 3) Compute order binary

-- Use this table to 
-- compute order_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
  order_binary.test_assignment,
  COUNT(DISTINCT order_binary.item_id)  AS num_orders,
  SUM(order_binary.orders_binary_30d)   AS sum_orders_binary_30d
FROM
  (
  SELECT 
    assignments.item_id,
    assignments.test_assignment,
    MAX(CASE WHEN
          (orders.created_at > assignments.test_start_date AND
          DATE_PART('day', orders.created_at - assignments.test_start_date) <= 30)
        THEN 1 ELSE 0 END) AS orders_binary_30d
  FROM 
    dsv1069.final_assignments AS assignments
  LEFT OUTER JOIN
    dsv1069.orders AS orders
    ON assignments.item_id = orders.item_id
  WHERE 
    assignments.test_number = 'item_test_2'
  GROUP BY
    assignments.item_id,
    assignments.test_assignment
    ) AS order_binary
GROUP BY
  order_binary.test_assignment
LIMIT 100

-------------------------------------------------------------------------------------------------------------------------

SELECT
  assignments.item_id,
  assignments.test_assignment,
  MAX(
    CASE
      WHEN (
        orders.created_at > assignments.test_start_date
        AND DATE_PART(
          'day',
          orders.created_at - assignments.test_start_date
        ) <= 30
      ) THEN 1
      ELSE 0
    END
  ) AS orders_binary_30d
FROM
  dsv1069.final_assignments AS assignments
  LEFT OUTER JOIN dsv1069.orders AS orders ON assignments.item_id = orders.item_id
WHERE
  assignments.test_number = 'item_test_2'
GROUP BY
  assignments.item_id,
  assignments.test_assignment
LIMIT 100

-------------------------------------------------------------------------------------------------------------------------

-- 4) Compute view item binary
-- Use this table to 
-- compute view_binary for the 30 day window after the test_start_date
-- for the test named item_test_2

SELECT
  view_binary.test_assignment,
  COUNT(item_id) AS items,
  SUM(view_binary.view_binary_30d)     AS viewed_items,
  CAST(100*SUM(view_binary.view_binary_30d)/COUNT(item_id) AS FLOAT) AS  viewed_percent,
  SUM(views) AS views,
  SUM(views)/COUNT(item_id) AS avg_views_per_item
FROM
  (
  SELECT 
    fa.item_id,
    fa.test_assignment,
    MAX(CASE WHEN
          views.event_time > fa.test_start_date THEN 1 ELSE 0 END) AS view_binary_30d,
    COUNT(views.event_id) AS views
  FROM 
    dsv1069.final_assignments AS fa
  LEFT OUTER JOIN
    (
    SELECT
      event_time,
      event_id,
      CAST(parameter_value AS int) AS item_id
    FROM 
      dsv1069.events
    WHERE
      event_name = 'view_item'
    AND
      parameter_name = 'item_id'
    ) views
    ON 
      fa.item_id = views.item_id
    AND
      views.event_time >= fa.test_start_date
    AND
      DATE_PART('day', views.event_time - fa.test_start_date) <= 30
  WHERE 
    fa.test_number = 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
    ) AS view_binary
GROUP BY
  view_binary.test_assignment

-------------------------------------------------------------------------------------------------------------------------

SELECT
  view_binary.test_assignment,
  COUNT(item_id) AS items,
  SUM(view_binary.view_binary_30d)     AS viewed_items
FROM
  (
  SELECT 
    fa.item_id,
    fa.test_assignment,
    MAX(CASE WHEN
          views.event_time > fa.test_start_date THEN 1 ELSE 0 END) AS view_binary_30d,
    COUNT(views.event_id) AS views
  FROM 
    dsv1069.final_assignments AS fa
  LEFT OUTER JOIN
    (
    SELECT
      event_time,
      event_id,
      CAST(parameter_value AS int) AS item_id
    FROM 
      dsv1069.events
    WHERE
      event_name = 'view_item'
    AND
      parameter_name = 'item_id'
    ) views
    ON 
      fa.item_id = views.item_id
    AND
      views.event_time >= fa.test_start_date
    AND
      DATE_PART('day', views.event_time - fa.test_start_date) <= 30
  WHERE 
    fa.test_number = 'item_test_2'
  GROUP BY
    fa.test_assignment,
    fa.item_id
    ) AS view_binary
GROUP BY
  view_binary.test_assignment
LIMIT 100

-------------------------------------------------------------------------------------------------------------------------

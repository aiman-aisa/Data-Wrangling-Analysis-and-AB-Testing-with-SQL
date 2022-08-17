-- 1. Count how many users we have

SELECT 
  COUNT(*)
FROM
  dsv1069.users;
  
-- 2. Find out how many users have ever ordered

SELECT 
  COUNT(DISTINCT user_id) AS users_with_orders
FROM
  dsv1069.orders
  
------------------------------------------------------------------------------------------

-- 2. find how many users have reordered the same item

SELECT
  COUNT(DISTINCT user_id) AS users_who_reordered
FROM
  (
  SELECT
    user_id,
    item_id,
    COUNT(DISTINCT line_item_id) AS times_user_ordered
  FROM
    dsv1069.orders
  GROUP BY
    user_id,
    item_id
  ) user_level_orders
WHERE times_user_ordered > 1

------------------------------------------------------------------------------------------

--3. Do users even order more than once?

SELECT
  COUNT(DISTINCT user_id)
FROM
  (
  SELECT
    user_id, 
    COUNT(DISTINCT invoice_id) AS order_count
  FROM
    dsv1069.orders
  GROUP BY
    user_id
  ) user_level
WHERE 
  order_count > 1
  
------------------------------------------------------------------------------------------

-- 4. Orders per item

SELECT
  item_id,
  COUNT(line_item_id) AS times_ordered
FROM 
  dsv1069.orders
GROUP BY 
  item_id
ORDER BY
  COUNT(line_item_id) DESC

------------------------------------------------------------------------------------------

-- 5. Orders per category

SELECT
  item_category,
  COUNT(line_item_id) AS times_ordered
FROM 
  dsv1069.orders
GROUP BY 
  item_category
ORDER BY
  COUNT(line_item_id) DESC

------------------------------------------------------------------------------------------

-- 6. Do user order multiple things from the same category?

SELECT
  item_category,
  AVG(times_category_ordered)
FROM
  (
  SELECT
    user_id,
    item_category,
    COUNT(DISTINCT line_item_id) AS times_category_ordered
  FROM
    dsv1069.orders
  GROUP BY
    user_id,
    item_category
  ) user_level
GROUP BY
  item_category
  
------------------------------------------------------------------------------------------

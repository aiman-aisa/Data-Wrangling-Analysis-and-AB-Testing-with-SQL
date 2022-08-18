-- Exercise 1: Using any methods you like determine if you can you trust this events table.

SELECT
  DATE(event_time) AS date,
  COUNT(*) AS Number_of_events
FROM
  dsv1069.events_201701 --WHERE event_time IS NULL
GROUP BY
  DATE(event_time) 
  -- no null values in any of the columns
  -- we found that there are 31 rows in the output
  -- which means that we don't have any missing events in Jan 2017
  
----------------------------------------------------------------------------------------------------
-- Exercise 2: Using any methods you like, determine if you can you trust this events table. (HINT: When did
-- we start recording events on mobile)

SELECT
  platform,
  MIN(date(event_time)) AS first_mobile
FROM
  dsv1069.events_ex2
WHERE
  platform = 'iOS'
  OR platform = 'Android'
  OR platform = 'mobile web'
GROUP BY
  platform
ORDER BY
  first_mobile 
  -- We found that we start recording events on mobile on 13th Jan 2013
  -- On Android on 1st Jan 2016 and on iOS on 1st May 2016
  
----------------------------------------------------------------------------------------------------
-- Exercise 3: Imagine that you need to count item views by day. You found this table
-- item_views_by_category_temp - should you use it to answer your question?

SELECT
  SUM(view_events)
FROM
  dsv1069.item_views_by_category_temp;
  
-- this table does not have dates
-- total item view events is 14481

-- check with the main events table
SELECT
  COUNT(DISTINCT (event_id)) AS Num_of_event
FROM
  dsv1069.events
WHERE
  event_name = 'view_item' 
  -- we found total distinct event id is 262786 which is much higher
  -- so it is not a good idea to use the dsv1069.item_views_by_category_temp table
  
----------------------------------------------------------------------------------------------------
-- Exercise 4: Is this the right way to join orders to users? Is this the right way this join.
--First check if the joined queries has the same number of rows as in the single table 

SELECT
  COUNT(*)
FROM
  dsv1069.orders
  JOIN dsv1069.users ON orders.user_id = users.parent_user_id;
-- Output:
-- Num rows = 2604

SELECT
  COUNT(*)
FROM
  dsv1069.orders;
-- Output:
-- Num rows = 47402 (much larger)

-- Hence, the join statement above is not the right way
-- this is because might be there's null values on both table 
-- which makes the table small

-- use COALESCE statement
SELECT
  COUNT(*)
FROM
  dsv1069.orders
  JOIN dsv1069.users 
  -- this means that if the user_id does not have parent_user_id, join the table using
  -- users.id
  ON orders.user_id = COALESCE(users.parent_user_id, users.id) 
  -- which output has 47310 rows, closer to the orders num of rows.
  
  

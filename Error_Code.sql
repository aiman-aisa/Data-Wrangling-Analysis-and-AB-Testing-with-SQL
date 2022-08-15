--1) Here we use users table to pull a list of user email addresses. Edit the query to pull email
-- addresses, but only for non-deleted users.

SELECT
  id,
  email_address
FROM
  dsv1069.users
WHERE
  deleted_at IS NULL;
  
-- 2) Use the items table to count the number of items for sale in each category
SELECT
  category,
  COUNT(id) AS item_count
FROM
  dsv1069.items
GROUP BY
  category
ORDER BY
  item_count DESC;
  
--3) Select all of the columns from the result when you JOIN the users table to the orders table

SELECT
  *
FROM
  dsv1069.users U
  JOIN dsv1069.orders O ON U.id = O.user_id;
  
-- 4) Check out the query below. This is not the right way to count the number of viewed_item
-- events. Determine what is wrong and correct the error.

SELECT
  COUNT(DISTINCT(event_id)) AS EVENTS
FROM
  dsv1069.events
WHERE
  event_name = 'view_item';
  
-- 5) Compute the number of items in the items table which have been ordered. The query
--below runs, but it isn’t right. Determine what is wrong and correct the error or start from scratch.

SELECT
  COUNT(DISTINCT(item_id)) AS Item_count
FROM
  dsv1069.orders;
  
--6) For each user figure out IF a user has ordered something, and when their first purchase was. 
--The query below doesn’t return info for any of the users who haven’t ordered anything.

SELECT
  U.id,
  MIN(O.paid_at)
FROM
  dsv1069.users U
  LEFT OUTER JOIN dsv1069.orders O ON U.id = O.user_id
GROUP BY
  U.id;
  
-- 7) Figure out what percent of users have ever viewed the user profile page.

SELECT
  (
    CASE
      WHEN first_view IS NULL THEN false
      ELSE TRUE
    END
  ) AS has_viewed_profile_page,
  COUNT(id) AS users
FROM
  (
    SELECT
      U.id,
      MIN(event_time) AS first_view
    FROM
      dsv1069.users U
      LEFT OUTER JOIN dsv1069.events E ON U.id = E.user_id
      AND event_name = 'view_user_profile'
    GROUP BY
      U.id
  ) first_profile_view
GROUP BY
  (
    CASE
      WHEN first_view IS NULL THEN false
      ELSE TRUE
    END
  );

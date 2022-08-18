-- Exercise 1: We’ll be using the users table to answer the question “How many new users are
--added each day?“. Start by making sure you understand the columns in the table.

-- 1) Explore the data
SELECT
  id,
  parent_user_id,
  merged_at
FROM dsv1069.users
ORDER BY parent_user_id ASC

-------------------------------------------------------------------------------------------------------------

--Exercise 2: WIthout worrying about deleted user or merged users, count the number of users
--added each day.
-- 2) Simplest solution

SELECT
  DATE(created_at) AS day,
  COUNT(*) AS users
FROM
  dsv1069.users
GROUP BY
  day
  

-------------------------------------------------------------------------------------------------------------

-- Exercise 3: Consider the following query. Is this the right way to count merged or deleted
--users? If all of our users were deleted tomorrow what would the result look like?

-- 3) Better but still problematic

SELECT
  DATE(created_at) AS day,
  COUNT(*) AS users
FROM
  dsv1069.users
WHERE
  deleted_at IS NULL
AND
  (id <> parent_user_id OR parent_user_id IS NULL)
GROUP BY
  day
  
  
-------------------------------------------------------------------------------------------------------------

--Exercise 4: Count the number of users deleted each day. Then count the number of users
--removed due to merging in a similar way.
--4) Count deleted user

SELECT
  DATE(deleted_at) AS day,
  COUNT(*) AS deleted_users
FROM
  dsv1069.users
WHERE 
  deleted_at IS NOT NULL
GROUP BY
  day
  
  
-------------------------------------------------------------------------------------------------------------

-- Exercise 5: Use the pieces you’ve built as subtables and create a table that has a column for
--the date, the number of users created, the number of users deleted and the number of users
--merged that day.
-- 5) Complete solution
SELECT
  new.day,
  new.new_users_added,
  deleted.deleted_users,
  merged.merged_users
FROM
  -- a subquery which count all users each day regardless of deleted or merged
  (
    SELECT
      DATE(created_at) AS DAY,
      COUNT(*) AS new_users_added
    FROM
      dsv1069.users
    GROUP BY
      date(created_at)
  ) new -- JOIN with counted deleted users
  LEFT JOIN (
    SELECT
      DATE(deleted_at) AS DAY,
      COUNT(*) AS deleted_users
    FROM
      dsv1069.users
    WHERE
      deleted_at IS NOT NULL
    GROUP BY
      date(deleted_at)
  ) deleted 
  ON deleted.day = new.day -- matching deleted day with new day
  -- because we wanna compare how many users we added and how many old users we deleted
-- then join with the merged users
LEFT JOIN
(SELECT
    date(merged_at) AS day,
    COUNT(*) AS merged_users
  FROM
    dsv1069.users
  WHERE
    id <> parent_user_id
  AND
    parent_user_id IS NOT NULL
  GROUP BY 
    date(merged_at)
  ) merged 
ON merged.day = new.day


-------------------------------------------------------------------------------------------------------------

-- Refine your query from #5 to have informative column names and so that null
--columns return 0.

--6) Complete answers
SELECT
  new.day,
  new.new_users_added,
  COALESCE(deleted.deleted_users, 0) AS deleted_users,
  COALESCE(merged.merged_users, 0) AS merged_users,
  (new.new_users_added - COALESCE(deleted.deleted_users, 0) - COALESCE(merged.merged_users, 0))
  AS net_added_users
FROM
  -- a subquery which count all users each day regardless of deleted or merged
  (
    SELECT
      DATE(created_at) AS DAY,
      COUNT(*) AS new_users_added
    FROM
      dsv1069.users
    GROUP BY
      date(created_at)
  ) new -- JOIN with counted deleted users
  LEFT JOIN (
    SELECT
      DATE(deleted_at) AS DAY,
      COUNT(*) AS deleted_users
    FROM
      dsv1069.users
    WHERE
      deleted_at IS NOT NULL
    GROUP BY
      date(deleted_at)
  ) deleted 
  ON deleted.day = new.day -- matching deleted day with new day
  -- because we wanna compare how many users we added and how many old users we deleted
-- then join with the merged users
LEFT JOIN
(SELECT
    date(merged_at) AS day,
    COUNT(*) AS merged_users
  FROM
    dsv1069.users
  WHERE
    id <> parent_user_id
  AND
    parent_user_id IS NOT NULL
  GROUP BY 
    date(merged_at)
  ) merged 
ON merged.day = new.day
ORDER BY new.day
-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------

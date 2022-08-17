-- 1. Ranked user views

SELECT  
  user_id,
  item_id, 
  event_time,
  ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC)
    AS view_number
FROM
  dsv1069.view_item_events
  
  ---------------------------------------------------------------------------
  
  -- 2. Skeleton Query. Join recent_views with users and items table
SELECT 
  *
FROM  
  (
  SELECT  
    user_id,
    item_id, 
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC)
      AS view_number
  FROM
    dsv1069.view_item_events
  ) AS recent_views
JOIN
  dsv1069.users
ON
  users.id = recent_views.user_id
JOIN
  dsv1069.items
ON
  items.id = recent_views.item_id
  
  ---------------------------------------------------------------------------
  
  -- 3. Clean up query outline and pull only the columns needed
/*The goal of all this is to return all of the information we’ll
need to send users an email about the item they viewed more recently. Clean up this query
outline from the outline in EX2 and pull only the columns you need. Make sure they are named
appropriately so that another human can read and understand their contents.
*/

SELECT 
  users.id              AS user_id,
  users.email_address,
  items.id              AS item_id,
  items.name            AS item_name,
  items.category        AS item_category
FROM  
  (
  SELECT  
    user_id,
    item_id, 
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC)
      AS view_number
  FROM
    dsv1069.view_item_events
  ) AS recent_views
JOIN
  dsv1069.users
ON
  users.id = recent_views.user_id
JOIN
  dsv1069.items
ON
  items.id = recent_views.item_id
  
  ---------------------------------------------------------------------------
  
  -- 4. Fine tuning
/* If we sent an email to everyone in the results of this
query, what would we want to filter out. Add in any extra filtering that you think would make this
email better. For example should we include deleted users? Should we send this email to users
who already ordered the item they viewed most recently?*/

SELECT 
  COALESCE(users.parent_user_id, users.id)              AS user_id,
  users.email_address,
  items.id                                              AS item_id,
  items.name                                            AS item_name,
  items.category                                        AS item_category
FROM  
  (
  SELECT  
    user_id,
    item_id, 
    event_time,
    ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY event_time DESC)
      AS view_number
  FROM
    dsv1069.view_item_events
    WHERE
      event_time > '2017-01-01'
  ) AS recent_views
JOIN
  dsv1069.users
ON
  users.id = recent_views.user_id
JOIN
  dsv1069.items
ON
  items.id = recent_views.item_id
LEFT OUTER JOIN
  dsv1069.orders
ON 
  orders.item_id = recent_views.item_id
AND
  orders.user_id = recent_views.user_id
WHERE 
  view_number = 1
AND 
  users.deleted_at IS NOT NULL -- to not include to sent email deleted user
AND 
  orders.item_id IS NULL 
  
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  

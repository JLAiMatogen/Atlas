--Cleanup Client Duplicates
WITH ranked_clients AS (
  SELECT ctid, ROW_NUMBER() OVER (PARTITION BY "ClientId" ORDER BY ctid) AS rn
  FROM "Client"
)
DELETE FROM "Client"
WHERE ctid IN (
  SELECT ctid FROM ranked_clients WHERE rn > 1
);
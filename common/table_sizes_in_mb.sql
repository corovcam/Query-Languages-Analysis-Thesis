SELECT
  TABLE_NAME AS `Table`,
  ROUND((DATA_LENGTH + INDEX_LENGTH) / 1024) AS `Size (kB)`
FROM
  information_schema.TABLES
WHERE
    TABLE_SCHEMA = "ecommerce"
ORDER BY
  (DATA_LENGTH + INDEX_LENGTH)
DESC;
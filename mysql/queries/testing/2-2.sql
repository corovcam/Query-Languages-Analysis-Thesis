-- 2.2 MAX

-- Find the most expensive product per brand
SELECT brand, MAX(price) AS maxPrice
FROM Product
GROUP BY brand;
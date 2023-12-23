-- 2.1 COUNT

-- Count the number of products per brand
SELECT brand, COUNT(*) AS productCount
FROM Product
GROUP BY brand;
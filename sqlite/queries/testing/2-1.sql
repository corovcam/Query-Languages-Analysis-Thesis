.timer on

-- 2.1 COUNT

SELECT brand, COUNT(*) AS productCount
FROM Product
GROUP BY brand;
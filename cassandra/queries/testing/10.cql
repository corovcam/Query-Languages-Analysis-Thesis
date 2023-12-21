tracing on;
capture '/dev/null';

-- 10. Distinct

-- Find unique combinations of product brands and the countries of the vendors selling those products

SELECT brand, country
FROM Vendor_Countries_By_Product_Brand;
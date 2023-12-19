.timer on

-- 10. Distinct

-- Find unique combinations of product brands and the countries of the vendors selling those products

SELECT DISTINCT Product.brand, Vendor.country
FROM Product
         JOIN Vendor_Products ON Product.productId = Vendor_Products.productId
         JOIN Vendor ON Vendor_Products.vendorId = Vendor.vendorId
ORDER BY Product.brand, Vendor.country;
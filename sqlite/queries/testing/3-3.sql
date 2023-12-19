.timer on

-- 3.3 Complex Join 1

-- Complex query with JOINS to retrieve order details
SELECT *
FROM `Order` o
         JOIN
     Customer c ON o.customerId = c.customerId
         JOIN
     Person p ON c.personId = p.personId
         JOIN
     Order_Products op ON o.orderId = op.orderId
         JOIN
     Product pr ON op.productId = pr.productId
         JOIN
     Vendor_Products vp ON pr.productId = vp.productId
         JOIN
     Vendor v ON vp.vendorId = v.vendorId;
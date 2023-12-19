.timer on

-- 3.2 Indexed Columns

SELECT *
FROM Product P
         INNER JOIN Order_Products OP on P.productId = OP.productId;
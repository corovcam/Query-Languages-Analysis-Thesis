// 9. Sorting

// 9.2 Indexed property

CREATE INDEX idx_product_productId IF NOT EXISTS FOR (p:Product) ON (p.productId);

PROFILE
MATCH (pr:Product)
RETURN pr.productId
  ORDER BY pr.productId;
// 9. Sorting

// 9.1 Non-Indexed property

PROFILE
MATCH (pr:Product)
RETURN pr.brand
  ORDER BY pr.brand;
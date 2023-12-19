// 1.3 Indexed Selection

PROFILE
MATCH (n:Vendor)
  WHERE n.vendorId = 24
RETURN n.vendorId, n.name;
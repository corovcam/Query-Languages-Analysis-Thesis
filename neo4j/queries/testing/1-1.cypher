// 1. Selection, Projection, Source (of data)

// 1.1 Non-Indexed Selection

PROFILE
MATCH (v:Vendor)
  WHERE v.name = 'Bauch - Denesik'
RETURN v.vendorId, v.name;
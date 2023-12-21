// 8. Difference

// Find people who have not made any orders
PROFILE
MATCH (p:Person)
  WHERE NOT (p)<-[:IS_PERSON]-(:Customer)<-[:ORDERED_BY]-(:Order)
RETURN p.personId, p.firstName, p.lastName;

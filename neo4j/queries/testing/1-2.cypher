// 1.2 Non-Indexed Selection - Range Query

DROP INDEX idx_person_birthday IF EXISTS;

PROFILE
MATCH (p:Person)
  WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
RETURN p.personId, p.firstName, p.lastName, p.birthday;
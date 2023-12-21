// 1.4 Indexed Selection - Range Query

CREATE INDEX idx_person_birthday IF NOT EXISTS FOR (p:Person) ON (p.birthday);

PROFILE
MATCH (p:Person)
  WHERE p.birthday >= date('1980-01-01') AND p.birthday <= date('1990-12-31')
RETURN p.personId, p.firstName, p.lastName, p.birthday;
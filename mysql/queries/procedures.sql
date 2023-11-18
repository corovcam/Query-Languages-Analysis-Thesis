DROP PROCEDURE IF EXISTS create_birthday_index_if_not_exists;
DROP PROCEDURE IF EXISTS drop_birthday_index_if_exists;

DELIMITER //
CREATE PROCEDURE IF NOT EXISTS create_birthday_index_if_not_exists ()
BEGIN
    IF (SELECT 1
    FROM `INFORMATION_SCHEMA`.`STATISTICS`
    WHERE `TABLE_SCHEMA` = 'ecommerce'
    AND `TABLE_NAME` = 'Person'
    AND `INDEX_NAME` = 'idx_person_birthday') IS NULL THEN

    CREATE INDEX idx_person_birthday ON Person (birthday);

    END IF;
END //
DELIMITER ;


DELIMITER //
CREATE PROCEDURE IF NOT EXISTS drop_birthday_index_if_exists ()
BEGIN
    IF (SELECT 1
    FROM `INFORMATION_SCHEMA`.`STATISTICS`
    WHERE `TABLE_SCHEMA` = 'ecommerce'
    AND `TABLE_NAME` = 'Person'
    AND `INDEX_NAME` = 'idx_person_birthday') IS NOT NULL THEN

    Alter Table Person DROP Index idx_person_birthday;

    END IF;
END //
DELIMITER ;
-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    personcenter ||'p'|| personid AS personid,
    name,
    txtvalue
FROM
    PERSON_EXT_ATTRS
WHERE
    name = 'show_online'
    AND txtvalue = 'true'
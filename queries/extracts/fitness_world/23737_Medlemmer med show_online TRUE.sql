-- This is the version from 2026-02-05
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
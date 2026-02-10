-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    any_club_in_scope AS
    (
        SELECT id 
          FROM centers 
         WHERE id IN ($$scope$$)
           AND rownum = 1
    )
    , params AS
    (
        SELECT
            /*+ materialize  */
            datetolongC(TO_CHAR(TRUNC(exerpsysdate())-5, 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS FROMDATE,
            datetolongC(TO_CHAR(TRUNC(exerpsysdate()), 'YYYY-MM-DD HH24:MI'), any_club_in_scope.id) AS TODATE
        FROM
            dual
        CROSS JOIN any_club_in_scope
    )
SELECT
    p.PERSON_ID
  , p.HOME_CENTER_ID
  , p.HOME_CENTER_PERSON_ID
  , p.FULL_NAME
  , p.COUNTRY_ID
  , p.POSTAL_CODE
  , p.CITY
  , p.DATE_OF_BIRTH
  , p.GENDER
  , p.PERSON_TYPE
  , p.PERSON_STATUS
  , p.CREATION_DATE
  , p.PAYER_PERSON_ID
  , p.COMPANY_ID
  , p.ETS
FROM
    BI_PERSONS p
CROSS JOIN
    PARAMS
WHERE
    p.HOME_CENTER_ID in ($$scope$$)
    AND p.ETS >= PARAMS.FROMDATE
    AND p.ETS < PARAMS.TODATE
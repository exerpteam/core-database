 WITH
     params AS
     (
         SELECT
             /*+ materialize */
             to_date($$StartDate$$,'YYYY-MM-DD')                    AS PeriodStart,
             to_date($$EndDate$$,'YYYY-MM-DD')                      AS PeriodEnd
     )
 SELECT
     p.center || 'p' || p.id AS PERSON_KEY,
     c.name AS CLUB,
     pea.txtvalue AS PROMOTION,
     (CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'Undefined'
    END) AS PERSON_STATUS,
     --pea2.txtvalue AS creation_date,
     --TO_CHAR(pea2.txtvalue, 'dd/MM/yyyy') AS creation_date2
     to_char(to_date(pea2.txtvalue, 'YYYY-MM-DD'), 'dd/MM/yyyy') AS CREATION_DATE
 FROM
     params, persons p
 JOIN centers c
 ON c.id = p.center
 LEFT JOIN
     person_ext_attrs pea
 ON
     pea.personcenter = p.center
 AND pea.personid = p.id
 AND pea.name = 'Promotion'
 JOIN
     person_ext_attrs pea2
 ON
     pea2.personcenter = p.center
 AND pea2.personid = p.id
 AND pea2.name = 'CREATION_DATE'
 WHERE
     p.CENTER IN ($$scope$$)
 AND p.external_id IS NOT NULL
 AND to_date(pea2.txtvalue, 'YYYY-MM-DD') BETWEEN params.PeriodStart AND params.PeriodEnd
 AND (
         ($$Promotion$$ = 'ALL PROMOTIONS')
         OR
         ($$Promotion$$ != 'ALL PROMOTIONS' AND $$Promotion$$ = pea.txtvalue)
     )

-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT t.PersonId,t.LegacyMemberId,t.STATE, t.EXTERNAL_ID,
trim(SUBSTR(t.SUB_COMMENT, POSITION(':' IN t.SUB_COMMENT)+1, POSITION('InvoiceAtId:' IN t.SUB_COMMENT)-POSITION(':' IN t.SUB_COMMENT)-1 )) AS MembershipID,
t.OWNER_CENTER,t.SUBSCRIPTION_PRICE,t.START_DATE,t.END_DATE,t.BILLED_UNTIL_DATE,t.INVOICELINE_CENTER,t.GLOBAL_ID,t.MigratedDate
FROM
(
SELECT DISTINCT
    CURPERS.center || 'p' || CURPERS.id AS PersonId,
    pea.txtvalue                        AS LegacyMemberId,
    CASE S.STATE
        WHEN 2
        THEN 'ACTIVE'
        WHEN 3
        THEN 'ENDED'
        WHEN 4
        THEN 'FROZEN'
        WHEN 7
        THEN 'WINDOW'
        WHEN 8
        THEN 'CREATED'
        ELSE 'UNKNOWN'
    END AS STATE,
    CURPERS.EXTERNAL_ID                                                                                                                        AS EXTERNAL_ID,
    regexp_replace(s.SUB_COMMENT,  E'[\\n\\r]+', ' ', 'g' ) as SUB_COMMENT,	
    S.OWNER_CENTER                                                                                                                             AS OWNER_CENTER,
    S.SUBSCRIPTION_PRICE                                                                                                                       AS SUBSCRIPTION_PRICE,
    S.START_DATE                                                                                                                               AS START_DATE,
    S.END_DATE                                                                                                                                 AS END_DATE,
    S.BILLED_UNTIL_DATE                                                                                                                        AS BILLED_UNTIL_DATE,
    S.INVOICELINE_CENTER                                                                                                                       AS INVOICELINE_CENTER,
    PR.GLOBALID                                                                                                                                AS GLOBAL_ID,
	TO_CHAR(longtodatec(je.creation_time, je.person_center), 'dd-MM-yyyy HH24:MI') AS MigratedDate	
FROM
    SUBSCRIPTIONS AS S
JOIN
    journalentries je
ON
    je.person_center = S.OWNER_CENTER
    AND je.person_id = S.OWNER_ID
    AND je.name = 'Person created'
JOIN
    person_ext_attrs pea
ON
    S.OWNER_CENTER = pea.personcenter
    AND S.OWNER_ID = pea.personid
    AND pea.name='_eClub_OldSystemPersonId'
    AND pea.txtvalue IS NOT NULL
LEFT JOIN
    PERSONS AS P
ON
    P.CENTER = S.OWNER_CENTER
    AND P.ID = S.OWNER_ID
LEFT JOIN
    PRODUCTS AS PR
ON
    PR.CENTER = S.SUBSCRIPTIONTYPE_CENTER
    AND PR.ID = S.SUBSCRIPTIONTYPE_ID
LEFT JOIN
    PERSONS AS CURPERS
ON
    CURPERS.CENTER = P.CURRENT_PERSON_CENTER
    AND CURPERS.ID = P.CURRENT_PERSON_ID
WHERE
    P.CENTER IN ($$Scope$$)
)t	
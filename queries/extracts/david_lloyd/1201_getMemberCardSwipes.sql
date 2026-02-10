-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    params AS
    (SELECT
        c.id
        , datetolongc($$fromDate$$, c.id) AS from_Datetime_long
        , datetolongc($$toDate$$, c.id) AS to_Datetime_long
    FROM
        centers c
    WHERE
        c.id = $$siteId$$
    )
SELECT
    ch.checkin_center                                 AS "siteId"
    ,COALESCE(legacyPersonId.txtvalue,cp.external_id) AS "contactId"
    ,to_char(longtodatec(ch.checkin_time,ch.checkin_center),'YYYY-MM-DD hh24:mi:ss')   AS "accessTime"
    ,to_char(longtodatec(ch.last_modified,ch.checkin_center),'YYYY-MM-DD hh24:mi:ss')AS "createdOnTime"
    ,NULL                                             AS "membersServiceFetchedTime" 
FROM
    checkins ch
JOIN
    params
ON
    params.id = ch.checkin_center
    AND ch.last_modified BETWEEN params.from_Datetime_long AND params.to_Datetime_long
JOIN
    persons p
ON
    p.center = ch.person_center
AND p.id = ch.person_id
JOIN
    persons cp
ON
    cp.center = p.transfers_current_prs_center
AND cp.id = p.transfers_current_prs_id
LEFT JOIN
    PERSON_EXT_ATTRS legacyPersonId
ON
    p.center=legacyPersonId.PERSONCENTER
AND p.id=legacyPersonId.PERSONID
AND legacyPersonId.name='_eClub_OldSystemPersonId'
-- This is the version from 2026-02-05
--  
 WITH
     params AS Materialized
     (
SELECT
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI' ) ) - 1000*60*60*24* $$offset$$
            AS bigint) AS FROMDATE,
            CAST(datetolong(TO_CHAR(CURRENT_DATE, 'yyyy-MM-dd HH24:MI') ) + 1000*60*60*24 AS bigint)
            AS TODATE
     )
 SELECT
     biview.*
 FROM
     params,
     	( SELECT p.external_id AS "PERSON_ID", p.address1 AS "ADDRESS1", p.address2 AS "ADDRESS2", p.address3 AS "ADDRESS3", pea1.txtvalue AS "WORK_PHONE", pea2.txtvalue AS "MOBILE_PHONE", pea3.txtvalue AS "HOME_PHONE", pea4.txtvalue AS "EMAIL", p.fullname AS "FULL_NAME", p.firstname AS "FIRSTNAME", p.lastname AS "LASTNAME", p.center AS "CENTER_ID", p.last_modified AS "ETS" FROM ((((persons p LEFT JOIN person_ext_attrs pea1 ON ((((pea1.name)::text = '_eClub_PhoneWork'::text) AND (pea1.personcenter = p.center) AND (pea1.personid = p.id)))) LEFT JOIN person_ext_attrs pea2 ON ((((pea2.name)::text = '_eClub_PhoneSMS'::text) AND (pea2.personcenter = p.center) AND (pea2.personid = p.id)))) LEFT JOIN person_ext_attrs pea3 ON ((((pea3.name)::text = '_eClub_PhoneHome'::text) AND (pea3.personcenter = p.center) AND (pea3.personid = p.id)))) LEFT JOIN person_ext_attrs pea4 ON ((((pea4.name)::text = '_eClub_Email'::text) AND (pea4.personcenter = p.center) AND (pea4.personid = p.id)))) WHERE (((p.sex)::text <> 'C'::text) AND (p.external_id IS NOT NULL) AND (p.center = p.transfers_current_prs_center) AND (p.id = p.transfers_current_prs_id)) ) biview
 WHERE
     biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
 and biview."CENTER_ID" in ($$scope$$)

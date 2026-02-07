WITH
    params AS
    (
        SELECT
            CASE
                WHEN $$offset$$ = -1
                THEN 0
                ELSE datetolong(TO_CHAR(CURRENT_DATE - interval '1 day'*$$offset$$,
                    'yyyy-MM-dd HH24:MI' ) )
            END                                                                         AS FROMDATE,
            datetolong(TO_CHAR(CURRENT_DATE + interval '1 day', 'yyyy-MM-dd HH24:MI') ) AS TODATE
    )
SELECT
    "PERSON_ID",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("ADDRESS1",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),
    '"','[qt]'), '''' , '') AS "ADDRESS1",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("ADDRESS2",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),
    '"','[qt]'), '''' , '') AS "ADDRESS2",
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE("ADDRESS3",CHR(13), '[CR]'), CHR(10), '[LF]'),';',''),
    '"','[qt]'), '''' , '') AS "ADDRESS3",
    "WORK_PHONE",
    "MOBILE_PHONE",
    "HOME_PHONE",
    "EMAIL",
    "CENTER_ID"
FROM
    params,
    (
        SELECT
            p.external_id   AS "PERSON_ID",
            p.address1      AS "ADDRESS1",
            p.address2      AS "ADDRESS2",
            p.address3      AS "ADDRESS3",
            pea1.txtvalue   AS "WORK_PHONE",
            pea2.txtvalue   AS "MOBILE_PHONE",
            pea3.txtvalue   AS "HOME_PHONE",
            pea4.txtvalue   AS "EMAIL",
            p.fullname      AS "FULL_NAME",
            p.firstname     AS "FIRSTNAME",
            p.lastname      AS "LASTNAME",
            p.center        AS "CENTER_ID",
            p.last_modified AS "ETS"
        FROM
            ((((persons p
        LEFT JOIN
            person_ext_attrs pea1
        ON
            ((((
                            pea1.name)::text = '_eClub_PhoneWork'::text)
                AND (
                        pea1.personcenter = p.center)
                AND (
                        pea1.personid = p.id))))
        LEFT JOIN
            person_ext_attrs pea2
        ON
            ((((
                            pea2.name)::text = '_eClub_PhoneSMS'::text)
                AND (
                        pea2.personcenter = p.center)
                AND (
                        pea2.personid = p.id))))
        LEFT JOIN
            person_ext_attrs pea3
        ON
            ((((
                            pea3.name)::text = '_eClub_PhoneHome'::text)
                AND (
                        pea3.personcenter = p.center)
                AND (
                        pea3.personid = p.id))))
        LEFT JOIN
            person_ext_attrs pea4
        ON
            ((((
                            pea4.name)::text = '_eClub_Email'::text)
                AND (
                        pea4.personcenter = p.center)
                AND (
                        pea4.personid = p.id))))
        WHERE
            (((
                        p.sex)::text <> 'C'::text)
            AND (
                    p.external_id IS NOT NULL)
            AND (
                    p.center = p.transfers_current_prs_center)
            AND (
                    p.id = p.transfers_current_prs_id)) ) biview
WHERE
    biview."ETS" BETWEEN PARAMS.FROMDATE AND PARAMS.TODATE
AND biview."CENTER_ID" IN ($$scope$$)
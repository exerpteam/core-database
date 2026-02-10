-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/browse/ST-12703
WITH
    params AS MATERIALIZED
    (
        SELECT
            $$StartDate$$       AS FromDateTime,
            $$EndDate$$			AS ToDateTime
        FROM
            dual
    )
SELECT
    p.external_id           AS "External Id",
    p.center || 'p' || p.id AS "PersonId",
    p.firstname             AS "First Name",
    p.lastname              AS "Last Name",
    p.address1              AS "Address Line 1",
    p.address2              AS "Address Line 2",
    p.address3              AS "Address Line 3",
    p.zipcode               AS "Post Code",
    home.txtvalue           AS "Home Number",
    mobile.txtvalue         AS "Mobile Number",
    email.txtvalue          AS "Email Address",
    'true'                  AS "Track And Trace"
FROM
    persons p
CROSS JOIN
    params
LEFT JOIN
    person_ext_attrs pe
ON
    pe.personcenter = p.center
    AND pe.personid = p.id
    AND pe.name = 'TRACKTRACE'
	AND pe.txtvalue = 'false'
LEFT JOIN
    person_ext_attrs home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    person_ext_attrs mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    person_ext_attrs email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
WHERE
    p.center IN ($$Scope$$)
	/* pe.personcenter is null means either deafult value true or pe.txtvalue = 'true' */
	AND pe.personcenter is null 
    AND p.status IN (1,3)
    AND EXISTS
    (
        SELECT
            1
        FROM
            checkins ch
        WHERE
            ch.person_center = p.center
            AND ch.person_id = p.id
            AND ch.checkin_time <= params.ToDateTime
            AND ch.checkout_time >= params.FromDateTime)
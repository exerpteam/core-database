 WITH
            params AS
            (
                SELECT
                    c.id   AS CENTERID,
                    c.name AS center_name,
                    cast(datetolongTZ(to_char(TO_date($$CheckIn_From$$,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) as BIGINT) AS FROMDATE,
                    cast(datetolongTZ(to_char(TO_date($$CheckIn_To$$,'YYYY-MM-DD HH24:MI:SS')+INTERVAL'1 DAYS','YYYY-MM-DD HH24:MI:SS'), c.time_zone)-1 as BIGINT)AS TODATE
                FROM
                    centers c
                WHERE c.id IN ($$Scope$$)
            )
SELECT DISTINCT
    c.name                              AS "Center",
    ch.person_center||'p'||ch.person_id AS "Person ID",
    p.firstname                         AS "First Name",
    p.lastname                          AS "Last Name",
    CASE WHEN ch.person_type = 0 THEN 'PRIVATE' WHEN ch.person_type= 1 THEN 'STUDENT' WHEN ch.person_type = 2 THEN 'STAFF' WHEN ch.person_type= 3 THEN 'FRIEND' WHEN ch.person_type= 4 THEN 'CORPORATE' WHEN ch.person_type= 5 THEN 'ONEMANCORPORATE' WHEN ch.person_type= 6 THEN 'FAMILY' WHEN ch.person_type= 7 THEN 'SENIOR' WHEN ch.person_type= 8 THEN 'GUEST' WHEN ch.person_type= 9 THEN 'CHILD' WHEN ch.person_type= 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS "Person Type",
    CASE p.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Person Status",
    to_char(longtodatec(ch.checkin_time,ch.checkin_center),'FMDay') AS "Check In Day",
    TO_CHAR(longtodatec(ch.checkin_time,ch.checkin_center),'mm/dd/yyyy hh12:mm:ss') AS "Check In Time",
    CASE WHEN IDENTITY_METHOD = 1 THEN 'Barcode' WHEN IDENTITY_METHOD = 2 THEN 'MagneticCard' WHEN IDENTITY_METHOD = 4 THEN 'RFCard' WHEN IDENTITY_METHOD = 5 THEN 'Pin' WHEN IDENTITY_METHOD = 6 THEN 'AntiDrown' WHEN IDENTITY_METHOD = 7 THEN 'QRCode' WHEN IDENTITY_METHOD = 8 THEN 'ExternalSystem' ELSE 'Undefined' END AS "Identity Method",
    CASE WHEN ORIGIN = 0 THEN 'Undefined' WHEN ORIGIN = 1 THEN 'Online' WHEN ORIGIN = 2 THEN 'Offline' WHEN ORIGIN = 3 THEN 'external' WHEN ORIGIN = 4 THEN 'API' WHEN ORIGIN = 5 THEN 'legacy' END AS "Check In Origin",
    CASE WHEN CHECKIN_RESULT = 0 THEN 'Undefined' WHEN CHECKIN_RESULT = 1 THEN 'accessGranted' WHEN CHECKIN_RESULT = 2 THEN 'presenceRegistered' WHEN CHECKIN_RESULT = 3 THEN 'accessDenied' END AS "Check In Result",
    ch.checked_out AS "Checked Out",
    p.address1     AS "Street Address 1",
    p.address2     AS "Street Address 2",
    p.city as "City",
    p.zipcode as "Zip",
    phone.txtvalue AS "Phone",
    email.txtvalue AS "Email"
FROM
params  join 
    checkins ch
    on ch.checkin_center = params.CENTERID
JOIN
    centers c
ON
    c.id = ch.checkin_center
JOIN
    chelseapiers.persons p
ON
    p.center = ch.person_center
AND p.id = ch.person_id
--LEFT JOIN
--    zipcodes province
--ON
--    p.zipcode = province.zipcode
--AND province.country = 'US'
--AND province.province IS NOT NULL
LEFT JOIN
    person_ext_attrs email
ON
    email.personcenter=p.center
AND email.personid=p.id
AND email.name = '_eClub_Email'
LEFT JOIN
    person_ext_attrs phone
ON
    phone.personcenter=p.center
AND phone.personid=p.id
AND phone.name = '_eClub_PhoneHome'
 where CH.checkin_time BETWEEN FROMDATE AND TODATE
 order by 1,2,8
 
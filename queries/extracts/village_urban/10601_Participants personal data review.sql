 WITH PARAMS AS
         (
                 SELECT
                         :FromDate AS FROMDATE,
                         :ToDate + (24*60*60*1000) AS TODATE
         )
 SELECT
         p.CENTER || 'p' || p.ID AS "Person ID",
         p.FULLNAME AS "Full Name",
         TO_CHAR(p.BIRTHDATE,'DD-MM-YYYY') AS "DOB",
         p.SEX AS "Gender",
         email.TXTVALUE AS "Email",
         co.NAME AS "Country",
         p.ZIPCODE AS "Zip code",
         p.ADDRESS1 AS "Address",
         c.NAME AS "Home Club",
         part.STATE AS "Participation state",
         TO_CHAR(LONGTODATEC(part.START_TIME, part.CENTER),'YYYY-MM-DD HH24:MI') AS "Participation start time",
         b.NAME AS "Booking name"
 FROM
         PERSONS p
 CROSS JOIN PARAMS
 JOIN
         PARTICIPATIONS part
                 ON p.CENTER = part.PARTICIPANT_CENTER AND p.ID = part.PARTICIPANT_ID
 JOIN
         BOOKINGS b
                 ON part.BOOKING_CENTER = b.CENTER AND part.BOOKING_ID = b.ID
 JOIN
         CENTERS c
                 ON c.ID = p.CENTER
 LEFT JOIN
         COUNTRIES co ON co.ID = p.COUNTRY
 LEFT JOIN
         PERSON_EXT_ATTRS mwc ON p.CENTER = mwc.PERSONCENTER AND p.ID = mwc.PERSONID AND mwc.NAME = '_eClub_WellnessCloudUserPermanentToken'
 LEFT JOIN
         PERSON_EXT_ATTRS email ON p.CENTER = email.PERSONCENTER AND p.ID = email.PERSONID AND email.NAME = '_eClub_Email'
 WHERE
         part.CENTER IN (:Scope)
         AND part.STATE NOT IN ('CANCELLED')
         AND part.START_TIME BETWEEN params.FROMDATE AND params.TODATE
         AND mwc.TXTVALUE IS NULL

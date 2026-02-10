-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT DISTINCT
     c.ID,
     c.SHORTNAME,
     c.NAME,
     c.STARTUPDATE,
     c.PHONE_NUMBER,
     c.FAX_NUMBER,
     c.EMAIL,
     c.ORG_CODE,
     c.ADDRESS1,
     c.ADDRESS2,
     c.ADDRESS3,
     c.COUNTRY,
     c.ZIPCODE,
     c.LATITUDE,
     c.LONGITUDE,
     c.CENTER_TYPE,
     c.EXTERNAL_ID,
     c.CITY,
     c.ORG_CODE2,
     c.WEB_NAME,
     c.WEBSITE_URL,
     man.FULLNAME       AS "General Manager",
     assist.FULLNAME    AS "Assistant Manager",
     CENTER_STATE.state AS "Center State",
     CENTER_STATE.STOP_DATE
 FROM
     CENTERS c
 LEFT JOIN
     PERSONS man
 ON
     man.center = c.MANAGER_CENTER
     AND man.id = c.MANAGER_ID
 LEFT JOIN
     PERSONS assist
 ON
     assist.CENTER = c.ASST_MANAGER_CENTER
     AND assist.ID = c.ASST_MANAGER_ID
 LEFT JOIN
     (
         SELECT
             CENTER_ID,
             CASE
                 WHEN li.START_DATE>CURRENT_TIMESTAMP
                 THEN 'preopen'
                 WHEN li.START_DATE <= CURRENT_TIMESTAMP
                     AND (li.STOP_DATE > CURRENT_TIMESTAMP
                         OR li.STOP_DATE IS NULL)
                 THEN 'Live'
                 WHEN li.START_DATE < CURRENT_TIMESTAMP
                     AND li.STOP_DATE < CURRENT_TIMESTAMP
                 THEN 'Closed'
                 ELSE 'none'
             END AS state,
             li.STOP_DATE
         FROM
             (
                 SELECT
                     CENTER_ID,
                     id,
                     LICENSES.START_DATE,
                     LICENSES.STOP_DATE,
                     rank () over (partition BY center_id ORDER BY center_id,id DESC) AS rank
                 FROM
                     LICENSES
                 WHERE
                     LICENSES.FEATURE = 'clubLead') li
         WHERE
             li.rank=1)CENTER_STATE
 ON
     CENTER_STATE.CENTER_ID = c.id
 WHERE
     c.ID IN ($$Scope$$)
 ORDER BY
     c.ID

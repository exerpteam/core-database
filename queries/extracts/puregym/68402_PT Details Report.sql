 SELECT
     p.FIRSTNAME                                                                        AS "First Name",
     p.LASTNAME                                                                         AS "Last Name",
     staff_email.TXTVALUE                                                               AS "Email Address",
     staff_ext_id.TXTVALUE                                                              AS "DF External ID",
     p.EXTERNAL_ID                                                                      AS "Exerp External ID",
     c.NAME                                                                             AS "Gym Name",
     pd.NAME                                                                            AS "Subscription",
     CASE s.STATE WHEN 2 THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'Undefined' END AS "Subscription State",
     pd.PRICE                                                                           AS "Subscription Price"
 FROM
     PERSONS p
 JOIN
     CENTERS c
 ON
     p.CENTER = c.ID
 LEFT JOIN
     PERSON_EXT_ATTRS staff_ext_id
 ON
     p.CURRENT_PERSON_CENTER = staff_ext_id.PERSONCENTER
     AND p.CURRENT_PERSON_ID = staff_ext_id.PERSONID
     AND staff_ext_id.NAME = '_eClub_StaffExternalId'
 LEFT JOIN
     PERSON_EXT_ATTRS staff_email
 ON
     p.CURRENT_PERSON_CENTER = staff_email.PERSONCENTER
     AND p.CURRENT_PERSON_ID = staff_email.PERSONID
     AND staff_email.NAME = '_eClub_Email'
 JOIN
     SUBSCRIPTIONS s
 ON
     p.center = s.OWNER_CENTER
     AND p.ID = s.OWNER_ID
 JOIN
     PRODUCTS pd
 ON
     s.SUBSCRIPTIONTYPE_CENTER = pd.CENTER
     AND s.SUBSCRIPTIONTYPE_ID = pd.ID
 WHERE
     pd.GLOBALID ='DD_STANDARD'
     OR pd.GLOBALID ='GYM_INSTRUCTOR'
     OR pd.NAME LIKE 'PT/FC%'
     AND P.CENTER IN (:scope)

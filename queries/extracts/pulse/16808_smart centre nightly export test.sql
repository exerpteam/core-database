 SELECT
     p.center center,
     c.shortname AS centre,
     p.id AS member_no,
     CASE p.PERSONTYPE
        WHEN 0
        THEN 'PRIVATE'
        WHEN 1
        THEN 'STUDENT'
        WHEN 2
        THEN 'STAFF'
        WHEN 3
        THEN 'FRIEND'
        WHEN 4
        THEN 'CORPORATE'
        WHEN 5
        THEN 'ONEMANCORPORATE'
        WHEN 6
        THEN 'FAMILY'
        WHEN 7
        THEN 'SENIOR'
        WHEN 8
        THEN 'GUEST'
        ELSE 'UNKNOWN'
     END        AS type,
     p.lastname AS surname,
     p.firstname AS name,
     null AS initials,
     salutation.TxtValue AS title,
     p.Address1 AS AddressLine1,
     p.address2 AS AddressLine2,
     NULL AS AddressLine3,
     NULL AS AddressLine4,
     p.Zipcode AS pcode,
	p.Birthdate AS birthdate,
     TO_CHAR(s.END_DATE, 'YYYY-MM-DD') AS expiry,
     TO_CHAR(p.first_active_start_date, 'YYYY-MM-DD') joined,
     HomePhone.TxtValue AS HomePhone,
     WorkPhone.TxtValue AS WorkPhone,
         Emails.TxtValue as Email
 FROM
     pulse.persons p
 JOIN pulse.centers c
 ON
     p.center = c.id
 JOIN pulse.subscriptions s
 ON
     p.center = s.owner_center
     AND p.id = s.owner_id
 JOIN pulse.subscriptiontypes st
 ON
     s.subscriptiontype_center = st.center
     AND s.subscriptiontype_id = st.id
 JOIN pulse.products pr
 ON
     st.center = pr.center
     AND st.id = pr.id
 JOIN pulse.product_and_product_group_link ppgl
 ON
     pr.center = ppgl.product_center
     AND pr.id = ppgl.product_id
 JOIN pulse.product_group pg
 ON
     ppgl.product_group_id = pg.id
 LEFT JOIN pulse.Person_Ext_Attrs HomePhone
 ON
     p.center = HomePhone.PersonCenter
     AND p.id = HomePhone.PersonId
     AND HomePhone.Name = '_eClub_PhoneHome'
 LEFT JOIN pulse.Person_Ext_Attrs WorkPhone
 ON
     p.center = WorkPhone.PersonCenter
     AND p.id = WorkPhone.PersonId
     AND WorkPhone.Name = '_eClub_PhoneWork'
 LEFT JOIN pulse.Person_ext_attrs Salutation
 ON
     Salutation.personcenter = p.center
     AND Salutation.personid = p.id
     AND Salutation.name='_eClub_Salutation'
 LEFT JOIN
     pulse.Person_Ext_Attrs Emails
     ON
     p.center  = Emails.PersonCenter
     AND p.id  = Emails.PersonId
     AND Emails.Name = '_eClub_Email'
 WHERE
     p.persontype <> 2 -- not staff
     AND p.status IN (1,3) --active or temp inactive persons
     AND pg.name LIKE 'Smart Centre'
     AND s.state IN (2,4) -- active or frozen subscriptions
     AND p.center IN (:SelectClub)

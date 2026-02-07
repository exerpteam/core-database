SELECT
    p.center CentreId,
    p.center||'p'||p.id AS MemberNo,
    case when rel_prod.CENTER is not null then rel.RELATIVECENTER || 'p' || rel.relativeid  else '' end as HeadMemberNo,
    case when rel_prod.CENTER is not null then 'No' else 'Yes' end as Head,
    ent.IDENTITY as Barcode,
    DECODE(p.STATUS, 1, 'Active', 3, 'TempInactive', 'Inactive') as Status,
    p.firstname AS Forename,
    p.lastname AS Surname,
    salutation.TxtValue AS Title,
    p.sex as Sex,
    Emails.TxtValue as Email,
    p.Address1 AS HomeAddr1,
    p.address2 AS HomeAddr2,
    zip.CITY as HomeAddTown,
    zip.COUNTY as HomeAddCoun,
    zip.ZIPCODE as HomePCode,
    to_char(p.BIRTHDATE, 'DD-MM-YYYY') as DoB,
    case when rel_prod.CENTER is not null then rel_prod.NAME else pr.NAME end as MembershipCategory,
    case when rel_prod.CENTER is not null then rel_sub.END_DATE else s.END_DATE end as ExpiryDate,
    case when rel_prod.CENTER is not null then rel_sub.START_DATE else s.START_DATE end as JoinedDate,
    case when rel_prod.CENTER is not null then rel_sub.BINDING_END_DATE else s.BINDING_END_DATE end as ObligationDate,
    HomePhone.TxtValue AS HomePhone,
    WorkPhone.TxtValue AS WorkPhone,
    MobilePhone.TxtValue AS MobilePhone,
    decode(st.ST_TYPE, 1, 'DD', 0, 'CASH') as BillingMethod

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
LEFT JOIN pulse.Person_Ext_Attrs MobilePhone
ON
    p.center = MobilePhone.PersonCenter
    AND p.id = MobilePhone.PersonId
    AND MobilePhone.Name = '_eClub_PhoneSMS'
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
LEFT JOIN
    PULSE.ENTITYIDENTIFIERS ent on ent.REF_CENTER = p.center and ent.REF_ID = p.id and ent.ref_type = 1 and ent.ENTITYSTATUS = 1
LEFT JOIN
    PULSE.ZIPCODES zip on zip.COUNTRY = p.COUNTRY and zip.ZIPCODE = p.ZIPCODE and zip.CITY = p.CITY
LEFT JOIN
    PULSE.RELATIVES rel on rel.CENTER = p.center and rel.id = p.id and rel.RTYPE = 4 and rel.STATUS = 1 and p.PERSONTYPE = 6
LEFT JOIN
    PULSE.SUBSCRIPTIONS rel_sub on rel_sub.owner_CENTER = rel.RELATIVECENTER and rel_sub.owner_id = rel.RELATIVEID and rel_sub.STATE in (2,4)
LEFT JOIN
    PULSE.PRODUCTS rel_prod on rel_prod.CENTER = rel_sub.SUBSCRIPTIONTYPE_CENTER and rel_prod.ID = rel_sub.SUBSCRIPTIONTYPE_ID 
WHERE
    p.persontype <> 2 -- not staff
    AND p.status IN (1,3) --active or temp inactive persons
    AND s.state IN (2,4) -- active or frozen subscriptions
    -- AND (p.PERSONTYPE != 4 or rel_prod.center is not null)
    AND p.center IN (:scope)
order by p.center, p.id
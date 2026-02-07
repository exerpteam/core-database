-- This is the version from 2026-02-05
--  
SELECT 
    persons.center || 'p' ||persons.id as personid, 
    persons.firstname firstname, 
    persons.lastname lastname, 
    DECODE (persons.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    persons.ssn,
    persons.Address1 as AddressLine1, 
    persons.address2 as AddressLine2, 
    persons.Zipcode, 
    persons.City, 
	HomePhone.TxtValue as HomePhone,
    MobilePhone.TxtValue as MobilePhone, 
    WorkPhone.TxtValue as WorkPhone, 
    persons.country,
    Emails.TxtValue as Email, 
    ei.identity as card_number,
    DECODE(ei.IDMETHOD, 1, 'BARCODE', 2, 'MAGNETIC_CARD', 3, 'SSN', 4, 'RFID_CARD', 5, 'MEMBER_ID','UNKNOWN') as identity_type,
    Prod.globalid as product,
    to_char(sfp.start_date, 'YYYY-MM-DD') as freeze_start,
    to_char(sfp.end_date, 'YYYY-MM-DD') as freeze_end,
    pa.BANK_REGNO, 
    pa.BANK_ACCNO,
	sub.start_date as subscription_start_date,
	sub.end_date as subscription_end_date,
	sub.subscription_price as subscription_price,
	sub.binding_price as subscription_binding_price
FROM 
    fw.persons
join
    fw.subscriptions sub
    on
    persons.center = sub.owner_center
    and persons.id = sub.owner_id
left join
    fw.subscriptiontypes st
    on
    sub.subscriptiontype_center = st.center
    and sub.subscriptiontype_id = st.id
left join
    fw.products prod
    on
    st.center = prod.center
    and st.id = prod.id
left join
    fw.subscription_freeze_period sfp
    on
    sub.center = sfp.subscription_center
    and sub.id = sfp.subscription_id
    and sfp.start_date < to_date(to_char(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd') 
    and sfp.end_date > to_date(to_char(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd') 
LEFT JOIN 
    fw.Person_Ext_Attrs Emails 
    ON 
    persons.center  = Emails.PersonCenter 
    AND persons.id  = Emails.PersonId 
    AND Emails.Name = '_eClub_Email' 
left join fw.ENTITYIDENTIFIERS ei
    on 
    persons.center = ei.REF_CENTER 
    and persons.id = ei.REF_ID 
    and ei.REF_TYPE = 1  -- person
    and ei.entitystatus = 1    -- OK status

--
LEFT JOIN 
    fw.ACCOUNT_RECEIVABLES ar 
    ON 
    persons.center = ar.customercenter 
    and persons.id = ar.customerid 
    and ar.AR_TYPE = 4 
LEFT JOIN 
    fw.PAYMENT_ACCOUNTS pc 
    ON 
    ar.center = pc.center 
    and ar.id = pc.id 
LEFT JOIN 
    fw.payment_agreements pa 
    ON 
    pc.ACTIVE_AGR_CENTER    = pa.center 
    and pc.ACTIVE_AGR_ID    = pa.id 
    and pc.ACTIVE_AGR_SUBID = pa.subid 
--
LEFT JOIN 
    fw.Person_Ext_Attrs HomePhone 
    ON 
        persons.center       = HomePhone.PersonCenter 
    AND persons.id           = HomePhone.PersonId 
    AND HomePhone.Name = '_eClub_PhoneHome' 
LEFT JOIN 
    fw.Person_Ext_Attrs MobilePhone 
    ON 
    persons.center       = MobilePhone.PersonCenter 
    AND persons.id       = MobilePhone.PersonId 
    AND MobilePhone.Name = '_eClub_PhoneSMS' 
LEFT JOIN 
    fw.Person_Ext_Attrs WorkPhone 
    ON 
    persons.center     = WorkPhone.PersonCenter 
    AND persons.id     = WorkPhone.PersonId 
    AND WorkPhone.Name = '_eClub_PhoneWork' 

WHERE 
        persons.center = 185
    AND sub.state in (2,4) -- acticve, temp. inactive
order by
    persons.id
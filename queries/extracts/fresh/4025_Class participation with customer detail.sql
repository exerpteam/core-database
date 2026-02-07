SELECT
    bk.owner_CENTER,
    bk.owner_ID,
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD HH24:MI') AS START_TIME,
    bk.name,
    DECODE(p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    p.fullname as fullname,
    p.Address1 as AddressLine1, 
    p.address2 as AddressLine2, 
    p.Zipcode as zip,
    p.city,
    HomePhone.TxtValue AS HomePhone, 
    WorkPhone.TxtValue AS WorkPhone,
    PhoneSMS.TxtValue AS PhoneSMS
FROM
     bookings bk
join 
     participations par
     on
     bk.center = par.booking_center
     and bk.id = par.booking_id
     and par.state = 'PARTICIPATION' 
JOIN 
     ACTIVITIES_NEW a
     ON
     bk.ACTIVITY =  a.ID 
join
    persons p
    on
    bk.owner_center = p.center
    and bk.owner_id = p.id
LEFT JOIN 
     Person_Ext_Attrs HomePhone 
     ON 
         p.center       = HomePhone.PersonCenter 
     AND p.id           = HomePhone.PersonId 
     AND HomePhone.Name = '_eClub_PhoneHome' 
LEFT JOIN 
     Person_Ext_Attrs WorkPhone 
     ON 
         p.center       = WorkPhone.PersonCenter 
     AND p.id           = WorkPhone.PersonId 
     AND WorkPhone.Name = '_eClub_PhoneWork'
LEFT JOIN 
     Person_Ext_Attrs PhoneSMS
     ON 
         p.center       = PhoneSMS.PersonCenter 
     AND p.id           = PhoneSMS.PersonId 
     AND PhoneSMS.Name  = '_eClub_PhoneSMS'
WHERE
    par.participant_center in (:scope)
    and bk.STARTTIME >= :from_date
    and bk.STARTTIME <= :to_date
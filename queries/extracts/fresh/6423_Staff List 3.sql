 SELECT 
    p.center||'p'||p.id as Person_ID,
    emp.center||'emp'||emp.id as staff_ID,
    p.Firstname as Fornavn,
    p.Lastname as Efternavn,
    p.ssn as CPR,
    pag.bank_regno as Reg_nummer,
    pag.bank_accno as Konto_nummer,
    email.TXTVALUE as Email,
    p.ADDRESS1 as Gadeadresse,
    p.Zipcode as Postnummer, 
    p.City as Bynavn,
    mobile.TXTVALUE as Mobil_nr,
    center.shortname as Afdeling

FROM
     persons p
join employees emp
    on
    p.center = emp.personcenter
    AND 
    p.id = emp.personid

join account_receivables ar
     on
     p.center = ar.customercenter
     and
     p.id = ar.customerid
     
join payment_accounts pa
     on
     ar.center = pa.center
     and
     ar.id = pa.id
     
join payment_agreements pag
     on
     pa.ACTIVE_AGR_CENTER = pag.center
     and
     pa.ACTIVE_AGR_ID = pag.id
     and 
     pa.ACTIVE_AGR_SUBID = pag.SUBID 

LEFT JOIN PERSON_EXT_ATTRS email
ON
    p.center = email.PERSONCENTER
    AND p.id = email.PERSONID
    AND email.name='_eClub_Email'
    
LEFT JOIN PERSON_EXT_ATTRS mobile
ON
    p.center = mobile.PERSONCENTER
    AND p.id = mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
    
LEFT JOIN CENTERS center
ON
    p.center = center.ID
    
WHERE
    emp.center in (:center)
    and
    p.PERSONTYPE = 2
        
order by
    p.center,
    p.id
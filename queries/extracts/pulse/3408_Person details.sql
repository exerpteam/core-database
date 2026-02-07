SELECT 
	persons.center||'p'||persons.id as personid,

 
CASE persons.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS PERSON_STATUS,
        CASE persons.PERSONTYPE WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' END AS PERSONTYPE,
        


    persons.firstname as firstname, 
    persons.lastname as lastname, 
    persons.Address1 as AddressLine1, 
    persons.address2 as AddressLine2, 
    persons.Zipcode, 
    persons.City, 
    Emails.TxtValue as Email, 
    persons.password_hash as password_hash
FROM 
        pulse.persons 
LEFT JOIN 
        pulse.Person_Ext_Attrs Emails 
    ON 
        persons.center  = Emails.PersonCenter 
    AND persons.id  = Emails.PersonId 
    AND Emails.Name = '_eClub_Email' 
WHERE 
        persons.sex   <> 'C' 
    AND persons.center IN (:scope)
    and persons.STATUS IN (:person_status)
	and persons.persontype IN (:person_type)
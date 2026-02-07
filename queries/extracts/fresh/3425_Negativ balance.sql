SELECT
    CUSTOMERCENTER,
    CUSTOMERID,
    PERSONS.firstname,
    PERSONS.lastname,
    PERSONS.STATUS,
    BALANCE,
    MobilePhone.TxtValue AS MobilePhone,
    HomePhone.TxtValue   AS HomePhone
FROM
    ACCOUNT_RECEIVABLES
JOIN persons
ON
    ACCOUNT_RECEIVABLES.customercenter = PERSONS.center
AND ACCOUNT_RECEIVABLES.customerid=PERSONS.id
LEFT JOIN Person_Ext_Attrs MobilePhone
ON
    persons.center = MobilePhone.PersonCenter
AND persons.id = MobilePhone.PersonId
AND MobilePhone.Name = '_eClub_PhoneSMS'
LEFT JOIN Person_Ext_Attrs HomePhone
ON
    persons.center = HomePhone.PersonCenter
AND persons.id = HomePhone.PersonId
AND HomePhone.Name = '_eClub_PhoneHome'
WHERE
    balance < 0
SELECT 
    ca.center                           as companycenter, 
    ca.id                               as companyid, 
    ca.subid                            as agreementid, 
    c.lastname                          as company, 
    c.Address1 || '  /  ' || c.address2 as Address, 
    c.zipcode, 
    c.SSN, 
    ca.name as agreement,
DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4,
'Awaiting activation', 5, 'Blocked', 6, 'Slettet') as State
FROM 
    COMPANYAGREEMENTS ca 
JOIN 
    PERSONS c 
    ON 
    ca.CENTER = c.CENTER 
    AND ca.ID = c.ID 
WHERE 
    c.SEX = 'C' 


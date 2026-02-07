SELECT DISTINCT
    center.id                     AS CenterId,
    center.NAME                   AS CenterName,
    comp.center || 'p' || comp.id AS CompanyId,
    comp.firstname                AS FirstName,
    comp.MIDDLENAME               AS MiddleName,
    comp.lastname                 AS LastName,
    comp.fullname                 AS FullName,
    comp.ssn                      AS ssn,
    comp.ADDRESS1                 AS AddressLine1,
    comp.ADDRESS2                 AS AddressLine2,
    comp.ADDRESS3                 AS AddressLine3,
    comp.zipcode                  AS ZipCode,
    comp.city                     AS City,
    comp.country                  AS Country
FROM
    persons comp
JOIN
    CENTERS center
ON
    comp.center = center.id
WHERE
    comp.center IN ($$Scope$$)
    AND comp.sex = 'C'

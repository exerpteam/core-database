-- This is the version from 2026-02-05
--  
SELECT
    ca.CENTER as company_center,
    ca.ID as company_id,
    comp.LASTNAME AS company,
    person.CENTER||'p'||person.ID as customer,
    person.FIRSTNAME || ' ' || person.LASTNAME  AS person_Name,
    ca.NAME                                     AS agrrement,
    grants.sponsorship_name                     AS sponsor_level,
    DECODE(ca.STATE, 0, 'Under target', 1, 'Active', 2, 'Stop new', 3, 'Old', 4, 'Awaiting activation', 5, 'Blocked', 6, 'Deleted') AS agreement_state,
    DECODE (person.STATUS, 0,'LEAD', 1,'ACTIVE', 2,'INACTIVE', 3,'TEMPORARYINACTIVE', 4,'TRANSFERED', 5,'DUPLICATE', 6,'PROSPECT', 7,'DELETED','UNKNOWN') AS person_STATUS
FROM
    fw.PERSONS person
JOIN fw.RELATIVES companyAgrRel
ON
    person.CENTER = companyAgrRel.CENTER
AND person.ID = companyAgrRel.ID
AND companyAgrRel.RTYPE = 3
and companyAgrRel.STATUS = 1
JOIN fw.COMPANYAGREEMENTS ca
ON
    ca.CENTER = companyAgrRel.RELATIVECENTER
AND ca.ID = companyAgrRel.RELATIVEID
AND ca.SUBID = companyAgrRel.RELATIVESUBID
JOIN FW.PERSONS comp
ON
    comp.CENTER = ca.CENTER
AND comp.ID = ca.id
JOIN fw.privilege_grants grants
ON
    ca.center = grants.granter_center
AND ca.id = grants.granter_id
AND ca.subid = grants.granter_subid
WHERE
    ca.center in (:scope)
and person.PERSONTYPE = 4
AND person.SEX != 'C'
AND grants.granter_service = 'CompanyAgreement'
AND grants.sponsorship_name = 'FULL'
group by
    ca.CENTER,
    ca.ID,
    ca.SUBID,
    person.CENTER,
    person.ID,
    person.FIRSTNAME || ' ' || person.LASTNAME,
    comp.LASTNAME,
    ca.NAME,
    grants.sponsorship_name,
    ca.STATE,
    person.STATUS
order by
    ca.CENTER,
    ca.ID
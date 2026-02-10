-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Extract to export available companyagreements to web.
* Used to import companies for users to select agreement.
* Should be replaced by pagination in CompanyAPI.
* Created By: Henrik Håkanson
*/
SELECT 
	ca.ID AS "ID",
	ca.CENTER AS "CENTER",
	ca.SUBID AS "SUBID",
	c.FULLNAME AS "COMPANYNAME",
	ca.NAME AS "AGREEMENT",
	ca.STATE AS "STATE",
	ca.BLOCKED AS "BLOCKED",
	ca.REF AS "REFERENCE",
	ca.AVAILABILITY AS "AVAILABILITY"
FROM COMPANYAGREEMENTS ca
JOIN PERSONS c ON
	ca.CENTER = c.CENTER
	AND ca.ID = c.ID
	AND c.SEX='C'	
	AND ca.STATE = 1
ORDER BY
	ca.CENTER,
	ca.ID,
	ca.SUBID

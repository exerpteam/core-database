-- The extract is extracted from Exerp on 2026-02-08
-- Original list without ex member subscription detials
SELECT DISTINCT 
    r.RELATIVECENTER || 'p' || r.RELATIVEID     AS "Member ID", -- referring member
	CASE pe.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    END                                         AS "Person Status",
	pe.FULLNAME                                 AS "Full Name",
	CASE pe.persontype
	    WHEN 0 THEN 'Private'
	    WHEN 1 THEN 'Student'
	    WHEN 2 THEN 'Staff'
	    WHEN 3 THEN 'Friend'
	    WHEN 4 THEN 'Corporate'
	    WHEN 5 THEN 'One Man Corporate'
	    WHEN 6 THEN 'Family'
	    WHEN 7 THEN 'Senior'
	    WHEN 8 THEN 'External Staff'
	    ELSE 'UNKOWN'
    END                                         AS "Person Type",
    r.CENTER || 'p' || r.ID                     AS "Other Member ID", -- referred member
    CASE p.status
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARYINACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN' 
    END                                         AS "Other Person Status",
    TO_CHAR(sub.START_DATE, 'DD.MM.YYYY')       AS "Start Date Membership", -- start date of current membership
    prod.NAME                                   AS "Membership",

    CASE r.RTYPE
        WHEN 1
        THEN 'Friends of me'
        WHEN 4
        THEN 'Family to me'
        WHEN 9
        THEN 'Counselled by me'
        WHEN 12
        THEN 'My Payer'
        WHEN 13
        THEN 'Referred by me'
        ELSE 'UNKNOWN'
    END                                         AS "Type of Relation",
    CASE r.STATUS
        WHEN 0
        THEN 'Lead'
        WHEN 1
        THEN 'Active'
        WHEN 2
        THEN 'Inactive'
        WHEN 3
        THEN 'Blocked'
        ELSE 'unkown'
    END                                         AS "State of Relation",
    TO_CHAR(longtodate(MIN(scl.ENTRY_START_TIME) OVER (PARTITION BY scl.CENTER, scl.ID, scl.SUBID)),'YYYY-MM-DD HH24:MI:SS') AS "Referral Date",
pe.EXTERNAL_ID                                  AS "External ID",
pem.txtvalue                                    AS "E-Mail"
FROM
    RELATIVES r
JOIN
    PERSONS p
ON
    r.CENTER = p.CENTER 
    AND r.ID = p.ID 
JOIN 
    PERSONS pe 
ON 
    r.RELATIVECENTER || 'p' || r.RELATIVEID = pe.CENTER || 'p' || pe.ID 
JOIN 
    SUBSCRIPTIONS sub 
ON 
    sub.OWNER_CENTER = p.center
    AND sub.OWNER_ID = p.ID
JOIN
    SUBSCRIPTION_SALES ss
ON
    sub.CENTER = ss.SUBSCRIPTION_CENTER
    AND sub.ID = ss.SUBSCRIPTION_ID
JOIN
    SUBSCRIPTIONTYPES stype
ON
    ss.SUBSCRIPTION_TYPE_CENTER = stype.CENTER
    AND ss.SUBSCRIPTION_TYPE_ID = stype.ID
JOIN
    PRODUCTS prod
ON
    stype.CENTER = prod.CENTER
    AND stype.ID = prod.ID
JOIN 
    PERSON_EXT_ATTRS PA 
ON  
    PA.personcenter = p.CENTER
	AND PA.personid= p.ID
LEFT JOIN 
    PERSON_EXT_ATTRS pem 
ON 
    pem.personcenter = pe.CENTER 
    AND pem.personid = pe.ID 
    AND pem.name = '_eClub_Email'

LEFT JOIN
    STATE_CHANGE_LOG scl
ON
    ENTRY_TYPE=4
    AND scl.CENTER = r.CENTER
    AND scl.ID = r.ID
    AND scl.SUBID = r.SUBID
    AND scl.ENTRY_END_TIME IS NULL
WHERE
    r.RTYPE NOT IN (1,2,3,4,5,6,7,8,9,10,11,12)
    AND ss.type =1 -- only new sales
    AND prod.primary_product_group_id <> 2802
    AND prod.primary_product_group_id <> 6
    AND p.STATUS IN (1,3)
	AND r.STATUS IN (1)
	AND sub.STATE <> 3
    AND sub.STATE <> 7 
    AND sub.SUB_STATE <> 8
    AND p.CENTER IN ($$Scope$$)
    AND scl.ENTRY_START_TIME >= $$Startdate$$ 
    AND scl.ENTRY_START_TIME < ($$Enddate$$ + 24*60*60*1000)
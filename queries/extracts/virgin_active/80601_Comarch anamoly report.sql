SELECT
    -- Existing CASE statements for personstatus and persontype
    CASE 
        WHEN owner.STATUS = 0 THEN 'Lead'
        WHEN owner.STATUS = 1 THEN 'Active'
        WHEN owner.STATUS = 2 THEN 'Inactive'
        WHEN owner.STATUS = 3 THEN 'TemporaryInactive'
        WHEN owner.STATUS = 4 THEN 'Transferred'
        WHEN owner.STATUS = 5 THEN 'Duplicate'
        WHEN owner.STATUS = 6 THEN 'Prospect'
        WHEN owner.STATUS = 7 THEN 'Deleted' 
        WHEN owner.STATUS = 8 THEN 'Anonymised'
        WHEN owner.STATUS = 9 THEN 'Contact'
    END as personstatus,
    
    CASE 
        WHEN owner.persontype = 0 THEN 'Private'
        WHEN owner.persontype = 1 THEN 'Student'
        WHEN owner.persontype = 2 THEN 'Staff'
        WHEN owner.persontype = 3 THEN 'Friend'
        WHEN owner.persontype = 4 THEN 'Corporate'
        WHEN owner.persontype = 5 THEN 'OnemanCorporate'
        WHEN owner.persontype = 6 THEN 'Family'
        WHEN owner.persontype = 7 THEN 'Senior' 
        WHEN owner.persontype = 8 THEN 'Guest'
    END as persontype,

    centre.ID || 'p' || owner.ID AS Exerp_ID,  -- Concatenating owner.ID and centre.ID with 'p' in between
    owner.External_id,
    floor(months_between(TRUNC(CURRENT_TIMESTAMP), owner.BIRTHDATE) / 12) CurrentAge,
    
    -- New CASE statement for age check
    CASE 
        WHEN floor(months_between(TRUNC(CURRENT_TIMESTAMP), owner.BIRTHDATE) / 12) < 16 THEN 'Underage'
        ELSE NULL  -- NULL represents no value for those >= 16
    END as age_status,

    -- Existing LoyaltyTCs and other joins
    MAX(CASE WHEN LoyaltyTCs.name = 'LoyaltyTCs' THEN LOYALTYTCS.TXTValue END) AS LoyaltyTCs,
    MAX(CASE WHEN RewardURL.name = 'RewardURL' THEN RewardURL.TXTValue END) AS RewardURL,
    MAX(CASE WHEN Loyalty_identifier_ID.name = 'LOYALTY' THEN Loyalty_identifier_ID.TXTValue END) AS Loyalty_identifier_ID,
    MAX(CASE WHEN Loyalty_Customer_ID.name = 'LCID' THEN Loyalty_Customer_ID.TXTValue END) AS Loyalty_Customer_ID,
    MAX(CASE WHEN Loyalty_Account_ID.name = 'LAID' THEN Loyalty_Account_ID.TXTValue END) AS Loyalty_Account_ID

FROM
    PERSONS owner
JOIN
    CENTERS centre ON owner.CENTER = centre.ID
LEFT JOIN
    PERSON_EXT_ATTRS RewardURL
    ON owner.center = RewardURL.PERSONCENTER
    AND owner.id = RewardURL.PERSONID
    AND RewardURL.name = 'RewardURL'
LEFT JOIN
    PERSON_EXT_ATTRS Loyalty_identifier_ID
    ON owner.center = Loyalty_identifier_ID.PERSONCENTER
    AND owner.id = Loyalty_identifier_ID.PERSONID
    AND Loyalty_identifier_ID.name = 'LOYALTY'
LEFT JOIN
    PERSON_EXT_ATTRS Loyalty_Customer_ID
    ON owner.center = Loyalty_Customer_ID.PERSONCENTER
    AND owner.id = Loyalty_Customer_ID.PERSONID
    AND Loyalty_Customer_ID.name = 'LCID'
LEFT JOIN
    PERSON_EXT_ATTRS Loyalty_Account_ID
    ON owner.center = Loyalty_Account_ID.PERSONCENTER
    AND owner.id = Loyalty_Account_ID.PERSONID
    AND Loyalty_Account_ID.name = 'LAID'
LEFT JOIN
    PERSON_EXT_ATTRS LoyaltyTCs
    ON owner.center = LoyaltyTCs.PERSONCENTER
    AND owner.id = LoyaltyTCs.PERSONID
    AND LoyaltyTCs.name = 'LoyaltyTCs'

WHERE
    LOYALTYTCS.TXTValue = 'Y'
AND
	owner.STATUS IN (1,3)
AND
    owner.center IN 
    (
        76, 29, 34, 35, 27, 421, 405, 38, 438, 39, 47, 12, 51, 56, 57, 59, 
        415, 2, 60, 61, 422, 452, 15, 6, 68, 69, 410, 16, 953, 425, 408, 4
    )
GROUP BY
    personstatus, persontype, owner.ID, centre.ID, owner.External_id, owner.BIRTHDATE
HAVING
    MAX(CASE WHEN RewardURL.name = 'RewardURL' THEN RewardURL.TXTValue END) IS NULL
    OR MAX(CASE WHEN Loyalty_identifier_ID.name = 'LOYALTY' THEN Loyalty_identifier_ID.TXTValue END) IS NULL
    OR MAX(CASE WHEN Loyalty_Customer_ID.name = 'LCID' THEN Loyalty_Customer_ID.TXTValue END) IS NULL
    OR MAX(CASE WHEN Loyalty_Account_ID.name = 'LAID' THEN Loyalty_Account_ID.TXTValue END) IS NULL

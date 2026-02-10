-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT DISTINCT
    p2.EXTERNAL_ID,
    s.center||'ss'||s.id                                   AS Subscription_ID,
    DECODE(st.ST_TYPE, 0, 'Cash', 1, 'EFT', 3, 'Prospect') AS Subscription_type,
    pr.NAME                                                AS Subscription_name,
    pg.NAME                                                AS Product_Group_Name,
    s.START_DATE,
    s.END_DATE,
    DECODE (s.STATE, 2,'ACTIVE', 3,'ENDED', 4,'FROZEN', 7,'WINDOW', 8,'CREATED','UNKNOWN') AS STATE,
	DECODE (s.SUB_STATE, 1,'NONE', 2,'AWAITING_ACTIVATION', 3,'UPGRADED', 4,'DOWNGRADED', 5,'EXTENDED', 6, 'TRANSFERRED',7,'REGRETTED',8,'CANCELLED',9,'BLOCKED',10,'CHANGED','UNKNOWN') AS SUB_STATE,
    periodFee.TXTVALUE AS "PERIOD_FEE_CO_DATE",
    (CASE
        WHEN p.CENTER=14 THEN coFeeHAM.TXTVALUE
        WHEN p.CENTER=2 THEN coFeeBMS.TXTVALUE
        ELSE coFeeAll.TXTVALUE
     END) AS "CHARGE_CO_FEE",
	peaStatDeb.TXTVALUE AS "STATUS_DEBTOR",
	originalStartDate.TXTVALUE AS "ORIGINAL_START_DATE"
FROM
    HP.SUBSCRIPTIONS s
JOIN
    HP.SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    HP.PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    HP.PRODUCT_GROUP pg
ON
    pg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
JOIN
    HP.PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    HP.PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
LEFT JOIN HP.PERSON_EXT_ATTRS periodFee
        ON periodFee.PERSONCENTER = p.CENTER
           AND periodFee.PERSONID = p.ID
           AND periodFee.NAME in ('BODYSCANFEEDATE','COFEEDATEAT','COFEEDATECH')
LEFT JOIN HP.PERSON_EXT_ATTRS coFeeBMS
        ON coFeeBMS.PERSONCENTER = p.CENTER
           AND coFeeBMS.PERSONID = p.ID
           AND coFeeBMS.NAME = 'ChargeCOFee'
LEFT JOIN HP.PERSON_EXT_ATTRS coFeeHAM
        ON coFeeHAM.PERSONCENTER = p.CENTER
           AND coFeeHAM.PERSONID = p.ID
           AND coFeeHAM.NAME = 'CHARGECOFEE'
LEFT JOIN HP.PERSON_EXT_ATTRS coFeeAll
        ON coFeeAll.PERSONCENTER = p.CENTER
           AND coFeeAll.PERSONID = p.ID
           AND coFeeAll.NAME = 'CHARGE_CO_FEE'
LEFT JOIN HP.PERSON_EXT_ATTRS peaStatDeb
        ON peaStatDeb.PERSONCENTER = p.CENTER
           AND peaStatDeb.PERSONID = p.ID
           AND peaStatDeb.NAME = 'STATUS_DEBTOR'
LEFT JOIN HP.PERSON_EXT_ATTRS originalStartDate
		ON originalStartDate.PERSONCENTER = p.CENTER
			AND originalStartDate.PERSONID = p.ID
			AND originalStartDate.NAME = 'OriginalStartDate'
WHERE
    s.STATE !=5
    AND p2.STATUS NOT IN (4,5,7,8)
    AND p2.PERSONTYPE != 2
    
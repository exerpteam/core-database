SELECT DISTINCT
c.shortname AS CLUB,
    p2.EXTERNAL_ID,
p2.center||'p'||p2.id AS MemberID,
p.center||'p'||p.id AS OldMemberID,
keepmeid.TXTVALUE   AS KeepmeID,
    s.center||'ss'||s.id                                   AS Subscription_ID,
    CASE st.ST_TYPE
        WHEN 0 THEN 'Cash'
        WHEN 1 THEN 'EFT'
        WHEN 3 THEN 'Prospect'
		WHEN 2 THEN 'ClipCard'
    END AS Subscription_type,
    pr.NAME                                                AS Subscription_name,
    pg.NAME                                                AS Product_Group_Name,
    s.START_DATE,
    s.END_DATE,
	s.subscription_price,
    CASE s.STATE
      WHEN 2 THEN 'ACTIVE'
      WHEN 3 THEN 'ENDED'
      WHEN 4 THEN 'FROZEN'
      WHEN 7 THEN 'WINDOW'
      WHEN 8 THEN 'CREATED'
      ELSE 'UNKNOWN'
   END AS STATE,	
  CASE s.SUB_STATE
    WHEN 1
    THEN 'NONE'
    WHEN 2
    THEN 'AWAITING_ACTIVATION'
    WHEN 3
    THEN 'UPGRADED'
    WHEN 4
    THEN 'DOWNGRADED'
    WHEN 5
    THEN 'EXTENDED'
    WHEN 6
    THEN 'TRANSFERRED'
    WHEN 7
    THEN 'REGRETTED'
    WHEN 8
    THEN 'CANCELLED'
    WHEN 9
    THEN 'BLOCKED'
    ELSE 'UNKNOWN'
   END as SUB_STATE,
periodFee.TXTVALUE                                                                                                                                                                   AS "PERIOD_FEE_CO_DATE",
    (
        CASE
            WHEN p.CENTER=14
            THEN coFeeHAM.TXTVALUE
            WHEN p.CENTER=2
            THEN coFeeBMS.TXTVALUE
            ELSE coFeeAll.TXTVALUE
        END)                   AS "CHARGE_CO_FEE",
    peaStatDeb.TXTVALUE        AS "STATUS_DEBTOR",
    originalStartDate.TXTVALUE AS "ORIGINAL_START_DATE"
FROM
    SUBSCRIPTIONS s
JOIN
    SUBSCRIPTIONTYPES st
ON
    st.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCTS pr
ON
    pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
    AND pr.id = s.SUBSCRIPTIONTYPE_ID
JOIN
    PRODUCT_GROUP pg
ON
    pg.ID = pr.PRIMARY_PRODUCT_GROUP_ID
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
JOIN
    PERSONS p2
ON
    p2.CENTER = p.CURRENT_PERSON_CENTER
    AND p2.id = p.CURRENT_PERSON_ID
JOIN
    CENTERS c
ON
    c.id = p2.CENTER
LEFT JOIN
     PERSON_EXT_ATTRS keepmeid
 ON
    keepmeid.PERSONCENTER = p.CENTER
    AND keepmeid.PERSONID = p.ID
    AND keepmeid.NAME = 'keepmeid'

LEFT JOIN
    PERSON_EXT_ATTRS periodFee
ON
    periodFee.PERSONCENTER = p.CENTER
    AND periodFee.PERSONID = p.ID
    AND periodFee.NAME IN ('BODYSCANFEEDATE',
                           'COFEEDATEAT',
                           'COFEEDATECH')
LEFT JOIN
    PERSON_EXT_ATTRS coFeeBMS
ON
    coFeeBMS.PERSONCENTER = p.CENTER
    AND coFeeBMS.PERSONID = p.ID
    AND coFeeBMS.NAME = 'ChargeCOFee'
LEFT JOIN
    PERSON_EXT_ATTRS coFeeHAM
ON
    coFeeHAM.PERSONCENTER = p.CENTER
    AND coFeeHAM.PERSONID = p.ID
    AND coFeeHAM.NAME = 'CHARGECOFEE'
LEFT JOIN
    PERSON_EXT_ATTRS coFeeAll
ON
    coFeeAll.PERSONCENTER = p.CENTER
    AND coFeeAll.PERSONID = p.ID
    AND coFeeAll.NAME = 'CHARGE_CO_FEE'
LEFT JOIN
    PERSON_EXT_ATTRS peaStatDeb
ON
    peaStatDeb.PERSONCENTER = p.CENTER
    AND peaStatDeb.PERSONID = p.ID
    AND peaStatDeb.NAME = 'STATUS_DEBTOR'
LEFT JOIN
    PERSON_EXT_ATTRS originalStartDate
ON
    originalStartDate.PERSONCENTER = p.CENTER
    AND originalStartDate.PERSONID = p.ID
    AND originalStartDate.NAME = 'OriginalStartDate'
WHERE
    s.STATE !=5
    AND p2.STATUS NOT IN (4,5,7,8)
    AND c.COUNTRY IN ('DE')
	AND p2.center IN (:center)
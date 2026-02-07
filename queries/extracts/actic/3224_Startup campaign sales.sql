SELECT DISTINCT
    s.OWNER_CENTER||'p'||s.OWNER_ID   AS MemberID,
	s.CENTER || 'ss' || s.ID AS SubscriptionId,
	per.firstname,
	per.lastname,
	 email.TXTVALUE as email,
	   pea_mobile.txtvalue p1_mobile,
	c.name,
	CASE  P.STATUS  WHEN 0 THEN 'Lead'  WHEN 1 THEN 'Active'  WHEN 2 THEN 'Inactive'  WHEN 3 THEN 'Temporary inactive'  WHEN 4 THEN 'Transferred'  WHEN 5 THEN 'Duplicate'  WHEN 6 THEN 'Prospect'  WHEN 7 THEN 'Deleted'  WHEN 8 THEN  'Anonimized'  WHEN 9 THEN  'Contact'  ELSE 'Unknown' END AS STATUS,
	p.ssn,
	sc.id,
    invl.TOTAL_AMOUNT / invl.QUANTITY AS DiscountedJfeePrice,
    sc.NAME                           AS startup_campaign_Jfee,
    prg.NAME                          AS Priv_campaign_Jfee,
    cc.CODE                           AS Campiagn_Code_Used,
    TO_CHAR(longtodate(inv.TRANS_TIME),'yyyy-MM-dd') SaleDate,
    CASE  WHEN sc2.ID IS NULL THEN NULL ELSE sp.FROM_DATE END    discounted_period_start,
    CASE  WHEN sc2.ID IS NULL THEN NULL ELSE sp.TO_DATE END      discounted_period_end,
    CASE  WHEN sc2.ID IS NULL THEN NULL ELSE sp.PRICE END        discounted_period_price,
    sc2.NAME                              AS startup_campaign_period,
   prg2.NAME                             AS Priv_campaign_period,
    cc2.CODE                              AS Campiagn_Code_Used,
    longtodate(s.CREATION_TIME),
    per.EXTERNAL_ID
FROM
    SUBSCRIPTIONS s

LEFT JOIN Persons p ON  P.CENTER = S.OWNER_CENTER  AND P.ID = S.OWNER_ID

LEFT JOIN
    INVOICELINES invl
ON
    invl.CENTER = s.INVOICELINE_CENTER
    AND invl.id = s.INVOICELINE_ID
    AND invl.SUBID = s.INVOICELINE_SUBID


LEFT JOIN
    PRIVILEGE_USAGES pu
ON
    s.INVOICELINE_CENTER = pu.TARGET_CENTER
    AND s.INVOICELINE_ID= pu.TARGET_ID
    AND s.INVOICELINE_SUBID = pu.TARGET_SUBID
    AND pu.TARGET_SERVICE = 'InvoiceLine'
LEFT JOIN
    SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    AND sp.CANCELLED = 0

LEFT JOIN PERSONS per
ON
	s.OWNER_CENTER = per.CENTER
	AND s.OWNER_ID = per.ID

           LEFT JOIN PERSON_EXT_ATTRS email
        ON
            p.center=email.PERSONCENTER
            AND p.id=email.PERSONID
            AND email.name='_eClub_Email'

LEFT JOIN PERSON_EXT_ATTRS pea_mobile
ON
    pea_mobile.PERSONCENTER = p.center
	AND pea_mobile.PERSONID = p.id
	AND pea_mobile.NAME = '_eClub_PhoneSMS'

LEFT JOIN Centers c

ON  s.OWNER_CENTER = c.id
LEFT JOIN
    PRIVILEGE_USAGES pu2
ON
    sp.ID = pu2.TARGET_ID
    AND pu2.TARGET_SERVICE = 'SubscriptionPrice'
LEFT JOIN
    PRIVILEGE_GRANTS pg2
ON
    pu2.GRANT_ID = pg2.ID
    AND pg2.GRANTER_SERVICE IN ('StartupCampaign',
                                'ReceiverGroup')
LEFT JOIN
    PRIVILEGE_GRANTS pg
ON
    pu.GRANT_ID = pg.ID
    AND pg.GRANTER_SERVICE IN ('StartupCampaign',
                               'ReceiverGroup')
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS prg
ON
    prg.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE = 'ReceiverGroup'
LEFT JOIN
    PRIVILEGE_RECEIVER_GROUPS prg2
ON
    prg2.ID = pg2.GRANTER_ID
    AND pg2.GRANTER_SERVICE = 'ReceiverGroup'
LEFT JOIN
    STARTUP_CAMPAIGN sc2
ON
    sc2.ID = pg2.GRANTER_ID
    AND pg2.GRANTER_SERVICE='StartupCampaign'
LEFT JOIN
    STARTUP_CAMPAIGN sc
ON
    sc.ID = pg.GRANTER_ID
    AND pg.GRANTER_SERVICE='StartupCampaign'
LEFT JOIN
    CAMPAIGN_CODES cc2
ON
    pu2.CAMPAIGN_CODE_ID = cc2.ID
LEFT JOIN
    CAMPAIGN_CODES cc
ON
    pu.CAMPAIGN_CODE_ID = cc.ID
LEFT JOIN
    INVOICES inv
ON
    inv.CENTER = s.INVOICELINE_CENTER
    AND inv.ID = s.INVOICELINE_ID
WHERE
    (
        sc.ID IS NOT NULL
        OR sc2.ID IS NOT NULL
        OR prg.ID IS NOT NULL
        OR prg2.ID IS NOT NULL)
    AND s.CREATION_TIME > ($$SalesFromDate$$)::bigint
    AND s.CREATION_TIME <($$SalesToDate$$+1000*60*60*24)::bigint
    AND s.OWNER_CENTER IN($$Scope$$)
    AND ((
            $$cam_type$$ = 'startup'
            AND (
                (sc.ID)::varchar = $$CampaignId$$
                OR (sc2.ID)::varchar = $$CampaignId$$))
        OR (
            $$cam_type$$ = 'priv'
            AND (
                prg.NAME = $$CampaignId$$
                OR prg2.name = $$CampaignId$$)))

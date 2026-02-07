         SELECT DISTINCT
             c.id,
             c.SHORTNAME                                                                                                                                                                        members_club,
             CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS person_STATUS,
             p.CENTER || 'p' || p.ID                                                                                                                                                          member_id,
                         p.external_id                                                                                                                                                                                                                                                                                                                                                   external_id,
             mpr.CACHED_PRODUCTNAME                                                                                                                                                             add_on_type,
             CASE  S.State  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED'  END AS Subscription_State,

                         sa.START_DATE,
             sa.END_DATE,
             sa.INDIVIDUAL_PRICE_PER_UNIT Price,
             HLN.TXTVALUE  Home_Locker_Number,
			 HLL.TXTVALUE   Home_Locker_Location,
			 ALN.TXTVALUE  Away_Locker_Number,
			 ALO.TXTVALUE  Away_Locker_Location

         FROM
             SUBSCRIPTION_ADDON sa
                 left join centers sa_c on sa_c.id = sa.CENTER_ID
         JOIN
             SUBSCRIPTIONS s
         ON
             s.CENTER = sa.SUBSCRIPTION_CENTER
             AND s.ID = sa.SUBSCRIPTION_ID
         JOIN
             PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
        
         LEFT JOIN
             PERSON_EXT_ATTRS HLN
         ON
             HLN.PERSONCENTER = p.CENTER
             AND HLN.PERSONID = p.ID
             AND HLN.NAME = 'HOME_LOCKER_NUMBER'
		
   LEFT JOIN
             PERSON_EXT_ATTRS HLL
         ON
             HLL.PERSONCENTER = p.CENTER
             AND HLL.PERSONID = p.ID
             AND HLL.NAME = 'HOME_LOCKER_LOCATION'

   LEFT JOIN
             PERSON_EXT_ATTRS ALN
         ON
             ALN.PERSONCENTER = p.CENTER
             AND ALN.PERSONID = p.ID
             AND ALN.NAME = 'AWAY_LOCKER_NUMBER'

   LEFT JOIN
             PERSON_EXT_ATTRS ALO
         ON
             ALO.PERSONCENTER = p.CENTER
             AND ALO.PERSONID = p.ID
             AND ALO.NAME = 'AWAY_LOCKER_LOCATION'			 
			 
			 
         JOIN
             CENTERS c
         ON
             c.ID = p.CENTER
         LEFT JOIN
             PERSONS m
         ON
             m.CENTER = c.MANAGER_CENTER
             AND m.ID = c.MANAGER_ID
         JOIN
             MASTERPRODUCTREGISTER mpr
         ON
             mpr.ID = sa.ADDON_PRODUCT_ID
         LEFT JOIN
             MASTERPRODUCTREGISTER mpr2
         ON
             mpr2.GLOBALID = mpr.GLOBALID
             AND mpr2.SCOPE_TYPE = 'C'
             AND mpr2.SCOPE_ID = sa.CENTER_ID
         JOIN
             PRODUCTS prod
         ON
             prod.CENTER = sa.SUBSCRIPTION_CENTER
             AND prod.GLOBALID = mpr.GLOBALID
         LEFT JOIN
             CASHCOLLECTIONCASES cc
         ON
             cc.PERSONCENTER = p.CENTER
             AND cc.PERSONID = p.ID
             AND cc.CLOSED = 0
             AND cc.SUCCESSFULL = 0
             AND cc.MISSINGPAYMENT = 1
         WHERE
                         sa.CENTER_ID IN($$Scope$$) AND
             (
                 sa.END_DATE >= CURRENT_TIMESTAMP
                 OR sa.END_DATE IS NULL )
             AND sa.CANCELLED = 0
			 AND mpr.CACHED_PRODUCTNAME like '%Locker%'
   
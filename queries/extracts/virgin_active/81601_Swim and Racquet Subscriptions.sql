SELECT distinct
	--q1.PT_ID,
	--q1.PT_NAME,
         q1.pt_by_dd_club_name AS "PT_BY_DD_CLUB_NAME",
     q1.members_club AS "MEMBERS_CLUB",
         q1.person_status AS "PERSON_STATUS",
         q1.Subscription_State AS "SUBSCRIPTION_STATE",
         q1.Subscription_Sub_state AS "SUBSCRIPTION_SUB_STATE",
         q1.member_id AS "MEMBER_ID",
		 q1.external_id as "EXTERNAL_ID",
		 q1.Sub_ID as "SUBSCRIPTION_ID",
         --q1.title AS "TITLE",
         --q1.firstname AS "FIRSTNAME",
         --q1.Lastname AS "LASTNAME",
         q1.add_on_type AS "ADD_ON_TYPE",
         q1.rec_clipcard_clips as "MAX_CLIP",     
         q1.start_date AS "START_DATE",
         q1.end_date AS "END_DATE",
         q1.binding_end_date AS "BINDING_END_DATE",
          q1.member_price as "MEMBERPRICE",
         q1.headline_price AS "HEADLINE_PRICE",
     ar_debt.BALANCE AS "BALANCE",
     longtodate(q1.creation_time) as "Creation Time"
 FROM
     (
         SELECT DISTINCT
 --            mpr.id       mpr_id,
 --            mpr.GLOBALID mpr_global_id,
 --            sa.CENTER_ID center__id,
 --            prod.NAME    cat,
 --            mpr2.ID      mpr2_id,
			--PT.TXTVALUE PT_ID,
			--PE.Fullname PT_NAME,
             c.id,
             c.SHORTNAME                                                                                                                                                                        members_club,
             CASE  p.STATUS  WHEN 0 THEN 'LEAD'  WHEN 1 THEN 'ACTIVE'  WHEN 2 THEN 'INACTIVE'  WHEN 3 THEN 'TEMPORARYINACTIVE'  WHEN 4 THEN 'TRANSFERED'  WHEN 5 THEN 'DUPLICATE'  WHEN 6 THEN 'PROSPECT'  WHEN 7 THEN 'DELETED' WHEN 8 THEN  'ANONYMIZED'  WHEN 9 THEN  'CONTACT'  ELSE 'UNKNOWN' END AS person_STATUS,
             p.CENTER || 'p' || p.ID                                                                                                                                                            member_id,
             prod.NAME                                                                                                                                                             add_on_type,
             CASE  S.State  WHEN 2 THEN 'ACTIVE'  WHEN 3 THEN 'ENDED'  WHEN 4 THEN 'FROZEN'  WHEN 7 THEN 'WINDOW' WHEN 8 THEN 'CREATED'  END AS Subscription_State,
                         CASE  S.Sub_State  WHEN 1 THEN 'NONE' WHEN 2 THEN 'N/A' WHEN 3 THEN 'UPGRADED' WHEN 4 THEN 'DOWNGRADED' WHEN 5 THEN 'EXTENDED' WHEN 6 THEN 'TRANSFERRED' WHEN 7 THEN 'REGRETTED' WHEN 8 THEN 'CANCELLED' WHEN 9 THEN 'BLOCKED' WHEN 10 THEN 'CHANGED' END AS Subscription_Sub_state,
                         s.START_DATE,
             s.END_DATE,
             s.BINDING_END_DATE,
             s.creation_time, 
             s.subscription_price as Member_price,
             s.rec_clipcard_clips,   
             prod.PRICE     headline_price,
             cc.AMOUNT                                                                                                                       CC_AMOUNT,
             ROUND(months_between(CURRENT_TIMESTAMP,s.START_DATE),2)                                                                                  months_from_start,
             atts.TXTVALUE                                                                                                                   title,
            --RG 20/06/22 - added External ID and Sub ID below as per request: SR-270136
             p.external_id External_ID,
			 s.center ||'ss'|| s.id  Sub_ID,		 
			 p.FIRSTNAME,
			 p.LASTNAME,
             p.ADDRESS1,
             p.ADDRESS2,
             p.ADDRESS3,
             p.ZIPCODE,
             p.CITY,
             m.FULLNAME     manager_name,
             c.PHONE_NUMBER club_phone_number ,
             oldId.TXTVALUE legacySystemId,
           --  mpr.INFO_TEXT,
             m.CENTER || 'p' || m.ID manager_pid,
             p.CENTER                p_center,
             p.ID                    p_id,
                         sa_c.id addon_center,
                         sa_c.shortname pt_by_dd_club_name
         FROM   
           SUBSCRIPTIONS s
           join SUBSCRIPTIONTYPES st
           ON
    s.SubscriptionType_Center = st.Center
AND s.SubscriptionType_ID = st.ID
--and st.st_type in (2)
        
         left join centers sa_c on sa_c.id = s.CENTER    
         JOIN
            PERSONS p
         ON
             p.CENTER = s.OWNER_CENTER
             AND p.ID = s.OWNER_ID
         LEFT JOIN
             PERSON_EXT_ATTRS atts
         ON
             atts.PERSONCENTER = p.CENTER
             AND atts.PERSONID = p.ID
             AND atts.NAME = '_eClub_Salutation'
         LEFT JOIN
             PERSON_EXT_ATTRS oldId
         ON
             oldId.PERSONCENTER = p.CENTER
             AND oldId.PERSONID = p.ID
             AND oldId.NAME = '_eClub_OldSystemPersonId'
			 
		-- --RG 28.03.23 added in the PT ID and name for Georgina to track on this here	 
		 	-- LEFT JOIN 
			-- PERSON_EXT_ATTRS PT
			-- ON p.center = PT.personcenter
			-- and p.id = PT.personid
			-- and PT.Name = 'PT'
			-- and PT.TXTVALUE IS NOT NULL
			
			-- LEFT JOIN
			-- Persons PE 
			-- ON PE.CENTER || 'p' || PE.ID = PT.TXTVALUE
			-- --and PE.id = PT.personid
			
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
    Products prod
ON
    st.Center = prod.Center
AND st.Id = prod.Id
         LEFT JOIN
             CASHCOLLECTIONCASES cc
         ON
             cc.PERSONCENTER = p.CENTER
             AND cc.PERSONID = p.ID
             AND cc.CLOSED = 0
             AND cc.SUCCESSFULL = 0
             AND cc.MISSINGPAYMENT = 1
         WHERE
                         s.CENTER IN(:Scope) AND
             (
                 s.END_DATE >= CURRENT_TIMESTAMP
                 OR s.END_DATE IS NULL )
             
             AND EXISTS
             (
                 SELECT
                     1
                 FROM
                     PRODUCT_AND_PRODUCT_GROUP_LINK link
                 WHERE
                     link.PRODUCT_CENTER = prod.CENTER
                     AND link.PRODUCT_ID = prod.ID
                     AND link.PRODUCT_GROUP_ID IN (29002,26001) ) )q1
 LEFT JOIN
     ACCOUNT_RECEIVABLES ar_debt
 ON
     ar_debt.CUSTOMERCENTER = q1.p_center
     AND ar_debt.CUSTOMERID = q1.p_id
     AND ar_debt.AR_TYPE = 5
ORDER BY q1.pt_by_dd_club_name asc

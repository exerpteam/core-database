-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    product_spons_pg AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'PRODUCT_GROUP'
            AND pp.ref_id = ppgl.product_group_id)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )
    ,
    product_spons_global AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'GLOBAL_PRODUCT'
            AND pp.REF_GLOBALID = pr.globalid)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )
    ,
    product_spons_local AS
    (
        SELECT
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
        FROM
            products pr
        JOIN
            product_and_product_group_link ppgl
        ON
            ppgl.product_center = pr.center
        AND ppgl.product_id = pr.id
        JOIN
            PRODUCT_PRIVILEGES pp
        ON
            (
                pp.ref_type = 'LOCAL_PRODUCT'
            AND pp.REF_CENTER = pr.center
            AND pp.REF_ID = pr.id)
        JOIN
            PRIVILEGE_GRANTS pg
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        AND pg.SPONSORSHIP_NAME!= 'NONE'
        AND (
                pg.VALID_TO IS NULL
            OR  pg.VALID_TO > datetolong(TO_CHAR(CURRENT_TIMESTAMP, 'YYYY-MM-DD HH24:MM')) )
        AND pg.GRANTER_SERVICE='CompanyAgreement'
        JOIN
            COMPANYAGREEMENTS ca
        ON
            pg.GRANTER_CENTER=ca.center
        AND pg.granter_id=ca.id
        AND pg.granter_subid = ca.subid
        GROUP BY
            ca.center,
            ca.id,
            ca.subid,
            pr.globalid,
            pg.SPONSORSHIP_NAME,
            pg.SPONSORSHIP_AMOUNT
    )


SELECT DISTINCT
    
    center.id                          AS "ClubNumber",
    center.NAME                        AS "Club",
    p.EXTERNAL_ID			   		AS "ExternalUserId",
	p.center || 'p' || p.id            AS "UserNumber",
	subs.center || 'ss' || subs.id  AS "SubsId", 							
	p.firstname                        AS "Name",
	p.lastname                         AS "LastName",
	CASE p.sex
	WHEN 'M' THEN 'MALE'
	WHEN 'F' THEN 'FEMALE'
	WHEN 'C' THEN 'OTHER'
	ELSE 'OTHER'
	END  AS "Sex",

	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "BirthDate",
	email.txtvalue                     AS "Email",
	home.txtvalue                      AS "Phone",
	mobile.txtvalue                    AS "MobilePhone",
    workphone.txtvalue                 AS "WorkPhone",
    
	p.zipcode                          AS "PostalCode",
    p.city                             AS "City",
        
CASE p.country
WHEN 'DE' THEN 'Germany'
WHEN 'AT' THEN 'Austria'
WHEN 'CH' THEN 'Switzerland'
WHEN 'FR' THEN 'France'
WHEN 'PL' THEN 'Poland'
ELSE p.country
END AS "Country",

	
CASE clh.name
WHEN NULL THEN '0'
ELSE payment_ar.balance END AS "PaymentArBalance",


	cash_ar.balance         AS "CashArBalace",
	subs.start_date AS "StartDate",
	subs.end_date AS "EndDate",

	
	
	prod.name  AS "SubsName",

CASE
        WHEN has_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_EFT_SUB,
    CASE
        WHEN has_cash_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CASH_SUB,
	
    

CASE subt.is_addon_subscription 
	WHEN '1' THEN '1'
	WHEN '0' THEN '0'
	END AS "IsPT",

CASE subt.periodunit
  	WHEN 0 THEN 'WEEK'
	WHEN 1 THEN 'DAY'
	WHEN 2 THEN 'MONTH'
	END AS "TimePeriod",

CASE 
	WHEN subt.st_type = 0 THEN latest_sub.periodcount
	WHEN subt.st_type = 1 THEN latest_sub.bindingperiodcount
	WHEN subt.st_type = 2 THEN latest_sub.bindingperiodcount
	END AS "ContractLength",
	
	subt.periodcount  AS "ContractFrequency",

	subs.subscription_price AS "MembershipFee",
	
	
	
	---OTHER PAYER---
CASE
        WHEN op.CENTER IS NOT NULL
        THEN op.EXTERNAL_ID
        ELSE ''
    	END AS "PayerID",



	CASE
        WHEN op.center IS NOT NULL
        THEN op.FIRSTNAME || ' ' || op.LASTNAME
        ELSE NULL
    	END    AS "PayerName",


	
personCreation.txtvalue            AS personCreationDate,	


	




CASE p.blacklisted 
WHEN '1' THEN 'Blacklisted' 
WHEN '2' THEN 'Suspended' 
ELSE 'NO' 						END AS "Blocked",


--additional information--


pa.active as "DefaultAgreement",
clh.name AS "ClearingHouseName",
    
CASE
        WHEN ( op.center IS NULL
                AND pa.state IS NOT NULL
                AND ( has_sub.owner_center IS NOT NULL
                    OR pay_for.payer_center IS NOT NULL ) )
        THEN CASE pa.STATE  WHEN 1 THEN 'CREATED'  WHEN 2 THEN 'SENT'  WHEN 3 THEN 'FAILED'  WHEN 4 THEN 'OK'  WHEN 5 THEN 'ENDED BY DEBITOR''S BANK'  WHEN 6 THEN  'ENDED BY THE CLEARING HOUSE'  WHEN 7 THEN 'ENDED BY DEBITOR'  WHEN 8 THEN 'SHAL BE CANCELLED'  WHEN 9 THEN 'END REQUEST SENT'  WHEN 10 THEN  'ENDED BY CREDITOR'  WHEN 11 THEN 'NO AGREEMENT WITH DEBITOR'  WHEN 12 THEN 'DEPRECATED'  WHEN 13 THEN 'NOT NEEDED' WHEN 14 THEN  'INCOMPLETE' WHEN 15 THEN  'TRANSFERRED' ELSE 'UNKNOWN' END
        ELSE ''
    	END AS dd_state,


----Company data---




CASE
        WHEN subt.st_type = 1
            AND coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME) IS NOT NULL
        THEN coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME)
        ELSE NULL
    END AS Sponsorship ,

CASE
        WHEN subt.st_type = 1
            AND coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME) IS NOT NULL
        THEN coalesce(psl.SPONSORSHIP_AMOUNT,psg.SPONSORSHIP_AMOUNT,psp.SPONSORSHIP_AMOUNT)
        ELSE NULL
    END AS Sponsorship_amount,

comp.lastname AS "Company",

CASE
        WHEN comp.CENTER IS NOT NULL
        THEN comp.CENTER||'p'||comp.ID
        ELSE NULL
    END                                AS "CompanyID",
    
    cag.NAME                           AS "CompanyAgreement",

CASE
        WHEN pay_for.PAYER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
        END AS "IsPayer",

  

---Need for exclusion---

CASE WHEN
    p.STATUS IN (1,2,3) THEN 
    TO_CHAR(cp.LAST_ACTIVE_END_DATE,'DD-MM-YYYY') 
    ELSE 'null' 
    END AS "Last Active End Date",
    
	    
    CASE p.STATUS
        WHEN 0 THEN 'LEAD'
        WHEN 1 THEN 'ACTIVE'
        WHEN 2 THEN 'INACTIVE'
        WHEN 3 THEN 'TEMPORARY INACTIVE'
        WHEN 4 THEN 'TRANSFERRED'
        WHEN 5 THEN 'DUPLICATE'
        WHEN 6 THEN 'PROSPECT'
        WHEN 7 THEN 'DELETED'
        WHEN 8 THEN 'ANONYMIZED'
        WHEN 9 THEN 'CONTACT'
        ELSE 'UNKNOWN'
    								END AS "STATUS",

CASE subs.state
	WHEN 2 THEN 'active'
	WHEN 4 THEN 'frozen'
	WHEN 8 THEN 'created'
END AS "SubsState",

     
 CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType
    
       
    
    
FROM
    persons p
JOIN
    CENTERS center
ON
    p.center = center.id
LEFT JOIN
    zipcodes zipcode
ON
    zipcode.country = p.country
    AND zipcode.zipcode = p.zipcode
LEFT JOIN
    PERSON_EXT_ATTRS salutation
ON
    p.center=salutation.PERSONCENTER
    AND p.id=salutation.PERSONID
    AND salutation.name='_eClub_Salutation'
LEFT JOIN
    PERSON_EXT_ATTRS personCreation
ON
    p.center=personCreation.PERSONCENTER
    AND p.id=personCreation.PERSONID
    AND personCreation.name='CREATION_DATE'
LEFT JOIN
    PERSON_EXT_ATTRS home
ON
    p.center=home.PERSONCENTER
    AND p.id=home.PERSONID
    AND home.name='_eClub_PhoneHome'
LEFT JOIN
    PERSON_EXT_ATTRS mobile
ON
    p.center=mobile.PERSONCENTER
    AND p.id=mobile.PERSONID
    AND mobile.name='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS workphone
ON
    p.center=workphone.PERSONCENTER
    AND p.id=workphone.PERSONID
    AND workphone.name='_eClub_PhoneWork'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    p.center=email.PERSONCENTER
    AND p.id=email.PERSONID
    AND email.name='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS personcomment
ON
    p.center=personcomment.PERSONCENTER
    AND p.id=personcomment.PERSONID
    AND personcomment.name='_eClub_Comment'



LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    p.center = osd.PERSONCENTER
    AND p.id = osd.PERSONID
	AND osd.name = 'OriginalStartDate'


LEFT JOIN
     PERSON_EXT_ATTRS source
 ON
     p.center=source.PERSONCENTER
     AND p.id=source.PERSONID
     AND source.name='SOURCES_DE'

---tags---

LEFT JOIN
     PERSON_EXT_ATTRS bs
 ON
     p.center=bs.PERSONCENTER
     AND p.id=bs.PERSONID
     AND bs.name='CHARGEBSDE'
LEFT JOIN
     PERSON_EXT_ATTRS tow
 ON
     p.center=tow.PERSONCENTER
     AND p.id=tow.PERSONID
     AND tow.name='CHARGETOWDE'



LEFT JOIN
     PERSON_EXT_ATTRS staff
 ON
     p.center=staff.PERSONCENTER
     AND p.id=staff.PERSONID
     AND staff.name='Sales_Staff'

LEFT JOIN
     persons staff2
 ON
     staff2.center||'p'||staff2.id = staff.TXTVALUE
 LEFT JOIN
     PERSON_EXT_ATTRS sales_name
 ON
     staff2.center=sales_name.PERSONCENTER
     AND staff2.id=sales_name.PERSONID
     AND sales_name.name='p.FULLNAME'


LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
	AND payment_ar.STATE = 0
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
    AND cash_ar.CUSTOMERID=p.id
    AND cash_ar.AR_TYPE = 1
	AND cash_ar.STATE = 0
LEFT JOIN
    RELATIVES comp_rel
ON
    comp_rel.center=p.center
    AND comp_rel.id=p.id
    AND comp_rel.RTYPE = 3
    AND comp_rel.STATUS < 3


LEFT JOIN
    COMPANYAGREEMENTS cag
ON
    cag.center= comp_rel.RELATIVECENTER
    AND cag.id=comp_rel.RELATIVEID
    AND cag.subid = comp_rel.RELATIVESUBID
LEFT JOIN
    persons comp
ON
    comp.center = cag.center
    AND comp.id=cag.id

LEFT JOIN
    ENTITYIDENTIFIERS ei
ON
    ei.REF_CENTER = p.CENTER
    AND ei.REF_ID = p.id
    AND ei.entitystatus = 1
	AND ei.ref_type = 1

LEFT JOIN
    PAYMENT_ACCOUNTS paymentaccount
ON
    paymentaccount.center = payment_ar.center
    AND paymentaccount.id = payment_ar.id
LEFT JOIN
    PAYMENT_AGREEMENTS pa
ON
    paymentaccount.ACTIVE_AGR_CENTER = pa.center
    AND paymentaccount.ACTIVE_AGR_ID = pa.id
    AND paymentaccount.ACTIVE_AGR_SUBID = pa.subid

LEFT JOIN  payment_cycle_config pcc
ON
pcc.ID = pa.payment_cycle_config_id

LEFT JOIN CLEARINGHOUSES clh
ON
    clh.ID = pa.clearinghouse

 ---payer---

LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12 ---paid for by me
    AND op_rel.STATUS < 3
LEFT JOIN
    PERSONS op
ON
    op.center = op_rel.center
    AND op.id = op_rel.id
LEFT JOIN
    ACCOUNT_RECEIVABLES otherPayerAR
ON
    otherPayerAR.CUSTOMERCENTER = op.center
    AND otherPayerAR.CUSTOMERID = op.id
    AND otherPayerAR.AR_TYPE = 4
	AND otherPayerAR.STATE = 0
    --- other payer---



LEFT JOIN
    (
        SELECT
            row_number() over (partition BY p.CENTER, p.ID ORDER BY subs.END_DATE DESC ) AS lastone,
            subs.OWNER_CENTER,
            subs.OWNER_ID,
            subs.center,
            subs.id,
			subs.state,
            subs.sub_state,
            pr.name,
            subs.start_date,
            subs.end_date,
			subs.binding_end_date,
			subs.billed_until_date,
			subs.subscription_price,
			subs.creation_time,
			stype.bindingperiodcount,
			stype.periodcount,
			stype.periodunit,
			stype.auto_stop_on_binding_end_date,
			stype.unrestricted_freeze_allowed,
			stype.autorenew_binding_count,
			stype.autorenew_binding_unit,
			stype.is_addon_subscription,
			ppg.product_group_id,
			stype.st_type
			
        FROM
            SUBSCRIPTIONS subs

		JOIN 
			subscriptiontypes stype
		ON
			stype.center = subs.SUBSCRIPTIONTYPE_CENTER
		AND stype.ID = subs.SUBSCRIPTIONTYPE_ID
		
        JOIN
            PRODUCTS pr
        ON
            subs.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
        AND subs.SUBSCRIPTIONTYPE_ID = pr.ID

		JOIN PRODUCT_AND_PRODUCT_GROUP_LINK ppg
		ON
			pr.center = ppg.PRODUCT_CENTER
		AND pr.id = ppg.PRODUCT_ID

        JOIN
            PERSONS p
        ON
            p.center = subs.OWNER_CENTER
        AND p.ID = subs.OWNER_ID
	
        WHERE
            subs.STATE IN (2,4,3,7)--active frozen ended window
			AND subs.sub_STATE NOT IN (8) --cancelled
        AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    pr.center = ppg.PRODUCT_CENTER
                AND pr.id = ppg.PRODUCT_ID
                AND ppg.PRODUCT_GROUP_ID IN (1605,2802)) ) latest_sub
ON
    latest_sub.owner_center = p.center
AND latest_sub.owner_id = p.id
AND latest_sub.lastone = 1



JOIN
	SUBSCRIPTIONS subs
ON
	subs.owner_center = p.CENTER 
	AND subs.OWNER_ID = p.id
	
JOIN
SUBSCRIPTIONTYPES subt
ON
subt.center = subs.center
AND subt.id = subs.subscriptiontype_id

LEFT JOIN
    PRODUCTS prod
ON
    prod.CENTER = subs.SUBSCRIPTIONTYPE_CENTER
    AND prod.id = subs.SUBSCRIPTIONTYPE_ID

LEFT JOIN
       PERSONS cp
        ON
            cp.center = subs.OWNER_CENTER
        AND cp.ID = subs.OWNER_ID
---sponsorship fixed---
LEFT JOIN
    relatives ca_rel
ON
    ca_rel.center = p.center
AND ca_rel.id = p.id
AND ca_rel.rtype = 3
AND ca_rel.STATUS < 3
LEFT JOIN
    product_spons_local psl
ON
    psl.center=ca_rel.relativecenter
AND psl.id = ca_rel.relativeid
AND psl.subid = ca_rel.relativesubid
AND psl.globalid = prod.GLOBALID
LEFT JOIN
    product_spons_global psg
ON
    psg.center=ca_rel.relativecenter
AND psg.id = ca_rel.relativeid
AND psg.subid = ca_rel.relativesubid
AND psg.globalid = prod.GLOBALID
LEFT JOIN
    product_spons_pg psp
ON
    psp.center=ca_rel.relativecenter
AND psp.id = ca_rel.relativeid
AND psp.subid = ca_rel.relativesubid
AND psp.globalid = prod.GLOBALID


---addons---

LEFT JOIN SUBSCRIPTION_ADDON sa
ON sa.subscription_center = subs.owner_center
AND sa.subscription_id = subs.id
AND sa.cancelled = 0

---pay for---

LEFT JOIN
    (
        SELECT DISTINCT
            rel.center AS PAYER_CENTER,
            rel.id     AS PAYER_ID
        FROM
            PERSONS mem
        JOIN
            SUBSCRIPTIONS sub
        ON
            mem.center = sub.OWNER_CENTER
            AND mem.id = sub.OWNER_ID
            AND sub.STATE IN (2,4,8)
            AND (
                sub.end_date IS NULL
                OR sub.end_date > sub.BILLED_UNTIL_DATE )
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID


        JOIN
            RELATIVES rel
        ON
            rel.RELATIVECENTER = mem.center
            AND rel.RELATIVEID = mem.id
            AND rel.RTYPE = 12
            AND rel.STATUS < 3
        WHERE
            st.ST_TYPE = 1
            AND mem.persontype NOT IN (2,8) ) pay_for
ON
    pay_for.payer_center = p.center
    AND pay_for.payer_id = p.id



  --- has eft sub--
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 1
            AND sub.STATE IN (2,4,8) ) has_sub ---active frozen created
ON
    has_sub.owner_center = p.center
    AND has_sub.owner_id = p.id
    --- has cash sub---
LEFT JOIN
    (
        SELECT DISTINCT
            sub.owner_center,
            sub.owner_id
        FROM
            SUBSCRIPTIONS sub
        JOIN
            SUBSCRIPTIONTYPES st
        ON
            st.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND st.id = sub.SUBSCRIPTIONTYPE_ID
        WHERE
            st.ST_TYPE = 0
            AND sub.STATE IN (2,4,8) ) has_cash_sub
ON
    has_cash_sub.owner_center = p.center
    AND has_cash_sub.owner_id = p.id





    
LEFT JOIN
    RELATIVES pt_rel
ON
    pt_rel.CENTER = p.center
    AND pt_rel.id = p.id
    AND pt_rel.STATUS < 3
    AND ( (
            p.PERSONTYPE = 3 ---friend
            AND pt_rel.RTYPE = 1 )  ---my friend
        OR (
            p.PERSONTYPE = 6  ---family
            AND pt_rel.RTYPE = 4 ) )  ---my family
LEFT JOIN
    PERSONS pt_rel_p
ON
    pt_rel_p.center = pt_rel.RELATIVECENTER
    AND pt_rel_p.id = pt_rel.RELATIVEID



---sponsorship---

LEFT JOIN
    (
        SELECT
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT
        FROM
            relatives car
        JOIN COMPANYAGREEMENTS ca
        ON
            ca.center = car.RELATIVECENTER
            AND ca.id = car.RELATIVEID
            AND ca.SUBID = car.RELATIVESUBID
        JOIN PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_SERVICE='CompanyAgreement'
            AND pg.GRANTER_CENTER=ca.center
            AND pg.granter_id=ca.id
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME!= 'NONE'
            AND
            (
                pg.VALID_TO IS NULL
                OR pg.VALID_TO > datetolong(TO_CHAR(current_timestamp, 'YYYY-MM-DD HH24:MM'))
            )
        JOIN PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
        WHERE
            car.RTYPE = 3
            AND car.STATUS < 3
        GROUP BY
            car.center,
            car.id,
            pg.SPONSORSHIP_NAME,
            pp.REF_GLOBALID,
            pg.SPONSORSHIP_AMOUNT
    )
    priv
ON
    priv.center=p.center
    AND priv.id = p.id
    AND priv.REF_GLOBALID = prod.GLOBALID


WHERE
    p.center IN ($$scope$$)
	AND p.persontype NOT IN (2)   --not staff
    AND p.status NOT IN (5)   --not duplicate
	AND subs.state IN (2,4,8)--active frozen created
	AND p.status IN (1,3)   --Active Tempinactive--

--AND coalesce(psl.SPONSORSHIP_NAME,psg.SPONSORSHIP_NAME,psp.SPONSORSHIP_NAME) IS NOT NULL--
             
        


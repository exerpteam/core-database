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
    center.id                          AS "ExerpClubNumber",
    center.NAME                        AS "ExerpCenterName",
    p.EXTERNAL_ID			   		AS "ExternalUserId",
	p.center || 'p' || p.id            AS "UserNumber",
	latest_sub.center || 'ss' || latest_sub.id  AS "ExternalContractId", 							
	p.firstname                        AS "Name",
	p.lastname                         AS "LastName",
	CASE p.sex
	WHEN 'M' THEN 'MALE'
	WHEN 'F' THEN 'FEMALE'
	WHEN 'C' THEN 'OTHER'
	END  AS "Sex",

	TO_CHAR(p.birthdate, 'YYYY-MM-DD') AS "BirthDate",
	email.txtvalue                     AS "Email",
	home.txtvalue                      AS "Phone",
	mobile.txtvalue                    AS "MobilePhone",
    workphone.txtvalue                 AS "WorkPhone",
    
CASE WHEN
   (p.CENTER, p.ID) NOT IN (
        SELECT
                pea.PERSONCENTER,
                pea.PERSONID
        FROM PERSON_EXT_ATTRS pea
        WHERE
				pea.PERSONCENTER IN (:scope)
				AND pea.NAME IN ('_eClub_Picture','_eClub_PictureFace')
                AND pea.mimevalue IS NOT NULL
)
   THEN 'NoPhoto'
   ELSE 'Photo'
										END AS "PhotoUrl",
	NULL                      AS "Company",	
	p.ADDRESS1                         AS "Street",
    p.ADDRESS2                         AS "Street2",
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


CASE center.id
WHEN 2 THEN '101'
WHEN 9 THEN '116'
WHEN 13 THEN '113'
WHEN 14 THEN '122'
WHEN 24 THEN '124'
WHEN 30 THEN '115'
WHEN 45 THEN '103'
WHEN 47 THEN '121'
WHEN 48 THEN '104'
WHEN 49 THEN '106'
WHEN 55 THEN '105'
WHEN 89 THEN '102'
WHEN 156 THEN '112'
WHEN 157 THEN '114'
WHEN 100 THEN '130/140'
									END AS "ClubNumber",
ei.IDENTITY                      AS "MemberCardNumber",
	
staff2.fullname 					AS "Consultant",

CASE
WHEN p.status IN (1,2,3)THEN '1'
ELSE '0'
							END AS "IsActive",---active temp inactive---
CASE
WHEN p.status IN (0,6,9)THEN '1'
ELSE '1'
							END AS "IsGuest", ---lead prospect contact---
	----CASE payment_ar.balanc empty when they have no payment agreement
CASE clh.name
WHEN NULL THEN '0'
ELSE payment_ar.balance END AS "TodayBalance",


	cash_ar.balance                       AS "PrepaidBalance",
	NULL AS							 "SignUpDate",

	latest_sub.start_date AS "StartDate",
	latest_sub.end_date AS "EndDate",
NULL AS "StartChargingFromDate",

	NULL AS "MinCancelTimeMonths",---add formuala in excel if nec
CASE latest_sub.auto_stop_on_binding_end_date 
WHEN '1' THEN '1'
WHEN '0' THEN '0'
END AS "IsAutomaticallyEnded",
---latest_sub.autorenew_binding_count AS "AutomaticRenew",---
NULL AS "AutomaticRenew",
'0' AS "StopChargingAfterMinPeriod",
CASE
	WHEN latest_sub.st_type = 0 THEN '1'
	ELSE '0' END AS "IsUpfront",
CASE latest_sub.unrestricted_freeze_allowed
WHEN '0' THEN '0'
WHEN '1' THEN '1'
END AS "FreezeAvailable",
	

	'0' AS "IsProrata",
	'1' AS "ProrataDay",

		
	NULL AS "PaymentPlan",
	NULL AS "VisitLimit", 
	NULL AS "RemainingVisitCount",
	NULL AS "VisitPeriod",   
 
CASE latest_sub.is_addon_subscription 
WHEN '1' THEN '1'
WHEN '0' THEN '0'
END AS "IsAdditionalContract",

CASE 
WHEN latest_sub.is_addon_subscription = 'FALSE' THEN '0'
ELSE '1' END AS "SynchronizeWithContract",

	CASE latest_sub.periodunit
  	WHEN 0 THEN 'WEEK'
	WHEN 1 THEN 'DAY'
	WHEN 2 THEN 'MONTH'
	END AS "TimePeriod",

CASE 
WHEN latest_sub.st_type = 0 THEN latest_sub.periodcount
WHEN latest_sub.st_type = 1 THEN latest_sub.bindingperiodcount
WHEN latest_sub.st_type = 2 THEN latest_sub.bindingperiodcount
END AS "ContractLength",
	
	latest_sub.periodcount  AS "ContractFrequency",

	
	'19' AS "VatRate",
	
	latest_sub.subscription_price AS "MembershipFee",
NULL AS "StartGeneratingTransactionsFromDate",
	




	'1' AS "ForcePaymentPlan",
	'0' AS "PaymentPlanAutoName",
	'0' AS "IsPaymentChosenDay",
	


	
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
NULL AS "PaymentType",


    
	
NULL                      AS  "BankAccountIban",
NULL			AS "BankAccountBic",
NULL                        AS "BankAccountMandatoryId",
CASE pa.REQUESTS_SENT WHEN '0' THEN 'true' ELSE 'false' END AS "BankAccountFirstPayment",
TO_CHAR(longtodate(pa.CREATION_TIME), 'YYYY-MM-DD') AS "BankAccountMandatorySignUpDate",


	NULL AS "CreditCardNumber",
	NULL AS "CreditCardReferenceNumber",
	NULL AS "CreditCardExpiryDate",
personCreation.txtvalue            AS personCreationDate,	


	personcomment.txtvalue    AS "Comment1",
	Grouponcode.txtvalue 	AS "Comment2",
	NULL AS  "Cancellation Reason3",
	NULL AS  "Comment4",
	NULL AS "Tags",

---agreement fields---
	
'0'                                                                                                   AS "Allow Email",
'0'                                                                                                               AS "Allow SMS",
'0'                                                                                             AS "Allow Letter",
'0'                                                                                                             AS "Allow Phone",
'0'                                                                                                          AS "AllowN ewsLetter",
'0'                                                                                                         AS "Allow ThirdPartyOffers",
'0' AS "OptIn",
'0'  AS "Doi",
DOI_Date.txtvalue AS "DoiDate",

---customfields---
salutation.txtvalue                AS "CustomAttribute.Title",
NULL AS "Markting Source",
NULL AS "CustomAttribute.Sales Offer",
NULL AS "CustomAttribute.Guest Type",
aggregator.txtvalue AS "CustomAttribute.Aggregator",
ContractCom.txtvalue AS "CustomAttribute Contract Com",
contdoc.txtvalue AS "CustomAttribute.Documentation",
NULL AS "CustomAttribute.Compliant",
priceok.txtvalue AS "CustomAttribute.ContractPrice",
startpackok.txtvalue AS "CustomAttribute.Starter Pack",
locker.txtvalue AS "CustomAttribute.Locker Number",
NUMBERPLATE.txtvalue AS "CustomAttribute.Number Plate",
egid.txtvalue 					AS "Custom.Attribute.Egym ID Exerp",
NULL AS "CustomAttribute.WebShop Voucher",
NULL AS "CustomAttribute.Given Apr May20",
NULL AS "CustomAttribute.Given Nov20",
NULL AS "CustomAttribute.Given Dec20",
NULL AS "CustomAttribute.Given Jan21",
NULL AS "CustomAttribute.Given Feb21",
NULL AS "CustomAttribute.Given Mar21",
NULL AS "CustomAttribute.Given Apr21",
NULL AS "CustomAttribute.Given May21",
--comp.lastname blank for deleted--
NULL AS "CustomAttribute.Company",
offer.txtvalue AS "CustomAttribute.Promotion",


CASE p.blacklisted 
WHEN '1' THEN 'Blacklisted' 
WHEN '2' THEN 'Suspended' 
ELSE 'NO' 						END AS "Blocked",


--additional information--

NULL AS "PaymentType",
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

  
pa.CLEARINGHOUSE_REF     	      AS CC_contractid,

----for conversion fields---
CASE
	WHEN subt.st_type = 0 THEN latest_sub.end_date       
	WHEN subt.st_type = 1 THEN latest_sub.binding_end_date
	END AS "MinCancelTimeMonths",
CASE
        WHEN quest.number_answer IS NOT NULL AND q.id IS NOT NULL
         THEN CAST ((xpath('//question[id/text()='|| 2 ||']/options/option[id/text()='|| quest.number_answer ||']/optionText/text()',xmlparse(document convert_from(q.QUESTIONS, 'UTF-8'))))[1] AS VARCHAR(255))
        ELSE NULL
    END               AS "Cancellation Reason",
source.txtvalue AS "Source",
offer.txtvalue AS "Offer",
guest.txtvalue AS "GuestType",
contok.txtvalue AS "ContractCompliant",
corcomp.txtvalue AS "WebShop Voucher",   
corgiven1.txtvalue AS "Corona.Given Apr May20",  
corgiven2.txtvalue AS "Corona.Given Nov20",
corgiven3.txtvalue AS "Corona.Given Dec20",
corgiven4.txtvalue AS "Corona.Given Jan21",
corgiven5.txtvalue AS "Corona.Given Feb21",
corgiven6.txtvalue AS "Corona.Given Mar21",
corgiven7.txtvalue AS "Corona.Given Apr21",
corgiven8.txtvalue AS "Corona.Given May21",

NULL  AS "PaymentPlanConvert",
NULL AS "MembershipGlId",
NULL AS "PPName and Global ID",


NULL AS "SponsoredOK",
NULL AS "Autorenew",

---sponsored---

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

CASE
        WHEN pt_rel_p.center IS NOT NULL
        THEN pt_rel_p.center || 'p' || pt_rel_p.id
        ELSE NULL
    END               					AS "FriendFamilyId",

    	
    


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

NULL AS  "SubsState",

     
 CASE  p.PERSONTYPE  WHEN 0 THEN 'PRIVATE'  WHEN 1 THEN 'STUDENT'  WHEN 2 THEN 'STAFF'  WHEN 3 THEN 'FRIEND'  WHEN 4 THEN 'CORPORATE'  WHEN 5 THEN 'ONEMANCORPORATE'  WHEN 6 THEN  'FAMILY'  WHEN 7 THEN 'SENIOR'  WHEN 8 THEN 'GUEST' ELSE 'UNKNOWN' END AS PersonType,
    
       
    
    
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
	CASE
        WHEN has_RCC_sub.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_RCC_SUB,

    CASE
        WHEN has_clipcard.OWNER_CENTER IS NOT NULL
        THEN 'YES'
        ELSE 'NO'
    END AS HAS_CLIP_CARD,

---tags need to list separated by coma---

bs.txtvalue AS "AmountHC",
tow.txtvalue AS "AmountTow",
loyalty.txtvalue AS "Loy",
priceinc.txtvalue AS "PriceIncr",
priceinc3.txtvalue AS "PriceIncr3%",
osd.TXTVALUE   AS "SignUpDate"



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
    PERSON_EXT_ATTRS channelEmail
ON
    p.center=channelEmail.PERSONCENTER
    AND p.id=channelEmail.PERSONID
    AND channelEmail.name='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    p.center=channelLetter.PERSONCENTER
    AND p.id=channelLetter.PERSONID
    AND channelLetter.name='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS channelPhone
ON
    p.center=channelPhone.PERSONCENTER
    AND p.id=channelPhone.PERSONID
    AND channelPhone.name='_eClub_AllowedChannelPhone'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    p.center=channelSMS.PERSONCENTER
    AND p.id=channelSMS.PERSONID
    AND channelSMS.name='_eClub_AllowedChannelSMS'
LEFT JOIN
    PERSON_EXT_ATTRS emailNewsLetter
ON
    p.center=emailNewsLetter.PERSONCENTER
    AND p.id=emailNewsLetter.PERSONID
    AND emailNewsLetter.name='_eClub_IsAcceptingEmailNewsLetters'
LEFT JOIN
    PERSON_EXT_ATTRS thirdPartyOffers
ON
    p.center=thirdPartyOffers.PERSONCENTER
    AND p.id=thirdPartyOffers.PERSONID
    AND thirdPartyOffers.name='_eClub_IsAcceptingThirdPartyOffers'

LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    p.center = osd.PERSONCENTER
    AND p.id = osd.PERSONID
	AND osd.name = 'OriginalStartDate'

LEFT JOIN			
       PERSON_EXT_ATTRS egid			
ON			
        p.center = egid.PERSONCENTER			
        AND p.id = egid.PERSONID 			
        AND egid.name = 'EGYMID'	
LEFT JOIN
     PERSON_EXT_ATTRS aggregator
 ON
     p.center=aggregator.PERSONCENTER
     AND p.id=aggregator.PERSONID
     AND aggregator.name = 'AGGREGATOR'

LEFT JOIN
     PERSON_EXT_ATTRS OPTIN
 ON
     p.center=OPTIN.PERSONCENTER
     AND p.id=OPTIN.PERSONID
     AND OPTIN.name='GDPROPTIN'
 


LEFT JOIN
     PERSON_EXT_ATTRS OPTIN_Date
 ON
     p.center=OPTIN_Date.PERSONCENTER
     AND p.id=OPTIN_Date.PERSONID
     AND OPTIN_Date.name='GDPROPTINDATE'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI
 ON
     p.center=DOI.PERSONCENTER
     AND p.id=DOI.PERSONID
     AND DOI.name='GDPRDOUBLEOPTIN'
 LEFT JOIN
     PERSON_EXT_ATTRS DOI_Date
 ON
     p.center=DOI_Date.PERSONCENTER
     AND p.id=DOI_Date.PERSONID
     AND DOI_Date.name='GDPRDOUBLEOPTINdate'

--- notes--
LEFT JOIN
     PERSON_EXT_ATTRS ContractCom
 ON
     p.center=ContractCom.PERSONCENTER
     AND p.id=ContractCom.PERSONID
     AND ContractCom.name='ContractCom'
LEFT JOIN
     PERSON_EXT_ATTRS Grouponcode
 ON
     p.center=Grouponcode.PERSONCENTER
     AND p.id=Grouponcode.PERSONID
     AND Grouponcode.name='Grouponcode'
LEFT JOIN
     PERSON_EXT_ATTRS NUMBERPLATE
 ON
     p.center=NUMBERPLATE.PERSONCENTER
     AND p.id=NUMBERPLATE.PERSONID
     AND NUMBERPLATE.name='NUMBERPLATE'


---fields---

LEFT JOIN
     PERSON_EXT_ATTRS source
 ON
     p.center=source.PERSONCENTER
     AND p.id=source.PERSONID
     AND source.name='SOURCES_DE'
LEFT JOIN
     PERSON_EXT_ATTRS contdoc
 ON
     p.center=contdoc.PERSONCENTER
     AND p.id=contdoc.PERSONID
     AND contdoc.name='ContractDocumentation'
LEFT JOIN
     PERSON_EXT_ATTRS contok
 ON
     p.center=contok.PERSONCENTER
     AND p.id=contok.PERSONID
     AND contok.name='ContractOK'
LEFT JOIN
     PERSON_EXT_ATTRS priceok
 ON
     p.center=priceok.PERSONCENTER
     AND p.id=priceok.PERSONID
     AND priceok.name='MembershipFee'
LEFT JOIN
     PERSON_EXT_ATTRS startpackok
 ON
     p.center=startpackok.PERSONCENTER
     AND p.id=startpackok.PERSONID
     AND startpackok.name='StarterPack'
LEFT JOIN
     PERSON_EXT_ATTRS offer
 ON
     p.center=offer.PERSONCENTER
     AND p.id=offer.PERSONID
     AND offer.name='SalesOffer'
LEFT JOIN
     PERSON_EXT_ATTRS locker
 ON
     p.center=locker.PERSONCENTER
     AND p.id=locker.PERSONID
     AND locker.name='LOCKER_NUMBER'
LEFT JOIN
     PERSON_EXT_ATTRS hesitation
 ON
     p.center=hesitation.PERSONCENTER
     AND p.id=hesitation.PERSONID
     AND hesitation.name='HESITATIONS'
LEFT JOIN
     PERSON_EXT_ATTRS goal
 ON
     p.center=goal.PERSONCENTER
     AND p.id=goal.PERSONID
     AND goal.name='Live Well Goal'
LEFT JOIN
     PERSON_EXT_ATTRS prefactivity
 ON
     p.center=prefactivity.PERSONCENTER
     AND p.id=prefactivity.PERSONID
     AND prefactivity.name='PREFERENCE_ACTIVITY'

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
     PERSON_EXT_ATTRS loyreg
 ON
     p.center=loyreg.PERSONCENTER
     AND p.id=loyreg.PERSONID
     AND loyreg.name='LOYALTYDEREG'
LEFT JOIN
     PERSON_EXT_ATTRS loyalty
 ON
     p.center=loyalty.PERSONCENTER
     AND p.id=loyalty.PERSONID
     AND loyalty.name='LOYALTYDE'
LEFT JOIN
     PERSON_EXT_ATTRS loyadd
 ON
     p.center=loyadd.PERSONCENTER
     AND p.id=loyadd.PERSONID
     AND loyadd.name='LOYALTYDEADDON'
LEFT JOIN
     PERSON_EXT_ATTRS guest
 ON
     p.center=guest.PERSONCENTER
     AND p.id=guest.PERSONID
     AND guest.name='GUESTTYPE'
LEFT JOIN
     PERSON_EXT_ATTRS priceinc
 ON
     p.center=priceinc.PERSONCENTER
     AND p.id=priceinc.PERSONID
     AND priceinc.name='PRICEINCREASE'
LEFT JOIN
     PERSON_EXT_ATTRS priceinc3
 ON
     p.center=priceinc3.PERSONCENTER
     AND p.id=priceinc3.PERSONID
     AND priceinc3.name='PRICEINCREASEMAX3'
LEFT JOIN
     PERSON_EXT_ATTRS corcomp
 ON
     p.center=corcomp.PERSONCENTER
     AND p.id=corcomp.PERSONID
     AND corcomp.name='CORONACOMP'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven1
 ON
     p.center=corgiven1.PERSONCENTER
     AND p.id=corgiven1.PERSONID
     AND corgiven1.name='COMPENSATIONGIVEN'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven2
 ON
     p.center=corgiven2.PERSONCENTER
     AND p.id=corgiven2.PERSONID
     AND corgiven2.name='COMPENSATIONGIVEN2'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven3
 ON
     p.center=corgiven3.PERSONCENTER
     AND p.id=corgiven3.PERSONID
     AND corgiven3.name='COMPENSATIONGIVEN3'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven4
 ON
     p.center=corgiven4.PERSONCENTER
     AND p.id=corgiven4.PERSONID
     AND corgiven4.name='COMPENSATIONGIVEN4'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven5
 ON
     p.center=corgiven5.PERSONCENTER
     AND p.id=corgiven5.PERSONID
     AND corgiven5.name='COMPENSATIONGIVEN5'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven6
 ON
     p.center=corgiven6.PERSONCENTER
     AND p.id=corgiven6.PERSONID
     AND corgiven6.name='COMPENSATIONGIVEN6'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven7
 ON
     p.center=corgiven7.PERSONCENTER
     AND p.id=corgiven7.PERSONID
     AND corgiven7.name='COMPENSATIONGIVEN7'
LEFT JOIN
     PERSON_EXT_ATTRS corgiven8
 ON
     p.center=corgiven8.PERSONCENTER
     AND p.id=corgiven8.PERSONID
     AND corgiven8.name='COMPENSATIONGIVEN8'








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
PERSON_EXT_ATTRS photo
 ON
     p.center=photo.PERSONCENTER
     AND p.id=photo.PERSONID
     AND photo.name IN ('_eClub_Picture','_eClub_PictureFace')



LEFT JOIN
    ACCOUNT_RECEIVABLES payment_ar
ON
    payment_ar.CUSTOMERCENTER = p.center
    AND payment_ar.CUSTOMERID = p.id
    AND payment_ar.AR_TYPE = 4
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_ar
ON
    cash_ar.CUSTOMERCENTER=p.center
    AND cash_ar.CUSTOMERID=p.id
    AND cash_ar.AR_TYPE = 1
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


LEFT JOIN
    RELATIVES op_rel
ON
    op_rel.relativecenter=p.center
    AND op_rel.relativeid=p.id
    AND op_rel.RTYPE = 12
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
    -- other payer



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
			pr.globalid,
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
                AND ppg.PRODUCT_GROUP_ID IN (2802)) ) latest_sub


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



  -- has eft sub
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
    -- has cash sub
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
            st.ST_TYPE = 2
            AND sub.STATE IN (2,4,8) ) has_RCC_sub
ON
    has_RCC_sub.owner_center = p.center
    AND has_RCC_sub.owner_id = p.id



    --- clipcards---
LEFT JOIN
    (
        SELECT DISTINCT
            clips.OWNER_CENTER,
            clips.OWNER_ID
        FROM
            clipcards clips
        JOIN
            products pd
        ON
            pd.center = clips.center
            AND pd.id = clips.id
        WHERE
            clips.CLIPS_LEFT > 0
            AND clips.FINISHED = 0
            AND clips.CANCELLED = 0
            AND clips.BLOCKED = 0 ) has_clipcard
ON
    has_clipcard.owner_center = p.center
    AND has_clipcard.owner_id = p.id

LEFT JOIN
    RELATIVES pt_rel
ON
    pt_rel.CENTER = p.center
    AND pt_rel.id = p.id
    AND pt_rel.STATUS < 3
    AND ( (
            p.PERSONTYPE = 3
            AND pt_rel.RTYPE = 1 )
        OR (
            p.PERSONTYPE = 6
            AND pt_rel.RTYPE = 4 ) )
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

---reason for leaving---
LEFT JOIN
    (
        SELECT
            qaa.center,
            qaa.id,
            qa1.text_answer,
            qa2.number_answer,
            qc.questionnaire
        FROM
            questionnaire_answer qaa
        JOIN
            questionnaire_campaigns qc
        ON
            qc.id = qaa.questionnaire_campaign_id
        LEFT JOIN
            QUESTION_ANSWER qa1
        ON
            qa1.ANSWER_CENTER =qaa.CENTER
            AND qa1.ANSWER_ID=qaa.ID
            AND qa1.answer_subid = qaa.subid
            AND qa1.QUESTION_ID = 1
        LEFT JOIN
            QUESTION_ANSWER qa2
        ON
            qa2.ANSWER_CENTER =qaa.CENTER
            AND qa2.ANSWER_ID=qaa.ID
            AND qa2.answer_subid = qaa.subid
            AND qa2.QUESTION_ID = 2
        WHERE
            NOT EXISTS
            (
                SELECT
                    1
                FROM
                    questionnaire_answer qaa2
                WHERE
                    qaa2.center = qaa.center
                    AND qaa2.id = qaa.id
                    AND qaa2.log_time > qaa.log_time) )quest
ON
    quest.center = p.center
    AND quest.id = p.id
LEFT JOIN
    QUESTIONNAIRES q
ON
    q.id = quest.questionnaire




WHERE
    p.center IN ($$scope$$)
	AND p.persontype NOT IN (2)   --not staff
    AND p.status IN (7,8)   --Deletd Anonymized---
	---AND pay_for.PAYER_CENTER is NULL ---Not Included in members extract
	AND  subs.sub_state NOT IN (8)--not cancelled
       

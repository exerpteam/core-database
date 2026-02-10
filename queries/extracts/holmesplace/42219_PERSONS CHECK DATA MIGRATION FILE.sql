-- The extract is extracted from Exerp on 2026-02-08
-- with last subs in same order as migration file
WITH
     Member AS
     (
         SELECT DISTINCT
             p.*,
             c.name AS centerName,
             c.id   AS centerId
         FROM
             PERSONS p
         JOIN
             CENTERS c
         ON
             c.id = p.CENTER
         WHERE
             p.STATUS IN (1,2,3)--only active inactive temp inactive
--dont choose status
			---p.status IN (person_status)
			 AND p.persontype NOT IN (2)
             AND c.COUNTRY IN ('DE')
			AND p.CENTER IN (:Scope)
     )
     
 SELECT DISTINCT
	CASE latest_sub.state
		WHEN 2 THEN 'active'
		WHEN 4 THEN 'frozen'
		WHEN 8 THEN 'created'
		WHEN 3 THEN 'ended'
		WHEN 7 THEN 'window'
		ELSE 'None'
END AS "state",
	CASE latest_sub.sub_state
		WHEN 1 THEN 'None'
		WHEN 2 THEN 'AwaitingActivation'
		WHEN 3 THEN 'Upgrade'
		WHEN 4 THEN 'Downgrade'
		WHEN 5 THEN 'Extended'
		WHEN 6 THEN 'Transferred'
		WHEN 7 THEN 'Regrett'
		WHEN 8 THEN 'Cancelled'
		WHEN 9 THEN 'Blocked'
		WHEN 10 THEN 'Changed'
END AS "substate",
	p.EXTERNAL_ID,
	latest_sub.center || 'ss' || latest_sub.id  AS "LastSubsID",
	p.FIRSTNAME,
    p.LASTNAME,
	p.SEX,
	p.BIRTHDATE, 
	email.TXTVALUE      AS email,
	p.center||'p'||p.id AS MemberID,
	home.TXTVALUE   AS "HomePhone",
	mobile.TXTVALUE AS "MobiPhone",
	work.TXTVALUE AS "WorkPhone",
	
    
	CASE WHEN
   (p.CENTER, p.ID) NOT IN
(
        SELECT
                pea.PERSONCENTER,
                pea.PERSONID
        FROM PERSON_EXT_ATTRS pea
        WHERE
				pea.PERSONCENTER IN (:Scope)
				AND pea.NAME IN ('_eClub_Picture','_eClub_PictureFace')
                AND pea.mimevalue IS NOT NULL
)

   THEN 'NoPhoto'
   ELSE 'Photo'
END AS Photo,
	comp.FULLNAME AS "Company",
	p.ADDRESS1,
    p.ZIPCODE,
    p.CITY,
    p.COUNTRY,
	NULL "PGM usernumber",
  	p.centerId          AS "Center ID",
	NULL "MemberCard",
	staff.TXTVALUE                                                                                                                                                                  	AS "Sales Staff",
 	staff2.fullname                                                                                                                                                                 	AS "Sales Name",
	NULL "IsActive",
	NULL "IsGuest",
	ar.BALANCE   AS "TodayBalance",
	NULL "PrepaidBalance",
	
TO_CHAR(longtodate(latest_sub.creation_time), 'DD-MM-YYYY') AS "SubsCreateDate",	
	latest_sub.start_date AS "StartDate",
	latest_sub.end_date AS "EndDate",
	latest_sub.binding_end_date AS "Binding",
	NULL "MinCancelTimeMonths",
	'No' AS "IsProrata",
	'0'  AS "IsEndProrata",
	'1' "ProrataDay",
	latest_sub.name AS "LastMembership",
	NULL "PaymentPlan",
	NULL "PaymentPlanType",
	CASE p.persontype
        WHEN 0 THEN 'PRIVATE'
        WHEN 1 THEN 'STUDENT'
        WHEN 2 THEN 'STAFF'
        WHEN 3 THEN 'FRIEND'
        WHEN 4 THEN 'CORPORATE'
        WHEN 5 THEN 'ONEMANCORPORATE'
        WHEN 6 THEN 'FAMILY'
        WHEN 7 THEN 'SENIOR'
        WHEN 8 THEN 'GUEST'
        WHEN 9 THEN 'CHILD'
        WHEN 10 THEN 'EXTERNAL_STAFF'
        ELSE 'UNKNOWN'
    END AS "PERSONTYPE",
	NULL "VisitLimit",
	NULL "RemainingVisitCount",
	NULL "VisitPeriod",
	NULL "SynchronizeWithContract",

CASE latest_sub.periodunit 
WHEN 0 THEN 'WEEK'
WHEN 1 THEN 'DAY'
WHEN 2 THEN 'MONTH'
ELSE 'UNKNOWN'
END AS "TimePeriod",
latest_sub.bindingperiodcount AS "ContractLength",
latest_sub.periodcount AS "ContractFrequency",
'0'  AS "IsUpfront",
NULL "VatRate",
latest_sub.adminfeeproduct_id AS "AdminFeeId",
NULL "AdminFeeVatRate",
latest_sub.subscription_price AS "MembershipFee",
NULL "PaymentType", --need active payment agreement in use

latest_sub.billed_until_date AS "Billeduntil",
'No'  AS "StartGeneratingTransactionsFromDate",
'Yes' AS "ForcePaymentPlan",
NULL "PaymentPlanAutoName",
NULL "IsPaymentChosenDay",
latest_sub.auto_stop_on_binding_end_date AS "IsAutoEnded",
NULL "IsAdditionalContract",
'0'  AS "StopChargingAfterMinPeriod",
'1'  AS "FreezeAvailable",
NULL "AutomaticRenew",
payer.center||'p'||payer.id AS "Payerid added",
payer.fullname as "PayerName",
NULL "AccountNumber",
NULL "BankAccountBic",
NULL "BankAccountMandatoryId",
NULL "BankAccountFirstPayment",
NULL "BankAccountMandatorySignUpDate",
NULL "CreditCardReferenceNumber",
NULL "CreditCardExpityDate",
com.TXTVALUE AS "Comment1",
p.blacklisted AS "Comment2BlackList",
     
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
    END AS "Comment3STATUS",

 cd.TXTVALUE AS "Comment4createddate",
p.centerName        AS "Center",
     
	aggregator.TXTVALUE
AS "Aggregator Name",	
   allow_Email.TXTVALUE                                                                                                                                                    AS allow_Email,
   allow_SMS.TXTVALUE                                                                                                                                                         AS allow_SMS,
   allow_Phone_Call.TXTVALUE                                                                                                                                                       AS allow_Phone_Call,
   allow_Letter.TXTVALUE                                                                                                                                                     AS allow_Letter,
   OPTIN.TXTVALUE                                                                                                                                                              AS "OPTIN",
   OPTIN_Date.TXTVALUE                                                                                                                                                          AS "OPTIN_Date",
   DOI.TXTVALUE                                                                                                                                                        AS "DOI",
   DOI_Date.TXTVALUE                                                                                                                                                    AS "DOI_Date",



p.last_active_start_date AS "Last Start Date",
osd.TXTVALUE AS "Orignal Start Date",
ca.name AS "CompAgreement",
ca.blocked AS "CAblocked",
ar.ar_type AS "ARtype"



 FROM
     Member p
LEFT JOIN
     PERSON_EXT_ATTRS aggregator
 ON
     p.center=aggregator.PERSONCENTER
     AND p.id=aggregator.PERSONID
     AND aggregator.name='AGGREGATOR'

LEFT JOIN
     PERSON_EXT_ATTRS keepmeid
 ON
     p.center=keepmeid.PERSONCENTER
     AND p.id=keepmeid.PERSONID
     AND keepmeid.name='KEEPMEID'
 LEFT JOIN
     PERSON_EXT_ATTRS email
 ON
     p.center=email.PERSONCENTER
     AND p.id=email.PERSONID
     AND email.name='_eClub_Email'
 LEFT JOIN
     PERSON_EXT_ATTRS mobile
 ON
     p.center=mobile.PERSONCENTER
     AND p.id=mobile.PERSONID
     AND mobile.name='_eClub_PhoneSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS home
 ON
     p.center=home.PERSONCENTER
     AND p.id=home.PERSONID
     AND home.name='_eClub_PhoneHome'
LEFT JOIN
     PERSON_EXT_ATTRS work
 ON
     p.center=work.PERSONCENTER
     AND p.id=work.PERSONID
     AND work.name='_eClub_PhoneWork'
LEFT JOIN
PERSON_EXT_ATTRS photo
 ON
     p.center=photo.PERSONCENTER
     AND p.id=photo.PERSONID
     AND photo.name IN ('_eClub_Picture','_eClub_PictureFace')


 LEFT JOIN
     PERSON_EXT_ATTRS staff
 ON
     p.center=staff.PERSONCENTER
     AND p.id=staff.PERSONID
     AND staff.name='Sales_Staff'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_SMS
 ON
     p.center=allow_SMS.PERSONCENTER
     AND p.id=allow_SMS.PERSONID
     AND allow_SMS.name='_eClub_AllowedChannelSMS'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Phone_Call
 ON
     p.center=allow_Phone_Call.PERSONCENTER
     AND p.id=allow_Phone_Call.PERSONID
     AND allow_Phone_Call.name='_eClub_AllowedChannelPhone'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Letter
 ON
     p.center=allow_Letter.PERSONCENTER
     AND p.id=allow_Letter.PERSONID
     AND allow_Letter.name='_eClub_AllowedChannelLetter'
 LEFT JOIN
     PERSON_EXT_ATTRS allow_Email
 ON
     p.center=allow_Email.PERSONCENTER
     AND p.id=allow_Email.PERSONID
     AND allow_Email.name='_eClub_AllowedChannelEmail'
 LEFT JOIN
     PERSON_EXT_ATTRS NEWSL
 ON
     p.center = NEWSL.PERSONCENTER
     AND p.id = NEWSL.PERSONID
     AND NEWSL.Name = '_eClub_IsAcceptingEmailNewsLetters'
 
 
 LEFT JOIN
     PERSON_EXT_ATTRS assigned_email
 ON
     p.center=assigned_email.PERSONCENTER
     AND p.id=assigned_email.PERSONID
     AND assigned_email.name='_eClub_Email'
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
     PERSON_EXT_ATTRS sales_email
 ON
     staff2.center=sales_email.PERSONCENTER
     AND staff2.id=sales_email.PERSONID
     AND sales_email.name='_eClub_Email'
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

LEFT JOIN			
                PERSON_EXT_ATTRS cd			
                ON			
                   p.center = cd.PERSONCENTER			
                AND p.id = cd.PERSONID 			
                AND cd.name = 'CREATION_DATE'	
LEFT JOIN
    PERSON_EXT_ATTRS osd
ON
    p.center = osd.PERSONCENTER
    AND p.id = osd.PERSONID
	AND osd.name = 'OriginalStartDate'

LEFT JOIN
    PERSON_EXT_ATTRS com
ON
    p.center = com.PERSONCENTER
    AND p.id = com.PERSONID
	AND com.name = '_eClub_Comment'



LEFT JOIN
    RELATIVES rel
ON
    rel.CENTER = p.CENTER ----Member of the company agreement
    AND rel.ID = p.ID
    AND rel.RTYPE = 3
    AND rel.STATUS = 1
LEFT JOIN
    COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.id = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID

LEFT JOIN
  PERSONS comp
ON
    comp.center = rel.RELATIVECENTER
    AND comp.id = rel.RELATIVEID

LEFT JOIN
    RELATIVES rel2
ON
    rel2.CENTER = p.CENTER ----Payer
    AND rel2.ID = p.ID
    AND rel2.RTYPE = 12
    AND rel2.STATUS = 1
LEFT JOIN
  PERSONS payer
ON
    payer.center = rel2.RELATIVECENTER
    AND payer.id = rel2.RELATIVEID

LEFT JOIN
    PAYMENT_REQUESTS pr
ON
pr.center = p.center
AND
pr.id = p.id
LEFT JOIN
    ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = pr.CENTER
AND ar.ID = pr.ID





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
			stype.periodunit,
			stype.periodcount,
			stype.auto_stop_on_binding_end_date,
			stype.adminfeeproduct_id
        FROM
            SUBSCRIPTIONS subs

		JOIN SUBSCRIPTIONTYPES stype
		on subs.SUBSCRIPTIONTYPE_CENTER =stype.CENTER
		AND subs.SUBSCRIPTIONTYPE_ID =stype.ID

        JOIN
            PRODUCTS pr
        ON
            subs.SUBSCRIPTIONTYPE_CENTER = pr.CENTER
        AND subs.SUBSCRIPTIONTYPE_ID = pr.ID
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


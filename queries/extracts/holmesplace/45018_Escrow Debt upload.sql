SELECT
	
  	p.external_id AS "MemberId",
	NULL AS "User Number",
	NULL AS "ExternalContractId",
	NULL AS "ContractId",
    prs.REF AS "ExternalTransactionId",
	TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') "Date",
    art.UNSETTLED_AMOUNT AS "Amount Gross",
	'19%'  AS "VAT",
	art.TEXT AS "Description",
	NULL AS "TransactionType",
	NULL AS "TransactionCategory",
	NULL AS "PeriodStartDate",
	NULL AS "PeriodEndDate",


	P.CENTER AS "Club",
	 p.CENTER || 'p' || p.ID AS "PersonID",
	p.FIRSTNAME AS "Name",	
    p.LASTNAME AS "LastName",
    p.blacklisted AS "Blocked",
case p.status
        when 0 then 'lead'
        when 1 then 'active'
        when 2 then 'inactive'
        when 3 then 'temp inactive'
        when 4 then 'transferred'
        when 5 then 'duplicate'
        when 6 then 'prospect'
        when 7 then 'blocked'
        when 8 then 'anonymized'
        when 9 then 'contact'
        else 'undefined'
    end as "personStatus",

    
    TO_CHAR(latest_sub.START_DATE, 'DD.MM.YYYY')  AS "LastStartDate",
	TO_CHAR(latest_sub.END_DATE, 'DD.MM.YYYY')  AS "LastStopDate",
	TO_CHAR(latest_sub.BINDING_END_DATE, 'DD.MM.YYYY') AS "LastBindingEnd",
	latest_sub.name AS "LastMembership",	
    latest_sub.center || 'ss' || latest_sub.id     AS "LastSubsID",
	
	    
   pa.CREDITOR_ID "PACreditor",
    
    
TO_CHAR(pr.REQ_DATE, 'DD.MM.YYYY') AS "prReqDate",
    
    prs.REQUESTED_AMOUNT AS "RquestedAmount",
    TO_CHAR(longtodate(art.ENTRY_TIME), 'YYYY-MM-DD')AS "EntryDate",
    art.UNSETTLED_AMOUNT AS "ARUnsettledAmount",
    art.AMOUNT - art.UNSETTLED_AMOUNT AS "ARsettledAmount",
    ar.BALANCE AS "AccountBalance",
	art.TEXT AS "Product",
	NULL AS "In migration",
	NULL AS "Tot debt here",
	NULL AS "User Number",
	NULL AS "Transaction Type",
	NULL AS "FOR TYPE Right",
    NULL AS "FOR TYPE Left"


FROM
    HP.PAYMENT_REQUEST_SPECIFICATIONS prs
JOIN
    HP.AR_TRANS art
ON
    art.PAYREQ_SPEC_CENTER = prs.CENTER
    AND art.PAYREQ_SPEC_ID = prs.ID
    AND art.PAYREQ_SPEC_SUBID = prs.SUBID

JOIN
    HP.ACCOUNT_RECEIVABLES ar
ON
    ar.CENTER = art.CENTER
    AND ar.ID = art.ID
JOIN
    HP.PERSONS p
ON
    p.CENTER = ar.CUSTOMERCENTER
    AND p.ID = ar.CUSTOMERID

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
			subs.binding_end_date
        FROM
            SUBSCRIPTIONS subs
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
                AND ppg.PRODUCT_GROUP_ID = 1605) ) latest_sub
ON
    latest_sub.owner_center = p.center
AND latest_sub.owner_id = p.id
AND latest_sub.lastone = 1



LEFT JOIN
    HP.PAYMENT_REQUESTS pr
ON
    pr.INV_COLL_CENTER = prs.CENTER
    AND pr.INV_COLL_ID = prs.ID
    AND pr.INV_COLL_SUBID = prs.SUBID
LEFT JOIN
    HP.PAYMENT_AGREEMENTS pa
ON
    pa.center = pr.CENTER
    AND pa.id = pr.ID
    AND pa.SUBID = pr.AGR_SUBID
LEFT JOIN
    HP.PERSON_EXT_ATTRS home_phone
ON
    home_phone.PERSONCENTER=p.center
    AND home_phone.PERSONID=p.id
    AND home_phone.name='_eClub_PhoneHome'
LEFT JOIN
    HP.PERSON_EXT_ATTRS work_phone
ON
    work_phone.PERSONCENTER=p.center
    AND work_phone.PERSONID=p.id
    AND work_phone.name='_eClub_PhoneWork'
LEFT JOIN
    HP.PERSON_EXT_ATTRS mobile_phone
ON
    mobile_phone.PERSONCENTER=p.center
    AND mobile_phone.PERSONID=p.id
    AND mobile_phone.name='_eClub_PhoneSMS'
LEFT JOIN
    HP.PERSON_EXT_ATTRS email
ON
    email.PERSONCENTER=p.center
    AND email.PERSONID=p.id
    AND email.name='_eClub_Email'
  
  

    
WHERE
    prs.CENTER in (:Center)
    AND art.UNSETTLED_AMOUNT <> 0
    AND art.AMOUNT < 0
    --    AND prs.DUE_DATE >= '2013-01-01'
    --    AND prs.DUE_DATE <= '2013-01-31'
	AND pr.REQUEST_TYPE = 1    
	AND prs.ORIGINAL_DUE_DATE >= :FromDueDate
    AND prs.ORIGINAL_DUE_DATE <= :ToDueDate
    AND art.REF_TYPE = 'INVOICE'
	AND p.status IN (1,3,0,2,6,9)
	

   
    
ORDER BY
    p.external_id,
    prs.ENTRY_TIME
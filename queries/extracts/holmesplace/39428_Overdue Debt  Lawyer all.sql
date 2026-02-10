-- The extract is extracted from Exerp on 2026-02-08
-- With subscription information.  Some debts are are duplicated if they have more than one subscritpion.
Keep the one with latest binding end date?
SELECT
    p.CENTER || 'p' || p.ID AS kd_nr,
    NULL vkz,
    NULL ars,
    p.LASTNAME "name",
    p.FIRSTNAME vorname,
    CASE
        WHEN p.ADDRESS2 IS NOT NULL
        THEN p.ADDRESS1 || ', ' || p.ADDRESS2
        ELSE p.ADDRESS1
    END strasse,
    p.ZIPCODE plz,
    p.CITY ort,
p.blacklisted,
    NULL kat_nr,
    art.TEXT re_bez,
    prs.REF re_nr,
    TO_CHAR(pr.REQ_DATE, 'DD.MM.YYYY') re_dat_v,
    NULL re_dat_b,
    art.UNSETTLED_AMOUNT hf_betrag,
    NULL zi_satz,
    NULL zi_ab,
    NULL ma_ko,
    NULL inkasso_ko,
    NULL ema_ko,
    NULL bank_ko,
    NULL ko_dat,
    NULL za_betrag,
    NULL za_dat,
    NULL Geburtsname,
    TO_CHAR(p.BIRTHDATE, 'DD.MM.YYYY') geburtsdatum,
    CASE
        WHEN home_phone.TXTVALUE IS NOT NULL
        THEN home_phone.TXTVALUE
        ELSE mobile_phone.TXTVALUE
    END telefon,
    email.TXTVALUE e_mail,
    pa.BANK_NAME geldinstitut,
    NULL bankort,
    pa.BANK_REGNO blz,
    pa.BANK_ACCNO kontonummer,
    pa.IBAN,
    pa.BIC,
    NULL AuslKz,
	TO_CHAR(subs.START_DATE, 'DD.MM.YYYY')  StartDate,
	TO_CHAR(subs.END_DATE, 'DD.MM.YYYY')  StopDate,
	TO_CHAR(subs.BINDING_END_DATE, 'DD.MM.YYYY') BindingEnd,
	prod.name Membership,
	
    
    NULL BEMERKUNGEN,
    pa.CREDITOR_ID int_creditor,
    
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
    end as int_person_status,
    TO_CHAR(prs.ORIGINAL_DUE_DATE, 'YYYY-MM-DD') int_dd_due_date,
    prs.REQUESTED_AMOUNT int_dd_Amount,
    TO_CHAR(longtodate(art.ENTRY_TIME), 'YYYY-MM-DD') int_line_entry,
    art.UNSETTLED_AMOUNT int_line_unsettled,
    art.AMOUNT - art.UNSETTLED_AMOUNT int_line_settled,
    ar.BALANCE int_account_balance,
    debtCall1.TXTVALUE debtCall1,
    debtCall2.TXTVALUE debtCall2,
    debtCall3.TXTVALUE debtCall3,
    debtComment.TXTVALUE debtComment,
subs.center || 'ss' || subs.id            AS "SubsID"

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
	SUBSCRIPTIONS subs
ON
	subs.owner_center = p.CENTER 
	AND subs.OWNER_ID = p.id
	---AND subs.state IN (2,4,8)--active frozen created
   --- AND subs.sub_state NOT IN (8)--not cancelled
	
LEFT JOIN
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
  
  
LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall1
ON
    debtCall1.PERSONCENTER=p.center
    AND debtCall1.PERSONID=p.id
    AND debtCall1.name='COMM_1.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall2
ON
    debtCall2.PERSONCENTER=p.center
    AND debtCall2.PERSONID=p.id
    AND debtCall2.name='COMM_2.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtCall3
ON
    debtCall3.PERSONCENTER=p.center
    AND debtCall3.PERSONID=p.id
    AND debtCall3.name='COMM_3.DEBT CALL'
    
    LEFT JOIN
    HP.PERSON_EXT_ATTRS debtComment
ON
    debtComment.PERSONCENTER=p.center
    AND debtComment.PERSONID=p.id
    AND debtComment.name='COMM_DEBT Comment'
    
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
	AND (
(p.status IN (1,3)AND subs.state IN (2,4)) OR (p.status IN (0,2,6,9)))
	

    AND NOT EXISTS
            (
                SELECT
                    1
                FROM
                    PRODUCT_AND_PRODUCT_GROUP_LINK ppg
                WHERE
                    ppg.product_center = subt.CENTER
                AND ppg.product_id = subt.ID
                AND ppg.PRODUCT_GROUP_ID IN (2802)) --exclude coaching
           
 -- Exclude add-on memberships
       --- AND subt.IS_ADDON_SUBSCRIPTION = 0

	
	
    
ORDER BY
    p.center,
    p.id,
    prs.ENTRY_TIME
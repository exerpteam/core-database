-- The extract is extracted from Exerp on 2026-02-08
-- Has the latest subscription - if active/temp then the current subscription  if ended then the last active subscription they had. Excludes PTbyDD so if empty it might be because they only ever had PTDD)
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
	TO_CHAR(latest_sub.START_DATE, 'DD.MM.YYYY')  LastStartDate,
	TO_CHAR(latest_sub.END_DATE, 'DD.MM.YYYY')  LastStopDate,
	TO_CHAR(latest_sub.BINDING_END_DATE, 'DD.MM.YYYY') LastBindingEnd,
latest_sub.name LastMembership,	
    latest_sub.center || 'ss' || latest_sub.id     AS "LastSubsID",
	
	    
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
    debtComment.TXTVALUE debtComment


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
	AND p.status IN (1,3,0,2,6,9)
	

   
    
ORDER BY
    p.center,
    p.id,
    prs.ENTRY_TIME
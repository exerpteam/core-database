-- The extract is extracted from Exerp on 2026-02-08
--  
WITH
    plist AS materialized
    (
        SELECT
            center,
            id
        FROM
            persons p
        WHERE
            p.status IN (0,
                         1,
                         2,
                         3,
                         6,
                         9)
        AND p.sex != 'C'
        AND p.center IN (700, 800, 725, 726, 727, 728, 729, 730, 732, 733, 735, 737, 743, 744, 748, 756, 759, 760, 762, 766, 778, 779, 782, 783, 7084, 731, 734, 736, 773, 7035, 7078)
    )
    ,
    comps AS
    (
        SELECT DISTINCT
            comp.*
        FROM
            plist p
        JOIN
            RELATIVES rel_comp
        ON
            p.CENTER = rel_comp.RELATIVECENTER
        AND p.ID = rel_comp.RELATIVEID
        AND rel_comp.RTYPE = 2
        AND rel_comp.STATUS=1
        JOIN
            persons comp
        ON
            comp.center = rel_comp.center
        AND comp.id = rel_comp.id
    )
SELECT DISTINCT
    (c.CENTER || 'p' || c.ID) AS CompanyId,
    c.CENTER                  AS OldCompanyCenter,
    c.ID                      AS OldCompanyId,
    'head_office_center'      AS NewCompanyCenter,
    c.STATUS,
    c.FULLNAME           AS CompanyName,
    com.TXTVALUE         AS CompanyComment,
    c.ADDRESS1           AS AddressLine1,
    c.ADDRESS2           AS AddressLine2,
    c.ADDRESS3           AS AddressLine3,
    c.ZIPCODE            AS ZipCode,
    c.CITY               AS City,
    c.COUNTRY            AS Country,
    c.CO_NAME            AS COName,
    mobilePhone.TXTVALUE AS MobilePhone,
    c.SSN                AS Ssn,
    email.TXTVALUE       AS Email,
    empNum.TXTVALUE      AS TotalNumberEmployee,
    invAdd1.TXTVALUE     AS InvoiceAddress1,
    invAdd2.TXTVALUE     AS InvoiceAddress2,
    invAdd7.TXTVALUE     AS InvoiceZipcode,
    invAdd3.TXTVALUE     AS InvoiceCity,
    invAdd4.TXTVALUE     AS InvoiceCoName,
    invAdd5.TXTVALUE     AS InvoiceCountry,
    invAdd6.TXTVALUE     AS InvoiceEmail,
    billnum.TXTVALUE     AS BillingNumber,
    -- c.PREFER_INVOICE_BY_EMAIL AS PreferInvoiceByEmail,
    /*(CASE
    WHEN channelEmail.TXTVALUE='true' THEN
    '1'
    ELSE
    '0'
    END) AS ChannelEmail,*/
    (
        CASE
            WHEN channelLetter.TXTVALUE='true'
            THEN '1'
            ELSE '0'
        END) AS ChannelLetter,
    /* (CASE
    WHEN channelSMS.TXTVALUE='true' THEN
    '1'
    ELSE
    '0'
    END) AS ChannelSMS,*/
    --cash_account.BALANCE AS CashAccountBalance,
    payment_account.BALANCE AS PaymentAccountBalance,
    CASE
        WHEN contact_rel.RELATIVECENTER IS NOT NULL
        THEN contact_rel.RELATIVECENTER||'p'||contact_rel.RELATIVEID
    END AS ContactPerson,
    CASE
        WHEN manager_rel.RELATIVECENTER IS NOT NULL
        THEN manager_rel.RELATIVECENTER||'p'||manager_rel.RELATIVEID
    END                       AS KeyAccountManager,
    cash_account.debit_max    AS MaxCashDebit,
    payment_account.debit_max AS MaxPaymentDebit
FROM
    comps c
LEFT JOIN
    PERSON_EXT_ATTRS mobilePhone
ON
    c.CENTER=mobilePhone.PERSONCENTER
AND c.ID=mobilePhone.PERSONID
AND mobilePhone.NAME='_eClub_PhoneSMS'
LEFT JOIN
    PERSON_EXT_ATTRS email
ON
    c.CENTER=email.PERSONCENTER
AND c.ID=email.PERSONID
AND email.NAME='_eClub_Email'
LEFT JOIN
    PERSON_EXT_ATTRS com
ON
    c.CENTER=com.PERSONCENTER
AND c.ID=com.PERSONID
AND com.NAME='_eClub_Comment'
LEFT JOIN
    PERSON_EXT_ATTRS empNum
ON
    c.CENTER=empNum.PERSONCENTER
AND c.ID=empNum.PERSONID
AND empNum.NAME='_eClub_TargetNumberOfEmployees'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd1
ON
    c.CENTER=invAdd1.PERSONCENTER
AND c.ID=invAdd1.PERSONID
AND invAdd1.NAME='_eClub_InvoiceAddress1'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd2
ON
    c.CENTER=invAdd2.PERSONCENTER
AND c.ID=invAdd2.PERSONID
AND invAdd2.NAME='_eClub_InvoiceAddress2'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd3
ON
    c.CENTER=invAdd3.PERSONCENTER
AND c.ID=invAdd3.PERSONID
AND invAdd3.NAME='_eClub_InvoiceCity'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd4
ON
    c.CENTER=invAdd4.PERSONCENTER
AND c.ID=invAdd4.PERSONID
AND invAdd4.NAME='_eClub_InvoiceCoName'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd5
ON
    c.CENTER=invAdd5.PERSONCENTER
AND c.ID=invAdd5.PERSONID
AND invAdd5.NAME='_eClub_InvoiceCountry'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd6
ON
    c.CENTER=invAdd6.PERSONCENTER
AND c.ID=invAdd6.PERSONID
AND invAdd6.NAME='_eClub_InvoiceEmail'
LEFT JOIN
    PERSON_EXT_ATTRS invAdd7
ON
    c.CENTER=invAdd7.PERSONCENTER
AND c.ID=invAdd7.PERSONID
AND invAdd7.NAME='_eClub_InvoiceZipCode'
LEFT JOIN
    PERSON_EXT_ATTRS billnum
ON
    c.CENTER=billnum.PERSONCENTER
AND c.ID=billnum.PERSONID
AND billnum.NAME='_eClub_BillingNumber'
LEFT JOIN
    PERSON_EXT_ATTRS channelEmail
ON
    c.CENTER=channelEmail.PERSONCENTER
AND c.ID=channelEmail.PERSONID
AND channelEmail.NAME='_eClub_AllowedChannelEmail'
LEFT JOIN
    PERSON_EXT_ATTRS channelLetter
ON
    c.CENTER=channelLetter.PERSONCENTER
AND c.ID=channelLetter.PERSONID
AND channelLetter.NAME='_eClub_AllowedChannelLetter'
LEFT JOIN
    PERSON_EXT_ATTRS channelSMS
ON
    c.CENTER=channelSMS.PERSONCENTER
AND c.ID=channelSMS.PERSONID
AND channelSMS.NAME='_eClub_AllowedChannelSMS'
LEFT JOIN
    ACCOUNT_RECEIVABLES cash_account
ON
    cash_account.CUSTOMERCENTER=c.CENTER
AND cash_account.CUSTOMERID=c.ID
AND cash_account.AR_TYPE=1
LEFT JOIN
    ACCOUNT_RECEIVABLES payment_account
ON
    payment_account.CUSTOMERCENTER=c.CENTER
AND payment_account.CUSTOMERID=c.ID
AND payment_account.AR_TYPE=4
LEFT JOIN
    RELATIVES contact_rel
ON
    contact_rel.CENTER = c.CENTER
AND contact_rel.ID = c.ID
AND contact_rel.RTYPE = 7
AND contact_rel.STATUS = 1
LEFT JOIN
    RELATIVES manager_rel
ON
    manager_rel.CENTER = c.CENTER
AND manager_rel.ID = c.ID
AND manager_rel.RTYPE = 10
AND manager_rel.STATUS = 1
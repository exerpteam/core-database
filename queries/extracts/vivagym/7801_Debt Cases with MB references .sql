-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    ccc.personcenter || 'p' || ccc.personid AS personkey,
p.firstname, p.lastname,
    c.shortname AS Center,
	ccc.startdate AS Open_case,ext.txtvalue,ext2.txtvalue,ext3.txtvalue,ext4.txtvalue,
    (
        CASE
            WHEN ccc.missingpayment = false 
            THEN 'MISSING_AGREEMENT'
            ELSE 'DEBT_CASE'
        END) Case_type,
    ar.balance,
    pea.txtvalue AS Phone,
    (
        CASE
            WHEN pag.creditor_id in ('FHEPDD', '3981SEPAHQ', '3981SEPA','10069SEPAHQ', '3978SEPA','3979SEPA','3984SEPA','3985SEPA','3991','3994SEPA')
            THEN 'SEPA'
            ELSE 'CC'
        END) Clearing_house,
    (
        CASE p.STATUS
            WHEN 0
            THEN 'LEAD'
            WHEN 1
            THEN 'ACTIVE'
            WHEN 2
            THEN 'INACTIVE'
            WHEN 3
            THEN 'TEMPORARYINACTIVE'
            WHEN 4
            THEN 'TRANSFERRED'
            WHEN 5
            THEN 'DUPLICATE'
            WHEN 6
            THEN 'PROSPECT'
            WHEN 7
            THEN 'DELETED'
            WHEN 8
            THEN 'ANONYMIZED'
            WHEN 9
            THEN 'CONTACT'
            ELSE 'UNKNOWN'
        END) AS "Member Status",
	CASE
		WHEN p.blacklisted = 0 THEN 'NONE'
		WHEN p.blacklisted = 1 THEN 'BLACKLISTED'
		WHEN p.blacklisted = 2 THEN 'SUSPENDED'
		WHEN p.blacklisted = 3 THEN 'BLOCKED'
	END AS Substatus
FROM
    cashcollectioncases ccc
JOIN
    vivagym.account_receivables ar
ON
    ar.customercenter = ccc.personcenter
AND ar.customerid = ccc.personid
AND ar.ar_type = 4
JOIN
    vivagym.persons p
ON
    ar.customercenter = p.center
AND ar.customerid = p.id
JOIN
        vivagym.centers c
        ON p.center = c.id
LEFT JOIN
                    PERSON_EXT_ATTRS ext
                ON
                    ext.PERSONCENTER = p.CENTER
                    AND ext.PERSONID = p.ID
                    AND ext.NAME = 'MBAMT'
LEFT JOIN
                    PERSON_EXT_ATTRS ext2
                ON
                    ext2.PERSONCENTER = p.CENTER
                    AND ext2.PERSONID = p.ID
                    AND ext2.NAME = 'MBENTITY'
LEFT JOIN
                    PERSON_EXT_ATTRS ext3
                ON
                    ext3.PERSONCENTER = p.CENTER
                    AND ext3.PERSONID = p.ID
                    AND ext3.NAME = 'MBREF'
LEFT JOIN
                    PERSON_EXT_ATTRS ext4
                ON
                    ext4.PERSONCENTER = p.CENTER
                    AND ext4.PERSONID = p.ID
                    AND ext4.NAME = '_eClub_Email'

LEFT JOIN
        vivagym.person_ext_attrs pea
        ON p.center = pea.personcenter AND p.id = pea.personid AND pea.name = '_eClub_PhoneSMS'
LEFT JOIN
    vivagym.payment_accounts paa
ON
    ar.center = paa.center
AND ar.id = paa.id
LEFT JOIN
    vivagym.payment_agreements pag
ON
    paa.active_agr_center = pag.center
AND paa.active_agr_id = pag.id
AND paa.active_agr_subid = pag.subid
WHERE
    ccc.closed = False
AND
ccc.personcenter in (:scope)
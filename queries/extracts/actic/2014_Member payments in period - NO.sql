SELECT
    *
FROM
    (
        SELECT
            art.TRANS_TIME as "TRANS_TIME",
            TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') as "PAYMENT_DATE",
            per.center || 'p' || per.id as "MEMBER_ID",
            per.FIRSTNAME as "FIRSTNAME",
            per.LASTNAME as "LASTNAME",
            per.ADDRESS1 as "ADDRESS1",
            per.ADDRESS2 as "ADDRESS2",
            per.ZIPCODE as "ZIPCODE",
            per.CITY as "CITY",
            'Actic' || ' ' || club.SHORTNAME as "CLUBNAME",
            club.ADDRESS1 as "CLUBADD1",
            club.ADDRESS2 as "CLUBADD2",
            club.ZIPCODE as "CLUBZIP",
            club.CITY as "CLUBCITY",
            prs.REF as "REF",
            art.AMOUNT as "AMOUNT",
            'Actic Norge AS' as "ORG_NAME",
            'Lensmannslia 4' as "ORG_ADDRESS",
            '1386 ASKER' as "ORG_ZIP_CITY",
            'Org.nr.: 879 438 462' as "ORG_NR",
            'Telefon: 61 32 47 50' as "ORG_PHONE",
            :contact as "ORG_CONTACT",
            'KONTOUTSKRIFT' as "TITLE",
            '' as "COMENT",
            'Dato' as "COL_DATE",
            'Betalt' as "COL_AMOUNT",
            'Fakturanr' as "COL_REF"
        FROM
            ACCOUNT_TRANS act
        LEFT JOIN AR_TRANS art
        ON
            art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        LEFT JOIN PAYMENT_REQUEST_SPECIFICATIONS prs
        ON
            art.center = prs.center
            AND art.id = prs.id
            AND art.INFO = prs.REF
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
            AND ar.id = art.id
        JOIN PERSONS per
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
        JOIN CENTERS club
        ON
            per.center = club.ID
        WHERE
            act.INFO_TYPE IN (3, 4, 16)
            AND
            (
                ar.CUSTOMERCENTER, ar.CUSTOMERID
            )
            IN (:memberid)
            AND act.TRANS_TIME >= :FromDate
            AND act.TRANS_TIME < :ToDate + 3600 * 1000 * 24
        UNION ALL
        SELECT
            art.TRANS_TIME,
            TO_CHAR(longtodate(art.TRANS_TIME), 'DD.MM.YYYY') payment_Date,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
            per.ADDRESS1,
            per.ADDRESS2,
            per.ZIPCODE,
            per.CITY,
            'Actic' || ' ' || club.SHORTNAME clubname,
            club.ADDRESS1 clubadd1,
            club.ADDRESS2 clubadd2,
            club.ZIPCODE clubzip,
            club.CITY clubcity,
            NULL,
            art.AMOUNT,
            'Actic Norge AS' ORG_NAME,
            'Postboks 73' ORG_ADDRESS,
            '2717 GRUA' ORG_ZIP_CITY,
            'Org.nr.: 879 438 462' ORG_NR,
            'Telefon: 61 32 47 50' ORG_PHONE,
            :contact ORG_CONTACT,
            'KONTOUTSKRIFT' TITLE,
            '' COMENT,
            'Dato' COL_DATE,
            'Betalt' COL_AMOUNT,
            'Fakturanr' COL_REF
        FROM
            AR_TRANS art
        JOIN ACCOUNT_TRANS act
        ON
            art.REF_CENTER = act.center
            AND art.REF_ID = act.id
            AND art.REF_SUBID = act.subid
            AND art.REF_TYPE = 'ACCOUNT_TRANS'
        JOIN ACCOUNTS debitacc
        ON
            debitacc.CENTER = act.DEBIT_ACCOUNTCENTER
            AND debitacc.ID = act.DEBIT_ACCOUNTID
        JOIN ACCOUNT_RECEIVABLES ar
        ON
            ar.center = art.center
            AND ar.id = art.id
        JOIN PERSONS per
        ON
            per.center = ar.CUSTOMERCENTER
            AND per.id = ar.CUSTOMERID
        JOIN CENTERS club
        ON
            per.center = club.ID
        WHERE
            ar.AR_TYPE = 4
            AND
            (
                ar.CUSTOMERCENTER, ar.CUSTOMERID
            )
            IN (:memberid)
            AND art.TRANS_TIME >= :FromDate
            AND art.TRANS_TIME < :ToDate + 3600 * 1000 * 24
            AND art.AMOUNT > 0
            AND
            (
                (
                    SUBSTR(art.text, 1, 7) = 'Payment'
                    AND art.EMPLOYEECENTER = 100
                    AND art.EMPLOYEEID = 1
                )
                OR
                (
                    act.INFO_TYPE = 11
                    AND debitacc.EXTERNAL_ID IN ('1931', '1936', '1937')
                )
            )
    ) t 
ORDER BY
    1 DESC

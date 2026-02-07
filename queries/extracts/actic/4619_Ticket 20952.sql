SELECT
    COUNT(test.clubname) cnt,
    test.clubname,
    test.member_id,
    test.firstname,
    test.lastname,
    test.company,
    test.persontype,
    test.membership,
    test.entry_time,
    test.type,
    test.price,
    test.sponsored
FROM
    (
        SELECT
            club.NAME clubname,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
            company.LASTNAME company,
            DECODE ( per.PERSONTYPE,4,'CORPORATE') AS PERSONTYPE,
            prod.NAME MEMBERSHIP, 
            TO_CHAR(longtodate(art.entry_time), 'YYYY-MM-DD') as entry_time,
           CASE
                WHEN subType.ST_TYPE = 0
                THEN 'Cash'
                WHEN subType.ST_TYPE = 1
                THEN 'EFT'
                ELSE 'Unknown'
            END type,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL
                WHEN subType.ST_TYPE = 1
                THEN sub.SUBSCRIPTION_PRICE
                ELSE -1
            END price,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL_SPONSORED
                ELSE 0
            END sponsored
  
        FROM
             subscriptions sub
        LEFT JOIN SUBSCRIPTION_SALES sales
        ON
            sales.SUBSCRIPTION_CENTER = sub.CENTER
            AND sales.SUBSCRIPTION_ID = sub.ID
        LEFT JOIN SUBSCRIPTIONTYPES subType
        ON
            subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCTS prod
        ON
            subType.CENTER = prod.CENTER
            AND subType.ID = prod.ID
        JOIN persons per
        ON
            sub.OWNER_CENTER = per.CENTER
            AND sub.OWNER_ID = per.ID
        join account_receivables acr
        on
           per.center = acr.customercenter
          and per.id = acr.customerid
        left join ar_trans art
            on
           acr.center = art.center
           and acr.id = art.id
        JOIN CENTERS club
        ON
            per.center = club.ID
        LEFT JOIN relatives r
        ON
            per.id = r.id
            AND per.center = r.center
            and r.status = 1
        LEFT JOIN COMPANYAGREEMENTS agr
        ON
            r.relativecenter = agr.center
            AND r.relativeid = agr.id
            AND r.relativesubid = agr.subid
        LEFT JOIN persons company
        ON
            agr.center = company.center
            AND agr.id = company.id
         WHERE
            r.rtype = 3
        and sub.sub_state <> 8
        and per.PERSONTYPE=4
        and art.ref_subid is not null
        and (REGEXP_SUBSTR(art.info,'[[:digit:]]{3}')) = to_char(per.center)
        and art.collected = 1
        and price <> 0
        and sub.state = 2  --active
        AND sub.center = 102
        and subType.ST_TYPE = 1
  ) 
    test
GROUP BY
    test.clubname,
    test.member_id,
    test.firstname,
    test.lastname,
    test.company,
    test.persontype,
    test.membership,
    test.entry_time,
    test.type,
    test.price,
    test.sponsored

UNION

SELECT
    COUNT(test2.clubname) cnt,
    test2.clubname,
    test2.member_id,
    test2.firstname,
    test2.lastname,
    test2.company,
    test2.persontype,
    test2.membership,
    test2.entry_time,
    test2.type,
    test2.price,
    test2.sponsored
FROM
    (
        SELECT
            club.NAME clubname,
            per.center || 'p' || per.id member_id,
            per.FIRSTNAME,
            per.LASTNAME,
            company.LASTNAME company,
            DECODE ( per.PERSONTYPE,4,'CORPORATE') AS PERSONTYPE,
            prod.NAME MEMBERSHIP, 
                       (select
                        TO_CHAR(longtodate(max(ip.trans_time)), 'YYYY-MM-DD')
                        from
                                   subscriptions sub
                        LEFT JOIN SUBSCRIPTION_SALES sales
                        ON
                                    sales.SUBSCRIPTION_CENTER = sub.CENTER
                                    AND sales.SUBSCRIPTION_ID = sub.ID
                        LEFT JOIN SUBSCRIPTIONTYPES subType
                        ON
                                  subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
                                    AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
                        LEFT JOIN PRODUCTS prod
                        ON
                                    subType.CENTER = prod.CENTER
                                    AND subType.ID = prod.ID
                        JOIN persons per
                        ON
                                    sub.OWNER_CENTER = per.CENTER
                                    AND sub.OWNER_ID = per.ID
                        join account_receivables acr
                        on
                                    per.center = acr.customercenter
                                    and per.id = acr.customerid
                        left join ar_trans art
                        on
                                    acr.center = art.center
                                    and acr.id = art.id
                        JOIN CENTERS club
                        ON
                                    per.center = club.ID
                        LEFT JOIN relatives r
                        ON
                                    per.id = r.id
                                    AND per.center = r.center
                                    and r.status = 1
                        LEFT JOIN COMPANYAGREEMENTS agr
                        ON
                                  r.relativecenter = agr.center
                                    AND r.relativeid = agr.id
                                    AND r.relativesubid = agr.subid
                        LEFT JOIN persons company
                        ON
                                  agr.center = company.center
                                    AND agr.id = company.id

                       left join invoices ip
                        on
                                  per.center =  ip.person_center
                                  and per.id = ip.person_id
                       left join invoicelines il
                        on
                                 ip.center = il.center
                                  and ip.id = il.id
                        WHERE
                                    r.rtype = 3
                                    and sub.sub_state <> 8
                                    and per.PERSONTYPE=4
                                    and art.ref_subid is not null
                                    and (REGEXP_SUBSTR(art.info,'[[:digit:]]{3}')) = to_char(per.center)
                                    and art.collected = 1
                                    and price <> 0
                                    and sub.state = 2  --active
                                    and subType.ST_TYPE = 0
                                    AND sub.center = 102
                       ) as entry_time,
             CASE
                WHEN subType.ST_TYPE = 0
                THEN 'Cash'
                WHEN subType.ST_TYPE = 1
                THEN 'EFT'
                ELSE 'Unknown'
            END type,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL
                WHEN subType.ST_TYPE = 1
                THEN sub.SUBSCRIPTION_PRICE
                ELSE -1
            END price,
            CASE
                WHEN subType.ST_TYPE = 0
                THEN sales.PRICE_INITIAL_SPONSORED
                ELSE 0
            END sponsored
        FROM
             subscriptions sub
        LEFT JOIN SUBSCRIPTION_SALES sales
        ON
            sales.SUBSCRIPTION_CENTER = sub.CENTER
            AND sales.SUBSCRIPTION_ID = sub.ID
        LEFT JOIN SUBSCRIPTIONTYPES subType
        ON
            subType.CENTER = sub.SUBSCRIPTIONTYPE_CENTER
            AND subType.ID = sub.SUBSCRIPTIONTYPE_ID
        LEFT JOIN PRODUCTS prod
        ON
            subType.CENTER = prod.CENTER
            AND subType.ID = prod.ID
        JOIN persons per
        ON
            sub.OWNER_CENTER = per.CENTER
            AND sub.OWNER_ID = per.ID
        join account_receivables acr
        on
           per.center = acr.customercenter
          and per.id = acr.customerid
        left join ar_trans art
            on
           acr.center = art.center
           and acr.id = art.id
        JOIN CENTERS club
        ON
            per.center = club.ID
        LEFT JOIN relatives r
        ON
            per.id = r.id
            AND per.center = r.center
            and r.status = 1
        LEFT JOIN COMPANYAGREEMENTS agr
        ON
            r.relativecenter = agr.center
            AND r.relativeid = agr.id
            AND r.relativesubid = agr.subid
        LEFT JOIN persons company
        ON
            agr.center = company.center
            AND agr.id = company.id
         WHERE
            r.rtype = 3
        and sub.sub_state <> 8
        and per.PERSONTYPE=4
        and art.ref_subid is not null
        and (REGEXP_SUBSTR(art.info,'[[:digit:]]{3}')) = to_char(per.center)
        and art.collected = 1
        and price <> 0
        and sub.state = 2  --active
        AND sub.center = 102
        and subType.ST_TYPE = 0
  )
   test2
GROUP BY
    test2.clubname,
    test2.member_id,
    test2.firstname,
    test2.lastname,
    test2.company,
    test2.persontype,
    test2.membership,
    test2.entry_time,
    test2.type,
    test2.price,
    test2.sponsored


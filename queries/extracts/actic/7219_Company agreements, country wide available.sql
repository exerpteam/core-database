SELECT
    decode(ca.availability,'A2', 'SWEDEN', 'A4', 'Norway') as country,
    ca.availability,
    company.LASTNAME as companyname,
    ca.NAME as agreementname,
    pro.NAME as product,
    pro.PRICE as normal_price,
    CASE
        WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
        THEN pro.PRICE - pp.PRICE_MODIFICATION_AMOUNT
        WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
        THEN pp.PRICE_MODIFICATION_AMOUNT
        WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
        THEN pro.price * (1 - pp.PRICE_MODIFICATION_AMOUNT)
        WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
        THEN 0
        ELSE pro.PRICE
    END AS REBATE_PRICE,
    pp.PRICE_MODIFICATION_NAME as REBATE_TYPE,
    to_char(ca.STOP_NEW_DATE, 'YYYY-MM-DD') as END_DATE,
    count (distinct(ansatte.center||'p'||ansatte.id)) as count_pr_agreement
FROM
     COMPANYAGREEMENTS ca
JOIN PERSONS company
    ON
        company.center = ca.center
    AND company.id = ca.id
    AND company.sex = 'C'
JOIN PRIVILEGE_GRANTS pg
    ON
        pg.GRANTER_CENTER = ca.CENTER
    AND pg.GRANTER_ID = ca.ID
    AND pg.GRANTER_SUBID = ca.SUBID
    AND pg.GRANTER_SERVICE = 'CompanyAgreement'
JOIN PRIVILEGE_SETS ps
ON
    ps.ID = pg.PRIVILEGE_SET
JOIN PRODUCT_PRIVILEGES pp
ON
    pp.PRIVILEGE_SET = ps.ID
    AND pp.REF_TYPE = 'GLOBAL_PRODUCT'
 join relatives rel
    on
        rel.RELATIVECENTER = ca.CENTER
    AND rel.RELATIVEID = ca.ID
    AND rel.RELATIVESUBID = ca.SUBID
    AND rel.RTYPE = 3
 join persons ansatte
    on
        rel.CENTER = ansatte.CENTER
    AND rel.ID = ansatte.ID
    and rel.status = 1
 join subscriptions s
    on
        rel.CENTER = s.OWNER_CENTER
    AND rel.ID = s.owner_id
 join subscriptiontypes st  
    on  s.subscriptiontype_center = st.center 
    and s.subscriptiontype_id = st.id
 join products pro 
    on st.center = pro.center 
    and st.id = pro.id
WHERE
    ca.availability like :country
    and
    (
        (ca.STOP_NEW_DATE IS NULL)
        OR (ca.STOP_NEW_DATE  >
to_date(to_char(exerpsysdate(),'yyyy-mm-dd'),'yyyy-mm-dd') )
    )
    AND ca.state in (1)   /*agreement active*/
    and s.state in (2)   /*subscription active*/
group by
    ca.availability,
    company.LASTNAME,
    ca.NAME,
    pro.NAME,
    pro.PRICE,
    pp.PRICE_MODIFICATION_NAME,
    pro.PRICE - pp.PRICE_MODIFICATION_AMOUNT,
    pp.PRICE_MODIFICATION_NAME,
    pp.PRICE_MODIFICATION_AMOUNT,
    pp.PRICE_MODIFICATION_NAME,
    pro.price * (1 - pp.PRICE_MODIFICATION_AMOUNT),
    pp.PRICE_MODIFICATION_NAME,
    ca.STOP_NEW_DATE
ORDER BY
    company.LASTNAME,
    ca.NAME,
    pro.name,
    pro.price
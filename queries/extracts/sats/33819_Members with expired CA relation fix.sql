SELECT
    p.center||'p'|| p.id,
    s.center||'ss'||s.id,
    sp2.TO_DATE,
    sp2.PRICE,
    sp.FROM_DATE,
    sp.PRICE,
    rel.EXPIREDATE,
    s.SUBSCRIPTION_PRICE,
    ca.NAME,
    ca.center,
    ca.id ,
    DECODE(is_spons.center,NULL,'no','yes')
FROM
    SATS.RELATIVES rel
JOIN
    SATS.PERSONS p
ON
    p.CENTER = rel.CENTER
    AND p.id = rel.ID
LEFT JOIN
    SATS.SUBSCRIPTIONS s
ON
    s.OWNER_CENTER = p.CENTER
    AND s.OWNER_ID = p.id
    AND (
        s.END_DATE > to_date('2015-01-01','yyyy-MM-dd')
        OR s.END_DATE IS NULL)
LEFT JOIN
    SATS.SUBSCRIPTION_PRICE sp
ON
    sp.SUBSCRIPTION_CENTER = s.CENTER
    AND sp.SUBSCRIPTION_ID = s.id
    AND sp.TYPE = 'DOCUMENTATION'
    AND sp.from_date BETWEEN to_date('2015-01-01','yyyy-MM-dd') AND exerpsysdate()
    AND sp.CANCELLED =0
JOIN
    SATS.COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.id = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
    AND ca.DOCUMENTATION_REQUIRED = 0
LEFT JOIN
    SATS.SUBSCRIPTION_PRICE sp2
ON
    sp2.SUBSCRIPTION_CENTER = sp.SUBSCRIPTION_CENTER
    AND sp2.SUBSCRIPTION_ID = sp.SUBSCRIPTION_ID
    AND sp2.TO_DATE= sp.FROM_DATE - 1
    AND sp2.CANCELLED =0
JOIN
    SATS.COMPANYAGREEMENTS ca
ON
    ca.CENTER = rel.RELATIVECENTER
    AND ca.id = rel.RELATIVEID
    AND ca.SUBID = rel.RELATIVESUBID
LEFT JOIN
    (
        SELECT
            s.center,
            s.id
        FROM
            SATS.subscriptions s
        JOIN
            SATS.SUBSCRIPTIONTYPES st
        ON
            s.subscriptiontype_center = st.center
            AND s.subscriptiontype_id = st.id
        JOIN
            SATS.products pr
        ON
            st.center = pr.center
            AND st.id = pr.id
        JOIN --Family relation / Friend 401 681
            SATS.RELATIVES r
        ON
            r.CENTER = s.owner_center
            AND r.id = s.owner_ID
            AND r.RTYPE IN (3)
            AND r.STATUS =1
            AND r.EXPIREDATE =to_date('2087-12-31','yyyy-MM-dd') 
        JOIN
            SATS.COMPANYAGREEMENTS ca
        ON
            ca.CENTER = r.RELATIVECENTER
            AND ca.ID = r.RELATIVEID
            AND ca.SUBID = r.RELATIVESUBID
        JOIN
            SATS.PRIVILEGE_GRANTS pg
        ON
            pg.GRANTER_CENTER = ca.CENTER
            AND pg.GRANTER_ID = ca.ID
            AND pg.GRANTER_SUBID = ca.SUBID
            AND pg.SPONSORSHIP_NAME != 'NONE'
            AND pg.VALID_FROM < exerpro.dateToLong(TO_CHAR(r.EXPIREDATE, 'YYYY-MM-dd HH24:MI'))
            AND (
                pg.VALID_TO >=exerpro.dateToLong(TO_CHAR(r.EXPIREDATE, 'YYYY-MM-dd HH24:MI'))
                OR pg.VALID_TO IS NULL)
        JOIN
            SATS.PRODUCT_PRIVILEGES pp
        ON
            pp.PRIVILEGE_SET = pg.PRIVILEGE_SET
            AND pp.VALID_FROM < exerpro.dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
            AND (
                pp.VALID_TO >= exerpro.dateToLong(TO_CHAR(exerpsysdate()+1, 'YYYY-MM-dd HH24:MI'))
                OR pp.VALID_TO IS NULL)
            AND pp.REF_GLOBALID = pr.GLOBALID
        WHERE
            ca.center BETWEEN 100 AND 299 ) is_spons
ON
    is_spons .center = s.CENTER
    AND is_spons.id = s.id
WHERE
    rel.RELATIVECENTER BETWEEN 100 AND 299
   
    AND rel.RTYPE = 3
    AND rel.EXPIREDATE = to_date('2087-12-31','yyyy-MM-dd') 
    --AND p.STATUS IN (1,3)
/**
* Creator: Exerp
* Purpose: List products and payments for companyagreements.
* Prices and rebates should be displayed as well.
*/
SELECT
    DISTINCT club.ID, club.SHORTNAME,
    company.LASTNAME companyname,
    ca.NAME agreementname,
	ca.AVAILABILITY,
    prod.NAME product,
    prod.PRICE normal_price,
    CASE
        WHEN pp.PRICE_MODIFICATION_NAME = 'FIXED_REBATE'
        THEN prod.PRICE - pp.PRICE_MODIFICATION_AMOUNT
        WHEN pp.PRICE_MODIFICATION_NAME = 'OVERRIDE'
        THEN pp.PRICE_MODIFICATION_AMOUNT
        WHEN pp.PRICE_MODIFICATION_NAME = 'PERCENTAGE_REBATE'
        THEN prod.price * (1 - pp.PRICE_MODIFICATION_AMOUNT)
        WHEN pp.PRICE_MODIFICATION_NAME = 'FREE'
        THEN 0
        ELSE prod.PRICE
    END AS REBATE_PRICE,
    pp.PRICE_MODIFICATION_NAME REBATE_TYPE,
    TO_CHAR(ca.STOP_NEW_DATE, 'YYYY-MM-DD') END_DATE

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
JOIN CENTERS club
ON
    pp.VALID_FOR = 'ASS[C' || club.id || ']' OR pp.VALID_FOR IN (:priv_valid)
JOIN PRODUCTS prod
ON
    prod.GLOBALID = pp.REF_GLOBALID
    and prod.CENTER = club.id

WHERE
    club.id IN (:scope)
    AND
    (
        ca.STOP_NEW_DATE IS NULL
        OR ca.STOP_NEW_DATE > current_timestamp
    )
    AND ca.state IN (:ca_state)
    AND prod.SHOW_IN_SALE = 1
	AND pp.PRICE_MODIFICATION_NAME IN ('FIXED_REBATE','OVERRIDE', 'PERCENTAGE_REBATE', 'FREE')

	
ORDER BY
    club.id,
    company.LASTNAME

-- The extract is extracted from Exerp on 2026-02-08
--  
/**
* Creator: Exerp
* Purpose: List information of accounts for Norway and Sweden.
*/
SELECT
    ma.GLOBALID,
    DECODE(ma.ATYPE, '1', 'Assets', '2', 'Liabilities', '3', 'Sales', '4', 'Expenses') TYPE,
    ma.NAME account_name,
    se.name se_name,
    se.EXTERNAL_ID se_id,
    nor.name no_name,
    nor.EXTERNAL_ID no_id
FROM
    MASTERACCOUNTREGISTER ma
JOIN MASTERACCOUNTREGISTER se
ON
    ma.GLOBALID = se.GLOBALID
    AND se.SCOPE_ID = 2
JOIN MASTERACCOUNTREGISTER nor
ON
    ma.GLOBALID = nor.GLOBALID
    AND nor.SCOPE_ID = 4
WHERE
    ma.SCOPE_TYPE = 'T'
ORDER BY
    ma.ATYPE,
    ma.NAME
-- The extract is extracted from Exerp on 2026-02-08
-- Used to check that the set up accounts is correct for the cash register
/**
* Creator: Exerp
* Purpose: Used to check that the set up accounts is correct for the cash register
*/
SELECT
    c.id,
    c.name,
    a1.ATYPE       AS "ASSET_TYPE",
    a1.NAME        AS "ASSET_NAME",
    a1.EXTERNAL_ID AS "ASSET_EXTERNAL_ID",
    a1.GLOBALID    AS "ASSET_GLOBAL_ID",
    a2.ATYPE       AS "RECONCILIATION_TYPE",
    a2.NAME        AS "RECONCILIATION_NAME",
    a2.EXTERNAL_ID AS "RECONCILIATION_EXTERNAL_ID",
    a2.GLOBALID    AS "RECONCILIATION_GLOBAL_ID",
    a3.ATYPE       AS "ROUNDING_TYPE",
    a3.NAME        AS "ROUNDING_NAME",
    a3.EXTERNAL_ID AS "ROUNDING_EXTERNAL_ID",
    a3.GLOBALID    AS "ROUNDING_GLOBAL_ID",
    a4.ATYPE       AS "ERROR_TYPE",
    a4.NAME        AS "ERROR_NAME",
    a4.EXTERNAL_ID AS "ERROR_EXTERNAL_ID",
    a4.GLOBALID    AS "ERROR_GLOBAL_ID",
    a5.ATYPE       AS "PAYOUT_TYPE",
    a5.NAME        AS "PAYOUT_NAME",
    a5.EXTERNAL_ID AS "PAYOUT_EXTERNAL_ID",
    a5.GLOBALID    AS "PAYOUT_GLOBAL_ID",
    a6.ATYPE       AS "BANK_TYPE",
    a6.NAME        AS "BANK_NAME",
    a6.EXTERNAL_ID AS "BANK_EXTERNAL_ID",
    a6.GLOBALID    AS "BANK_GLOBAL_ID",
    a7.ATYPE       AS "CC_ASSETTYPE",
    a7.NAME        AS "CC_ASSETNAME",
    a7.EXTERNAL_ID AS "CC_ASSETEXTERNAL_ID",
    a7.GLOBALID    AS "CC_ASSETGLOBAL_ID",
    a8.ATYPE       AS "PAYOUT_TYPE",
    a8.NAME        AS "PAYOUT_NAME",
    a8.EXTERNAL_ID AS "PAYOUT_EXTERNAL_ID",
    a8.GLOBALID    AS "PAYOUT_GLOBAL_ID",
    cr.*
FROM
    centers c
LEFT JOIN cashregisters cr
ON
    cr.center = c.id
LEFT JOIN accounts a1
ON
    a1.center = cr.ASSET_ACCOUNTCENTER
    AND a1.id = cr.ASSET_ACCOUNTID
LEFT JOIN accounts a2
ON
    a2.center = cr.RECONCILIATION_ACCOUNTCENTER
    AND a2.id = cr.RECONCILIATION_ACCOUNTID
LEFT JOIN accounts a3
ON
    a3.center = cr.ROUNDING_ACCOUNTCENTER
    AND a3.id = cr.ROUNDING_ACCOUNTID
LEFT JOIN accounts a4
ON
    a4.center = cr.ERROR_ACCOUNTCENTER
    AND a4.id = cr.ERROR_ACCOUNTID
LEFT JOIN accounts a5
ON
    a5.center = cr.PAYOUT_ACCOUNTCENTER
    AND a5.id = cr.PAYOUT_ACCOUNTID
LEFT JOIN accounts a6
ON
    a6.center = cr.BANK_ACCOUNTCENTER
    AND a6.id = cr.BANK_ACCOUNTID
LEFT JOIN accounts a7
ON
    a7.center = cr.CC_ASSET_ACCOUNTCENTER
    AND a7.id = cr.CC_ASSET_ACCOUNTID
LEFT JOIN accounts a8
ON
    a8.center = cr.PAYOUT_ACCOUNTCENTER
    AND a8.id = cr.PAYOUT_ACCOUNTID
WHERE
    c.id IN ( :scope )
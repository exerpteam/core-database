-- The extract is extracted from Exerp on 2026-02-08
--  List products sold in campaign "Öppet hus student"
/**
* Creator: Exerp
* Modified by: Stein Rudsengen.
* Purpose: List products sold in campaign "Öppet hus student"
* Note: Probably a campaign.
*
*/
SELECT
    prod.GLOBALID,
    p.CENTER || 'p' || p.ID,
    PU.TARGET_CENTER,
    PU.TARGET_ID,
    PU.TARGET_SUBID
FROM
    PRIVILEGE_USAGES PU
    /* Select PrivilegeUsages not cancelled, used for invoice lines coming from a campaign */
JOIN INVOICELINES invl
ON
    invl.CENTER = PU.TARGET_CENTER
    AND invl.ID = PU.TARGET_ID
    AND invl.SUBID = PU.TARGET_SUBID
JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.ID = invl.ID
JOIN PERSONS p
ON
    p.CENTER = inv.PERSON_CENTER
    AND p.ID = inv.PERSON_ID
left JOIN PRODUCTS prod
ON
    prod.CENTER = invl.PRODUCTCENTER
    AND prod.ID = invl.PRODUCTID
join PRIVILEGE_GRANTS pg on pg.ID = PU.GRANT_ID
WHERE
    pg.GRANTER_SERVICE = 'ReceiverGroup'
    and PU.PRIVILEGE_TYPE = 'PRODUCT'
    AND PU.TARGET_SERVICE = 'InvoiceLine'
    AND PU.STATE <> 'CANCELLED'
    AND PU.SOURCE_ID IN
    (
        SELECT
            ID
            /* Select the PrivilegeReceiverGroup Id from the name of the campaign */
        FROM
            PRIVILEGE_RECEIVER_GROUPS
        WHERE
            name = 'Öppet hus Student'
    )
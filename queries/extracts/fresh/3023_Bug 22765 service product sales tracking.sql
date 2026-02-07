SELECT

    p.GLOBALID,
    to_char(per.FIRST_ACTIVE_START_DATE,'yyyy-MM-dd') person_start_date,
    to_char(longToDate(inv.TRANS_TIME),'yyyy-MM-dd') invoice_created,
    p.CENTER || 'p' || p.id pid,
    s.CENTER || 'ss' || s.ID sid,
    s.START_DATE sub_start
FROM
    INVOICELINES invl
JOIN PRODUCTS p
ON
    invl.PRODUCTCENTER = p.CENTER
    AND invl.PRODUCTID = p.ID
    AND p.GLOBALID IN ('6MD_PRISFORSIKRING_1MDFORSINK','6MD_PRISFORSIKRING_2MFORSINK','6MD_PRISFORSIKRING')
JOIN INVOICES inv
ON
    inv.CENTER = invl.CENTER
    AND inv.id = invl.id
JOIN PERSONS per
ON
    per.CENTER = inv.PERSON_CENTER
    AND per.ID = inv.PERSON_ID
join SUBSCRIPTIONS s on s.OWNER_CENTER = p.CENTER and s.OWNER_ID = p.ID

/*group by
    p.GLOBALID,
    to_char(per.FIRST_ACTIVE_START_DATE,'yyyy-MM-dd'),
    to_char(longToDate(inv.TRANS_TIME),'yyyy-MM-dd')
*/
    order by p.GLOBALID,to_char(per.FIRST_ACTIVE_START_DATE,'yyyy-MM-dd')
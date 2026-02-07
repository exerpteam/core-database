SELECT
    s.CENTER || 'ss' || s.ID ssid,     
    s.RENEWAL_POLICY_OVERRIDE,
    c.COUNTRY,
    p.center,
    p.CENTER || 'p' || p.ID                                                                                                                                    pid,
    DECODE (p.PERSONTYPE, 0,'PRIVATE', 1,'STUDENT', 2,'STAFF', 3,'FRIEND', 4,'CORPORATE', 5,'ONEMANCORPORATE', 6,'FAMILY', 7,'SENIOR', 8,'GUEST','UNKNOWN') AS PERSONTYPE,
    max(nvl2(comp.CENTER,comp.CENTER || 'p' || comp.ID,null))                                                                                                                              comp_pid,
    max(comp.LASTNAME) comp_name,
    MIN(exerpro.longToDate(invs.ENTRY_TIME)) SPONS_ENTRY_TIME_MIN,
    MAX(exerpro.longToDate(invs.ENTRY_TIME)) SPONS_ENTRY_TIME_MAX
FROM
    SUBSCRIPTIONS s
JOIN
    PERSONS p
ON
    p.CENTER = s.OWNER_CENTER
    AND p.id = s.OWNER_ID
LEFT JOIN
    PAYMENT_CYCLE_CONFIG pcc
ON
    pcc.ID = s.RENEWAL_POLICY_OVERRIDE
LEFT JOIN
    SUBSCRIPTIONPERIODPARTS spp
ON
    spp.CENTER = s.CENTER
    AND spp.ID = s.ID
and (spp.CANCELLATION_TIME = 0 or spp.CANCELLATION_TIME is null)
LEFT JOIN
    SPP_INVOICELINES_LINK link
ON
    link.PERIOD_CENTER = spp.CENTER
    AND link.PERIOD_ID = spp.ID
    AND link.PERIOD_SUBID = spp.SUBID
LEFT JOIN
    INVOICES inv
ON
    inv.CENTER = link.INVOICELINE_CENTER
    AND inv.ID = link.INVOICELINE_ID
LEFT JOIN
    INVOICES invs
ON
    invs.CENTER = inv.SPONSOR_INVOICE_CENTER
    AND invs.ID = inv.SPONSOR_INVOICE_ID
LEFT JOIN
    PERSONS comp
ON
    comp.CENTER = invs.PAYER_CENTER
    AND comp.ID = invs.PAYER_ID
JOIN
    CENTERS c
ON
    c.ID = p.CENTER
WHERE
    s.STATE IN (2,4,8)
    AND p.center IN ($$scope$$)
group by 
    s.RENEWAL_POLICY_OVERRIDE,
    c.COUNTRY,
    p.center,
    s.CENTER || 'ss' || s.ID,
    p.CENTER || 'p' || p.ID  ,
    p.PERSONTYPE
 SELECT
     co.CENTER || 'p' || co.ID                                 COMPANY_ID
   , co.LASTNAME                                               COMPANY_NAME
   , ca.NAME                                                   AGREEMENT
   , pr.NAME                                                   AS SUBSCRIPTION
   , COUNT(DISTINCT p.CENTER || 'p' || p.id)                   NBR_ACTIVE_EMPLOYEES
   , SUM(COALESCE(sinvl.TOTAL_AMOUNT,0) - COALESCE(scnl.TOTAL_AMOUNT,0)) TOTAL_SPONS
   , SUM(COALESCE(invl.TOTAL_AMOUNT,0) - COALESCE(cnl.TOTAL_AMOUNT,0))   TOTAL_MEMBER
   , CASE
         WHEN COUNT(DISTINCT p.CENTER || 'p' || p.id) > 0
         THEN ROUND(SUM(COALESCE(sinvl.TOTAL_AMOUNT,0) - COALESCE(scnl.TOTAL_AMOUNT,0)) / COUNT(DISTINCT p.CENTER || 'p' || p.id),2)
         ELSE 0
     END SPONS_YELD_BY_MEMBER
   , CASE
         WHEN COUNT(DISTINCT p.CENTER || 'p' || p.id) > 0
         THEN ROUND(SUM(COALESCE(invl.TOTAL_AMOUNT,0) - COALESCE(cnl.TOTAL_AMOUNT,0)) / COUNT(DISTINCT p.CENTER || 'p' || p.id),2)
         ELSE 0
     END YELD_BY_MEMBER
 FROM
     RELATIVES rel
 JOIN
     COMPANYAGREEMENTS ca
 ON
     ca.CENTER = rel.RELATIVECENTER
     AND ca.ID = rel.RELATIVEID
     AND ca.SUBID = rel.RELATIVESUBID
 JOIN
     PERSONS co
 ON
     co.CENTER = ca.CENTER
     AND co.id = ca.ID
 JOIN
     PERSONS p
 ON
     p.CENTER = rel.CENTER
     AND p.ID = rel.ID
 JOIN
     SUBSCRIPTIONS s
 ON
     s.OWNER_CENTER = p.CENTER
     AND s.OWNER_ID = p.ID
     AND s.STATE IN (2,4,8)
 JOIN
     PRODUCTS pr
 ON
     pr.CENTER = s.SUBSCRIPTIONTYPE_CENTER
     AND pr.ID = s.SUBSCRIPTIONTYPE_ID
 JOIN
     SUBSCRIPTIONPERIODPARTS spp
 ON
     spp.CENTER = s.CENTER
     AND spp.id = s.id
     AND spp.SPP_STATE = 1
 JOIN
     SPP_INVOICELINES_LINK l
 ON
     l.PERIOD_CENTER = spp.CENTER
     AND l.PERIOD_ID = spp.ID
     AND l.PERIOD_SUBID = spp.SUBID
 JOIN
     INVOICELINES invl
 ON
     invl.CENTER = l.INVOICELINE_CENTER
     AND invl.ID = l.INVOICELINE_ID
     AND invl.SUBID = l.INVOICELINE_SUBID
 JOIN
     INVOICES inv
 ON
     inv.CENTER = invl.CENTER
     AND inv.ID = invl.ID
 LEFT JOIN
     CREDIT_NOTE_LINES cnl
 ON
     cnl.INVOICELINE_CENTER = invl.CENTER
     AND cnl.INVOICELINE_ID = invl.ID
     AND cnl.INVOICELINE_SUBID = invl.SUBID
 LEFT JOIN
     INVOICELINES sinvl
 ON
     sinvl.CENTER = inv.SPONSOR_INVOICE_CENTER
     AND sinvl.ID = inv.SPONSOR_INVOICE_ID
     AND sinvl.SUBID = invl.SPONSOR_INVOICE_SUBID
 LEFT JOIN
     CREDIT_NOTE_LINES scnl
 ON
     scnl.INVOICELINE_CENTER = sinvl.CENTER
     AND scnl.INVOICELINE_ID = sinvl.ID
     AND scnl.INVOICELINE_SUBID = sinvl.SUBID
 WHERE
     rel.RTYPE = 3
     AND rel.STATUS = 1
     AND spp.FROM_DATE >= $$period_from$$
     AND spp.TO_DATE <= $$period_to$$
     AND p.CENTER IN ($$scope$$)
 GROUP BY
     co.LASTNAME
   , ca.NAME
   , pr.NAME
   ,co.CENTER
   ,co.ID
 ORDER BY
     co.LASTNAME

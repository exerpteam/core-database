-- The extract is extracted from Exerp on 2026-02-08
-- For all persons in state 'Active' or 'Temporary Inactive', show payer (either other payer or themselves):
- Payer can be in any state.
- Show SUN of active (default) payment agreement.
- Show state of active (default) payment agreement.
 SELECT
  mem.memberid "Member Id",
 CASE mem.STATUS WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' END AS "Member status",
     mem.main_CENTER||'p'||mem.main_ID Payer,
     CASE  pag.clearinghouse  WHEN 1 THEN  '836301'  WHEN 601 THEN  '837394'  WHEN 201 THEN  '768308'  WHEN 401 THEN  '911116' END AS SUN,
     CASE
         WHEN pag.STATE = 1
         THEN 'CREATED'
         WHEN pag.STATE = 2
         THEN 'SENT'
         WHEN pag.STATE = 3
         THEN 'FAILED'
         WHEN pag.STATE = 4
         THEN 'OK'
         WHEN pag.STATE = 5
         THEN 'ENDED, BANK'
         WHEN pag.STATE = 6
         THEN 'ENDED, CLEARING HOUSE'
         WHEN pag.STATE = 7
         THEN 'ENDED, DEBTOR'
         WHEN pag.STATE = 8
         THEN 'CANCELLED, NOT SENT'
         WHEN pag.STATE = 9
         THEN 'CANCELLED, SENT'
         WHEN pag.STATE = 10
         THEN 'ENDED, CREDITOR'
         WHEN pag.STATE = 11
         THEN 'NO AGREEMENT'
         WHEN pag.STATE = 12
         THEN 'CASH PAYMENT'
         WHEN pag.STATE = 13
         THEN 'AGREEMENT NOT NEEDED'
         WHEN pag.STATE = 14
         THEN 'AGREEMENT INFORMATION INCOMPLETE'
         WHEN pag.STATE = 15
         THEN 'TRANSFER'
         WHEN pag.STATE = 16
         THEN 'AGREEMENT RECREATED'
         WHEN pag.STATE = 17
         THEN 'SIGNATURE MISSING'
         ELSE 'UNDEFINED'
     END AS "PAYMENT AGREEMENT STATE"
 FROM
     (
         SELECT
             per.center||'p'||    per.id memberID,
             op_rel.center ||'p'||op_rel.id,
             CASE
                 WHEN op_rel.center IS NOT NULL
                 THEN op_rel.center
                 ELSE per.center
             END AS main_center,
             CASE
                 WHEN op_rel.center IS NOT NULL
                 THEN op_rel.id
                 ELSE per.id
             END AS main_id,
             per.status
         FROM
             persons per
         LEFT JOIN
             RELATIVES op_rel
         ON
             op_rel.RELATIVECENTER=per.CENTER
         AND op_rel.RELATIVEID=per.ID
         AND op_rel.RTYPE = 12
         AND op_rel.STATUS < 3
         WHERE
           per.status IN (1,3)
         ) mem
 JOIN
     CENTERS cen
 ON
     mem.main_center = cen.id
 JOIN
     account_receivables acr
 ON
     acr.customercenter = mem.main_center
 AND acr.customerid = mem.main_id
 JOIN
     PAYMENT_ACCOUNTS pac
 ON
     pac.center = acr.center
 AND pac.ID = acr.ID
 AND acr.AR_TYPE = 4
 JOIN
     PAYMENT_AGREEMENTS pag
 ON
     pac.ACTIVE_AGR_CENTER = pag.center
 AND pac.ACTIVE_AGR_ID = pag.ID
 WHERE
     pag.clearinghouse IN (1,601,201,401)
 AND cen.country='GB'
 AND pag.active=1

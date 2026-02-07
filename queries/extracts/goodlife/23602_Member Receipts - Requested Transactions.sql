SELECT
  p.center || 'p' || p.id as "ClubPersonID",
  trans.center,
  trans.id,
  trans.subid,
TO_CHAR(longtodatec(trans.trans_time, ar.CENTER),'YYYY-MM-DD') AS "TransactionTime",
TO_CHAR(longtodatec(trans.entry_time, ar.CENTER),'YYYY-MM-DD') AS "EntryTime",
  trans.status as Status,
    trans.ref_type as RefType,
    ar.ar_type as AccountReceivableType,
  trans.text,
  atr.AMOUNT + COALESCE(vat.AMOUNT,0) AS TotalAmount,
    atr.AMOUNT AS NetAmount,
  COALESCE(vat.AMOUNT,0) AS TaxAmount,
    trans.unsettled_amount,
  invl.center || 'inv' || invl.id || 'ln' || invl.subid as SalesLineId,
    invl.productcenter || 'p' || invl.productid as ProductId,
  invl.person_center || 'p' || invl.person_id AS RecipientClubPersonId,
  recipient.fullname AS RecipientFullName,
  prod.Name AS ProductName,
  prod.globalid AS ProductGlobalId,
  --trans.center || 'ar' || trans.id || 'art' || trans.subid AS TransactionKey,
  --zipcode.province As ProvinceOfTransaction,
  settlements.art_paying_center AS CollectedPaymentCenter,
  settlements.art_paying_id AS CollectedPaymentId,
  settlements.art_paying_subid AS CollectedPaymentSubId,
  trans.entry_time as "ETS"

FROM    ACCOUNT_RECEIVABLES ar

      JOIN PERSONS p
        ON p.ID = ar.CUSTOMERID 
        AND p.CENTER = ar.CUSTOMERCENTER
                
      JOIN PERSONS cp ON 
        cp.center = p.transfers_current_prs_center 
        AND cp.id = p.transfers_current_prs_id
        AND cp.external_ID = :ExternalId

      JOIN AR_TRANS trans
        ON trans.ID = ar.ID 
        AND trans.CENTER = ar.CENTER
        AND trans.ref_type = 'INVOICE' 

      JOIN invoice_lines_mt invl
          ON trans.ref_center = invl.center
        AND trans.ref_id = invl.id
          AND trans.ref_type = 'INVOICE'

      JOIN PERSONS recipient ON
        recipient.center = invl.person_center
        AND recipient.id = invl.person_id

      JOIN products prod
        ON invl.productcenter = prod.center
        AND invl.productid = prod.id

      JOIN ACCOUNT_TRANS atr
        ON atr.center = invl.ACCOUNT_TRANS_CENTER
        AND atr.id = invl.ACCOUNT_TRANS_ID
        AND atr.SUBID = invl.ACCOUNT_TRANS_SUBID    

      JOIN invoices i
        on i.id = invl.id 
        and i.center = invl.center

      LEFT JOIN INVOICELINES_VAT_AT_LINK ivat
        ON ivat.INVOICELINE_CENTER=invl.CENTER
        AND ivat.INVOICELINE_ID=invl.ID
        AND ivat.INVOICELINE_SUBID=invl.SUBID

      LEFT JOIN ACCOUNT_TRANS vat
        ON vat.center = ivat.ACCOUNT_TRANS_CENTER
        AND vat.id = ivat.ACCOUNT_TRANS_ID
        AND vat.SUBID = ivat.ACCOUNT_TRANS_SUBID

      JOIN ART_MATCH settlements
        ON settlements.art_paid_center = trans.center
        AND settlements.art_paid_id = trans.id
        AND settlements.art_paid_subid = trans.subid
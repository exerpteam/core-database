-- The extract is extracted from Exerp on 2026-02-08
--  
 SELECT
     je.Name,
     je.person_center                 Center ,
     je.PERSON_CENTER||'p'||PERSON_ID Person_Key ,
     convert_from(big_text, 'UTF8') "Ref",
     longtodatec(art.trans_time,je.person_center) Book_Date,
      art.amount Total ,
     artm.amount , artl.text "Text"
 FROM
     JOURNALENTRIES je
 JOIN
     ACCOUNT_RECEIVABLES ar
 ON
     ar.CUSTOMERCENTER = je.person_center
 AND ar.CUSTOMERID = je.person_id
 AND ar.AR_TYPE = 4 -- Payment account
 JOIN
     AR_TRANS art
 ON
     ar.CENTER = art.CENTER
 AND ar.id = art.id
 AND art.text = convert_from(big_text, 'UTF8')
 JOIN
             ART_MATCH artm
         ON
             art.CENTER = artm.ART_PAYING_CENTER
             AND art.ID = artm.ART_PAYING_ID
             AND art.SUBID = artm.ART_PAYING_SUBID
  JOIN
                         AR_TRANS artl
                         ON artl.center = artm.ART_PAID_CENTER
                         AND artl.id = artm.ART_PAid_ID
                         AND artl.subid = artm.ART_PAid_SUBID
  JOIN
                         INVOICES inv
                         ON inv.center = art.REF_CENTER
                         AND inv.id = artl.REF_ID
  /*JOIN
                         INVOICE_LINES_MT invl
                         ON invl.center = inv.center
                         AND invl.id = inv.id
                         AND invl.TOTAL_AMOUNT != 0*/
 WHERE
   -- je.PERSON_CENTER = 1 and   je.PERSON_id = 5160
   je.creation_time BETWEEN $$fromdate$$ AND $$todate$$
  and je.person_center in ($$center$$)
  and JE.jeTYPE=3 --Note
 AND je.name = 'Debt Payment'
 ORDER BY convert_from(big_text, 'UTF8')





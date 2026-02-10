-- The extract is extracted from Exerp on 2026-02-08
--  
 select CE.NAME as SALESPERSON_CENTER,
 PE.CENTER || 'p' || PE.ID as SALESPERSON_ID,
 PE.FIRSTNAME || ' ' || PE.LASTNAME as SALESPERSON,
 C.INVOICELINE_CENTER as invoiced_center,
 CI.NAME as SALES_CENTER,
-- TO_DATE('01011970', 'DDMMYYYY') + I.TRANS_TIME/(24*3600*1000) + 1/24 as SALES_DAY2,
 TO_CHAR(longtodatec(I.TRANS_TIME,c.center),'dd/MM/YYYY') AS SALES_DAY,
 PP.CENTER || 'p' || PP.ID as CUSTOMER_ID,
 PP.FIRSTNAME || ' ' || PP.LASTNAME as CUSTOMER,
 CP.NAME as CUSTOMER_CENTER,
 P.NAME as PRODUCT,
 il.total_amount "TOTAL_AMOUNT_PAID",
 P.PRICE as PRODUCT_PRICE,
 c.clips_left "CLIPS_REMAINING",
 TO_CHAR(longtodatec(c.valid_from, c.CENTER),'dd/MM/YYYY HH24:MI')"VALID_FROM",
 TO_CHAR(longtodatec(c.valid_until, c.CENTER),'dd/MM/YYYY HH24:MI')"VALID_UNTIL",
    case c.finished
     when true
     then 'True' else 'False'
     end   "STATE_FINISHED",
     case c.cancelled
     when true
     then 'True' else 'False'
     end   "STATE_CANCELLED",
     case c.blocked
     when true
     then 'True' else 'False'
     end   "STATE_BLOCKED"
 from INVOICES I
 join INVOICELINES IL on I.CENTER=IL.CENTER and I.ID=IL.ID
 join PRODUCTS P on IL.PRODUCTCENTER=P.CENTER and IL.PRODUCTID=P.ID
 join EMPLOYEES E on I.EMPLOYEE_CENTER=E.CENTER and I.EMPLOYEE_ID=E.ID
 join PERSONS PE on E.PERSONCENTER=PE.CENTER and E.PERSONID=PE.ID
 join CENTERS CE on PE.CENTER=CE.ID
 join CLIPCARDS C on IL.CENTER=C.INVOICELINE_CENTER and IL.ID=C.INVOICELINE_ID and IL.SUBID=C.INVOICELINE_SUBID
 join PERSONS PP on C.OWNER_CENTER=PP.CENTER and C.OWNER_ID=PP.ID
 join CENTERS CP on PP.CENTER=CP.ID
 join CENTERS CI on I.CENTER=CI.ID
 /*LEFT JOIN CARD_CLIP_USAGES ccu ON ccu.CARD_CENTER = c.CENTER AND ccu.CARD_ID = c.ID
 AND ccu.CARD_SUBID = c.SUBID*/
 where P.PTYPE=4
 and C.INVOICELINE_CENTER in (:Invoiced_center)
 and I.TRANS_TIME>= :From_date
 and I.TRANS_TIME <=  :To_date
 --and p.name = '10 Day Pass'
 and p.NAME = :Product_name

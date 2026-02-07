SELECT  crt.CUSTOMERCENTER || 'p' || crt.CUSTOMERID as PersonId, crt.CRTTYPE, cr.name, ca.*, longtodateTZ(ca.TRANSTIME, 'Europe/London')
FROM CREDITCARDTRANSACTIONS ca
JOIN VA.CASHREGISTERTRANSACTIONS crt 
        ON ca.GL_TRANS_CENTER = crt.GLTRANSCENTER
        AND ca.GL_TRANS_ID = crt.GLTRANSID
        AND ca.GL_TRANS_SUBID = crt.GLTRANSSUBID
        and ca.TRANSACTION_ID is not null and ca.ACCOUNT_NUMBER is not null
        
JOIN CASHREGISTERS cr        
        ON cr.CENTER = crt.CENTER
        AND cr.ID = crt.ID

WHERE ca.TRANSTIME BETWEEN $$longDateFrom$$ AND $$longDateTo$$ + (24*60*60*1000)        

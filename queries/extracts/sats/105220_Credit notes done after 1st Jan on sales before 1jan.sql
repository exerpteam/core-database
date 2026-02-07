SELECT
     i.center||'inv'||i.id as "Invoice id",
     longtodate(i.entry_time) as "invoice date",
     i.payer_center ||'p'|| i.payer_id as "member id", 
     c.country AS "Country",
     c.shortname AS "Center",
     c.id AS "CenterID",
     pr.name AS "Product Name",
     il.quantity AS "Sales Count",
    cl.total_amount AS "credit note Total Amount",
     cl.total_amount - il.net_amount AS  "credit note VAT Amount",
     cl.net_amount AS "credit note Total Amount Excl Vat",
    case when cl.total_amount = cl.net_amount
          then Null
      else round(((cl.total_amount - cl.net_amount) / cl.net_amount)*100,0) end as "VAT rate" ,
     cl.center||'cred'||cl.id as "creditnote id",
     longtodate(cn.entry_time) as "credit date"
 FROM
     INVOICES i
 JOIN
     invoice_lines_mt il
 ON
     i.center = il.center
     AND i.id = il.id
 JOIN
     CREDIT_NOTE_LINES_MT cl
 ON    
 cl.invoiceline_center = il.center
 and
 cl.invoiceline_id = il.id
 and
 cl.invoiceline_subid = il.subid
 
 join credit_notes cn
 on
 cl.center = cn.center
 and
 cl.id = cn.id
     
 JOIN
    PRODUCTS pr
 ON
    il.Productcenter = pr.center
    AND il.PRODUCTID = pr.ID
  JOIN
    centers c
 ON
    c.ID = i.CENTER

 
 WHERE
    c.ID IN (:Scope)
    AND i.entry_time < (1767222000000) AND cn.entry_time > (1767222000000)
SELECT
     c.center,
     c.id,
     c.subid,
     c.owner_center,
     c.owner_id,
persons.firstname,
persons.lastname,
     c.clips_left,
     c.clips_initial,
     LongToDate(c.valid_until) as valid_until,
     prod.name,
     member_il.total_amount as customer_price,
     company_il.total_amount as company_price,
     company.lastname,
     company.center||'p'||company.id as company
FROM
     CLIPCARDS C
join INVOICELINES member_il
    on
      c.invoiceline_center = member_il.center
      and c.invoiceline_id = member_il.id
      and c.invoiceline_subid = member_il.subid
join INVOICES member_inv 
    on 
        member_inv.CENTER =  member_il.CENTER 
        and member_inv.ID =  member_il.ID
left join INVOICES company_inv
    on company_inv.center = member_inv.SPONSOR_INVOICE_CENTER
    and company_inv.id = member_inv.SPONSOR_INVOICE_ID
left join INVOICELINES company_il
    on company_il.center = company_inv.center
    and company_il.id = company_inv.id
    and company_il.SUBID = member_il.SPONSOR_INVOICE_SUBID
join PRODUCTS prod
    on
      c.center = prod.center
      and c.id = prod.id
left join persons company
    on company.center = company_inv.person_center
      and company.id = company_inv.person_id

left join persons persons
on persons.center = c.owner_center and persons.id = c.owner_id
WHERE
      C.OWNER_CENTER >= :homecenterid
  AND c.clips_left > 0
  AND c.finished =0
  AND c.cancelled =0
order by
    c.owner_center,
    c.owner_id

select 
c.name as "Center",
p.fullname,
to_char(longtodatec(i.trans_time,i.center),'mm/dd/yyyy hh12:mm:ss') as "Transaction_Time",
right(i.text,length(i.text)-14) as "Product_Sold",
i.payer_center||'p'||i.payer_id as "Person_ID"
  from chelseapiers.invoices i 
  join chelseapiers.persons p on p.center = i.payer_center and p.id = i.payer_id
  join chelseapiers.centers c on c.id = i.center
where i.employee_center = 100 and i.employee_id = 2201
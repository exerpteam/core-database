select * from payment_agreements 
where ref like '%' || $$Reference$$ 
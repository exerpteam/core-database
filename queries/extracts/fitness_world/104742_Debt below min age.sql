-- The extract is extracted from Exerp on 2026-02-08
-- ES-43448 under age overdue debt
select 
ccc.personcenter||'p'||ccc.personid as member_key,
closed, successfull, hold, amount, cashcollectionservice, ext_ref, startdate, currentstep, currentstep_type, currentstep_date, nextstep_date, nextstep_type, missingpayment, below_minimum_age


from cashcollectioncases ccc

where   ccc.below_minimum_age is true
        and ccc.closed is false
select 
pa.center,
pa.id,
pa.ref,
pa.individual_deduction_day
from
payment_agreements pa
where
pa.clearinghouse = '202'
and
pa.active = 't'
and
pa.center in(:scope)

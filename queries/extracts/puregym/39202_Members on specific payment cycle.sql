select 


ac.CUSTOMERCENTER||'p'||ac.CUSTOMERID  AS MEMBER_ID,
p.FULLNAME,
DECODE ( p.persontype, 0,'Private', 1,'Student', 2,'Staff', 3,'Friend', 4,'Corporate', 5,'Onemancorporate', 6,'Family', 7,'Senior', 8,'Guest','Unknown') AS PERSON_TYPE,
pa.CENTER ||'-'|| pa.ID ||'-'|| pa.SUBID AS AGREEMENT_ID

from PAYMENT_CYCLE_CONFIG pcc

join  PAYMENT_AGREEMENTS pa on pa.PAYMENT_CYCLE_CONFIG_ID = pcc.ID

join PAYMENT_ACCOUNTS pac on pac.ACTIVE_AGR_CENTER = pa.CENTER and pac.ACTIVE_AGR_ID = pa.ID and pac.ACTIVE_AGR_SUBID = pa.SUBID

join ACCOUNT_RECEIVABLES ac on ac.CENTER = pac.CENTER and ac.ID = pac.ID

join PERSONS p on ac.CUSTOMERCENTER = p.CENTER and ac.CUSTOMERID = p.ID

join PAYMENT_CYCLE_CONFIG pcc on pcc.ID = pa.PAYMENT_CYCLE_CONFIG_ID

where pcc.NAME in (:PaymentCycleName)
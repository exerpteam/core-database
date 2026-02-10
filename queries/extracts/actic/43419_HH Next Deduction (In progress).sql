-- The extract is extracted from Exerp on 2026-02-08
-- List information of next deduction.
Should be emailed to customer.
https://actic.zendesk.com/agent/tickets/600087
/*SELECT * FROM DC_DEDUCTIONS dc 
WHERE
	dc.MEMBERCENTER = 45
	AND dc.MEMBERID = 636*/
SELECT * from DC_DEDUCTIONS dc
--where MEMBERID = '45p636'
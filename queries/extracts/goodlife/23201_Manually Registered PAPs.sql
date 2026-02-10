-- The extract is extracted from Exerp on 2026-02-08
-- Audits for payments registered from the payment requests tab as opposed to through the cash register using the pay button.

Approved in ISSUE-30572
Reviewed in ST-5798
;WITH art
AS (
SELECT
	  center
	,	id
	, subid
	, trans_time
	,	amount
	,	due_date
	, info
	,	text
	,	ref_type
	,	status
	,	unsettled_amount
	,	collected_amount
	, employeecenter
	, employeeid
	, entry_time -- AS "ETS"
	, ref_center
	, ref_id
	, ref_subid
FROM AR_TRANS
WHERE 1=1
	AND (text LIKE 'Manual registered payment%')
--	AND trans_time 
	AND entry_time 
		BETWEEN
		  (SELECT EXTRACT(EPOCH FROM CAST($$dayFrom$$ AS date)) * 1000)
			AND
		  (SELECT EXTRACT(EPOCH FROM CAST($$dayTo$$ AS date)) * 1000)
) 
, artEmp 
AS (
SELECT art.*, e.personcenter, e.personid
FROM art
	JOIN employees e
		ON e.center = art.employeecenter
		AND e.id = art.employeeid
-- WHERE e.personcenter NOT IN ('990', '100')
)
, artEmpRec
AS (
SELECT artEmp.*, ar.customerid, ar.customercenter
FROM artEmp
	JOIN account_receivables ar
		ON artEmp.center = ar.center
			AND artEmp.id = ar.id
)
, artEmpRecTrans
AS (
SELECT aer.*, at.debit_accountcenter, at.debit_accountid, at.aggregated_transaction_center, at.aggregated_transaction_id
, at.center AS atcenter, at.id AS atid, at.subid AS atsubid
FROM artEmpRec aer
	JOIN account_trans at
		ON		at.center = aer.ref_center
			AND	at.id = aer.ref_id
			AND	at.subid = aer.ref_subid
WHERE 1=1
/*
	AND at.trans_time 
		BETWEEN
		  (SELECT EXTRACT(EPOCH FROM CAST($$dayFrom$$ AS date)) * 1000)
			AND
		  (SELECT EXTRACT(EPOCH FROM CAST($$dayTo$$ AS date)) * 1000)
*/
	AND at.info_type = 16
)
, artEmpRecTrans2
AS (
SELECT aert.*
FROM artEmpRecTrans aert
	JOIN account_trans at2
		ON 		at2.debit_transaction_center = aert.atcenter
			AND at2.debit_transaction_id = aert.atid
			AND at2.debit_transaction_subid = aert.atsubid
WHERE 	at2.info_type = 16
	AND at2.debit_accountcenter = 990
	AND at2.debit_accountid = 90
)
, a990
AS (
SELECT a.center, a.id, a.name, a.external_id
FROM accounts a
WHERE a.name = 'Debt to 990'
)
, artEmpRecTransAc
AS (
SELECT aert.*, a.name, a.external_id
FROM artEmpRecTrans2 aert
	JOIN a990 a
		ON		a.center = aert.debit_accountcenter
			AND	a.id = aert.debit_accountid
)
, artEmpRecTransAcPers
AS (
SELECT aerta.*, p.center AS person_center, p.id AS person_id, p.firstname, p.lastname, ep.fullname, ep.center AS associate_center
FROM artEmpRecTransAc aerta
	JOIN PERSONS p
		ON	  aerta.CUSTOMERID = p.ID 
		  AND aerta.CUSTOMERCENTER = p.CENTER
	JOIN persons ep
		ON    ep.center = aerta.personcenter
		  AND ep.id = aerta.personid
)
SELECT
	LONGTODATE (t.entry_time) AS EntryDate,
--  to_char(longtodatec(t.entry_time, 'yyyy-MM-dd hh24:mi') AS EntryDateTime,
	to_char(longtodatec(t.entry_time, 100),'yyyy-MM-dd HH24:MI:SS') AS EntryDateTime,
	t.person_center || 'p' || t.person_id as PersonID,
	t.firstname,
  t.lastname,
	t.amount,
	t.aggregated_transaction_center || 'agt' || t.aggregated_transaction_id AS AgtId,
	LONGTODATE (t.trans_time) AS BookDate,
	t.text,
	t.fullname AS AssociateName,
	t.associate_center as Center,
	t.name AS GlobalAccount, 
	t.external_id,
	t.center || 'ar' || t.id || 'art' || t.subid AS TransactionKey,
--	t.due_date, 
	t.info,
	t.ref_type,
	t.status,
	t.unsettled_amount,
	t.collected_amount
FROM artEmpRecTransAcPers t

WITH
    PARAMS AS
    (
        SELECT
            CASE
                WHEN $$offset$$=-1
                THEN 0
                ELSE CAST((CURRENT_DATE-$$offset$$-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000
            END AS FROMDATE,
            CAST((CURRENT_DATE+1-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 AS TODATE
    )
    
select 
cmt.center || 'cred' || cmt.id || 'cnl' || cmt.subid as CreditNoteId
,cmt.invoiceline_center || 'inv' || cmt.invoiceline_id || 'ln' || cmt.invoiceline_subid as InvoiceLineId
, c.id as ClubNumber
, c.name as ClubName
, cmt.person_center || 'p' || cmt.person_id AS MemberPersonId
, pe.External_ID as MemberExternalID
, pe.firstname ||' '|| pe.lastname MemberName
, p.name As ProductName
, p.globalid As ProductGlobalID
, cn.text As CreditNoteNotes
, cmt.total_amount As CreditNoteValuewithTax
--, longtodateC(cn.trans_time, 100) AS CreditNoteDateProcessed
, TO_CHAR(longtodatec(cn.trans_time, 100), 'YYYY-MM-DD HH24:MI') 
AS CreditNoteDateProcessed
, cn.coment As CreditNoteDetails
, ep.center || 'p' || ep.id As AssociatePersonID
, ep.External_id AS AssociateExternalId
, ep.firstname ||' '|| ep.lastname As AssociateName

from credit_notes cn
CROSS JOIN
    params
	join credit_note_lines_mt cmt
		on cn.center = cmt.center
			and cn.id = cmt.id
	join centers c
		on c.id = cn.center
	join Products p
		on p.center = cmt.productcenter
		and p.id = cmt.productid
	join Employees em
		on em.center = cn.employee_center
		and em.id = cn.employee_id
	join Persons ep
		on ep.center = em.personcenter
		and ep.id = em.personid
	join Persons pe
		on pe.center = cmt.person_center
		and pe.id = cmt.person_id	
where
c.id in ($$scope$$) 

and cn.trans_time BETWEEN
		PARAMS.FROMDATE AND PARAMS.TODATE
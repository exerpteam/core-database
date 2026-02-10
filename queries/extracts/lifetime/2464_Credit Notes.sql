-- The extract is extracted from Exerp on 2026-02-08
-- It allows us to pull up all the credit notes across all Clubs. Filterable. What credit note is being processed at a Club in detail.


select 
c.id as ClubNumber
, c.name as ClubName
, cmt.person_center || 'p' || cmt.person_id AS MemberPersonId
, pe.External_ID as MemberExternalID
, pe.firstname ||' '|| pe.lastname MemberName
, p.name As ProductName
, p.globalid As ProductGlobalID
, cn.text As CreditNoteNotes
, cmt.total_amount As CreditNoteValuewithTax
, TO_CHAR(longtodateC(cn.trans_time, 100),'YYYY-MM-DD') AS CreditNoteDateProcessed
, cn.coment As CreditNoteDetails
, ep.center || 'p' || ep.id As AssociatePersonID
, ep.External_id AS AssociateExternalId
, ep.firstname ||' '|| ep.lastname As AssociateLastName

from credit_notes cn
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

and

CASE WHEN $$personid$$='ALL' THEN '1' ELSE
em.personcenter || 'p' || em.personid = $$personid$$--(:personid)  
END
 
--and em.personcenter || 'p' || em.personid = (:personid)



and cn.trans_time BETWEEN
		CAST((:CreditNoteDateProcessStart-to_date('1-1-1970','MM-DD-YYYY')) AS BIGINT)*24*3600*1000 
        AND CAST((:CreditNoteDateProcessEnd-to_date('1-1-1970','MM-DD-YYYY'))AS BIGINT)*24*3600*1000 

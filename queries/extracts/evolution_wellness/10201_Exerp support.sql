-- The extract is extracted from Exerp on 2026-02-08
--  
select p.fullname,
       je.id as journal_entry_id,
       jes.id as journalentry_signature_id,
       s.center as signature_center,
       s.id as signature_id,
       s.center as signature_center,
       s.id as signature_id,
       je.name as doc_name,
       je.document_name as doc_filename,
       to_timestamp(s.creation_time / 1000) as signed_time,
       to_timestamp(je.creation_time / 1000) as created_time,
       je.document as unsigned_doc_zipped_pdf,
       s.signed_document as signed_doc_zipped_pdf,
       s.signature_image_data as signature_zipped_png,
       jes.position_left as pos_left,
       jes.position_top as pos_top,
       jes.width as pos_width,
       jes.height as pos_height,
       jes.page as pos_page
from signatures s
join journalentry_signatures jes on s.center = jes.signature_center AND s.id = jes.signature_id
join journalentries je on jes.journalentry_id = je.id
join persons p on je.person_center = p.center AND je.person_id = p.id
where p.center = 108
  and p.id in (5847,6601,5291)
  and je.signable = true
  and je.state = 'ACTIVE'
  and s.signed_document_mimetype = 'application/x-zip-pdf'
  and s.signature_image_mimetype = 'image/x-zip-png'
  and je.document is not null
  and s.signed_document is not null
  and s.signature_image_data is not null
order by je.id;SE
-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        i.payer_center || 'p' || i.payer_id AS payer_clipcard,
        il.person_center || 'p' || il.person_id AS assigned_to_incorrectly,
        c_org.finished AS is_original_clipcard_finished,
        c_org.cancelled AS is_original_clipcard_cancelled,
        c_org.blocked AS is_original_clipcard_blocked,
        c_new.owner_center || 'p' || c_new.owner_id AS transferred_to_person,
        c_new.finished AS is_new_clipcard_finished,
        c_new.cancelled AS is_new_clipcard_cancelled,
        c_new.blocked AS is_new_clipcard_blocked
FROM evolutionwellness.clipcards c_org
JOIN evolutionwellness.invoice_lines_mt il ON c_org.invoiceline_center = il.center AND c_org.invoiceline_id = il.id AND c_org.invoiceline_subid = il.subid
JOIN evolutionwellness.invoices i ON i.center = il.center AND i.id = il.id 
LEFT JOIN evolutionwellness.clipcards c_new ON c_new.transfer_from_clipcard_center = c_org.center AND c_new.transfer_from_clipcard_id = c_org.id AND c_new.transfer_from_clipcard_subid = c_org.subid
WHERE 
        (il.person_center, il.person_id) != (i.payer_center, i.payer_id)
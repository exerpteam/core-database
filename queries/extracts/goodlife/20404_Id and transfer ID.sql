-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
        cp.center || 'p' || cp.id AS PersonId,
        tr.center || 'p' || tr.id AS TransferredPersonId
FROM goodlife.persons tr
JOIN goodlife.persons cp On tr.transfers_current_prs_center = cp.center and tr.transfers_current_prs_id = cp.id
where
        tr.center || 'p' || tr.id IN (:ListOfIds)
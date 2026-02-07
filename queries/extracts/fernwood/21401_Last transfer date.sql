SELECT 
        CAST(max(oldpea.txtvalue) AS DATE) AS Transfer_date
FROM
        persons p
JOIN
        persons oldp
        ON p.center = oldp.transfers_current_prs_center
        AND p.id = oldp.transfers_current_prs_id
JOIN
        PERSON_EXT_ATTRS oldpea
        ON oldpea.PERSONCENTER = oldp.center
        AND oldpea.PERSONID = oldp.id
        AND oldpea.name = '_eClub_TransferDate'
WHERE
        p.external_id = :external_id  
GROUP BY 
		p.external_id   
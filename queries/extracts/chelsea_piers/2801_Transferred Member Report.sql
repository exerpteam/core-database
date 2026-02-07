WITH PARAMS AS
(
        SELECT
             TO_DATE(:FromDate,'YYYY-MM-DD') AS FROM_DATE,
             TO_DATE(:ToDate,'YYYY-MM-DD') AS TO_DATE
)
SELECT
        p2.firstname AS "First Name",
        p2.lastname AS "Last Name",
        t1.center || 'p' || t1.id AS "Transferred From Id",
        transfer_to.txtvalue AS "Transferred To Id",
        fromCenter.shortname AS "Former Home Club",
        toCenter.shortname AS "Current Home Club",
        TO_CHAR(t1.transfer_date,'MM-DD-YYYY') AS "Transfer Date"
FROM
(
        SELECT
                p.center,
                p.id,
                TO_DATE(transfer_date.txtvalue,'YYYY-MM-DD') AS transfer_date
        FROM chelseapiers.persons p
        JOIN chelseapiers.person_ext_attrs transfer_date 
                ON p.center = transfer_date.personcenter 
                AND p.id = transfer_date.personid 
                AND transfer_date.name = '_eClub_TransferDate' 
                AND transfer_date.txtvalue IS NOT NULL
) t1
CROSS JOIN PARAMS par
JOIN chelseapiers.person_ext_attrs transfer_to 
                ON t1.center = transfer_to.personcenter 
                AND t1.id = transfer_to.personid 
                AND transfer_to.name = '_eClub_TransferredToId' 
                AND transfer_to.txtvalue IS NOT NULL
JOIN chelseapiers.persons p2
        ON (p2.center || 'p' || p2.id) = transfer_to.txtvalue
JOIN chelseapiers.centers fromCenter
        ON fromCenter.id = t1.center
JOIN chelseapiers.centers toCenter
        ON toCenter.id = p2.center
WHERE
        transfer_date between par.FROM_DATE AND par.TO_DATE
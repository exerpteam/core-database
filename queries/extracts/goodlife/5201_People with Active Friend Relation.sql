SELECT DISTINCT
    relatives.center || 'p' || relatives.id as PersonId
FROM
    goodlife.relatives
WHERE
    relatives.rtype = 5
AND relatives.status = 1
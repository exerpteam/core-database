SELECT
    cin.ID AS "ID",
    h.name   "CLEARING_HOUSE",
    CASE
        WHEN cin.STATE = 1
        THEN 'Received'
        WHEN cin.STATE = 2
        THEN 'Verified'
        WHEN cin.STATE = 3
        THEN 'Errored'
        WHEN cin.STATE = 4
        THEN 'Bad'
        WHEN cin.STATE = 5
        THEN 'Handled'
        WHEN cin.STATE = 6
        THEN 'Confirmed'
        WHEN cin.STATE = 7
        THEN 'Cleaned'
        WHEN cin.STATE = 8
        THEN 'Handling'
        ELSE 'UNDEFINED'
    END AS "STATE",
    cin.RECEIVED_DATE   AS "RECEIVED_DATETIME",
    cin.GENERATED_DATE  AS "GENERATED_DATETIME",
    cin.FILENAME        AS "FILENAME",
    cin.REF             AS "REFERENCE"
FROM
    CLEARING_IN cin
LEFT JOIN
    CLEARINGHOUSES h 
ON
   cin.CLEARINGHOUSE = h.id    
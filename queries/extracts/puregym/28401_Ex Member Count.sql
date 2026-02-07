SELECT 
    DECODE(C.NAME, NULL, '--Total', C.NAME)  AS "Club Name",
    COUNT(1) as "Total Ex Member"
FROM
    PERSONS P
JOIN 
    CENTERS C
ON
    C.ID = P.CENTER        
WHERE
    P.CENTER IN ($$center$$)
    AND P.STATUS = 2
    AND P.PERSONTYPE != 2
GROUP BY 
    GROUPING SETS ((C.NAME), ())
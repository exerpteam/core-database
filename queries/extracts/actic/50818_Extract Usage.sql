WITH PARAMS AS (
                SELECT 
                /* materialize */
                DATETOLONGC(TO_CHAR(:Last_Usage_Date,'YYYY-MM-DD HH24:MI'), 100) AS from_time
                FROM DUAL)
SELECT
   t.EXTRACT_ID, e.name AS "Extract Name", longtodateC(t.TIME, 100) AS "Last Used Time", 
   p.FIRSTNAME || ' ' || p.LASTNAME AS "Employee Name",
   CASE WHEN t.EMPLOYEE_CENTER is not null then  t.EMPLOYEE_CENTER||'emp'||t.EMPLOYEE_ID END AS "Employee ID",
   CASE WHEN em.PERSONCENTER is not null THEN em.PERSONCENTER||'p'||em.PERSONID END AS "Person ID"
FROM
    params,
    (
        SELECT
            eu.*,
            rank() over (partition BY eu.extract_id ORDER BY eu.TIME DESC) AS rnk
        FROM
            extract_usage eu ) t
    JOIN
       extract e
    ON 
      t.EXTRACT_ID = e.ID            
    LEFT JOIN
      EMPLOYEES em
    on
      em.CENTER = t.EMPLOYEE_CENTER   
      AND em.ID = t.EMPLOYEE_ID
    left join 
      persons p
    ON  
      em.personcenter = p.center
      and em.personid = p.id
WHERE
    rnk = 1
    AND e.blocked = 0
    AND t.TIME > params.from_time
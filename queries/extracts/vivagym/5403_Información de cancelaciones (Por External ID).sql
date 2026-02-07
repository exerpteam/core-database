        SELECT DISTINCT
            p.center as "Home club ID",
                 CE.NAME AS "Home Club nombre", 
                     P.FIRSTNAME AS "Socio nombre",
                     P.LASTNAME AS "Socio apellidos", 
            s.owner_center || 'p' || s.owner_id AS "Codigo de persona", 
            P.EXTERNAL_ID as "External ID", 
             CASE P.STATUS
             WHEN 0 THEN 'LEAD'
     WHEN 1 THEN 'ACTIVE'
     WHEN 2 THEN 'INACTIVE'
     WHEN 3 THEN 'TEMPORARY INACTIVE' 
    WHEN 4 THEN 'TRANSFERRED' 
    WHEN 5 THEN 'DUPLICATE' 
    WHEN 6 THEN 'PROSPECT' 
    WHEN 7 THEN 'DELETED'
     WHEN 8 THEN 'ANONIMIZED' 
    WHEN 9 THEN 'CONTACT'
     ELSE 'UNKNOWN' END AS "Estado persona", 
            PR.NAME AS "Cuota", 
            CASE S.STATE WHEN 2 
            THEN 'ACTIVE' WHEN 3 THEN 'ENDED' WHEN 4 THEN 'FROZEN' WHEN 7 
            THEN 'WINDOW' WHEN 8 THEN 'CREATED' ELSE 'UNKNOWN' END AS 
            "Estado cuota",    
            S.CENTER AS "Club Cuota ID",
                 S.ID AS "Cuota socio ID",
            s.end_date as "Fecha de baja",
                       TO_CHAR(TO_TIMESTAMP(sc.change_time / 1000), 'DD/MM/YYYY HH24:MI:SS') AS "Fecha solicitud baja",
 sc.employee_center || 'emp' || sc.employee_id AS "Emp que cancela", 
    --    sc.change_time, 
            TO_CHAR(TO_TIMESTAMP(sc.cancel_time / 1000), 'DD/MM/YYYY HH24:MI:SS') AS "Fecha cancelación baja"
  --      sc.cancel_time
           FROM
            subscriptions s
                LEFT join PRODUCTS AS PR ON (PR.CENTER = s.SUBSCRIPTIONTYPE_CENTER AND PR.ID 
            = s.SUBSCRIPTIONTYPE_ID) 
        JOIN
            persons p
        ON
            s.owner_center = p.center
        AND s.owner_id = p.id
        LEFT 
        join CENTERS AS CE ON P.CENTER = CE.ID
        JOIN
            vivagym.subscriptiontypes st
        ON
            s.subscriptiontype_center = st.center
        AND s.subscriptiontype_id = st.id
        AND st.st_type = 1
        LEFT JOIN
            subscription_change sc
        ON
            s.center = sc.old_subscription_center
        AND s.id = sc.old_subscription_id
        AND sc.type = 'END_DATE'
        WHERE
        P.EXTERNAL_ID IN (:externalid)


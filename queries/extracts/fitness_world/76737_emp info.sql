-- This is the version from 2026-02-05
--  
SELECT
                        e.CENTER || 'emp' || e.ID AS MemberID,
                        p.CENTER as PCenter,
                        p.ID AS PId,
                        p.EXTERNAL_ID AS ExternalID,
                        p.FIRSTNAME AS First_name, 
                        p.LASTNAME AS Last_name,
                        c.NAME AS Center,
                        pr.NAME AS MembershipName,
                        e.LAST_LOGIN AS LastLogin
                     
                         
                FROM
                        PERSONS p
                JOIN 
                        EMPLOYEES e ON p.CENTER = e.PERSONCENTER AND p.ID = e.PERSONID
                LEFT JOIN 
                        SUBSCRIPTIONS s ON p.CENTER = s.OWNER_CENTER AND p.ID = s.OWNER_ID AND s.STATE IN (2,4,8)
                LEFT JOIN 
                        FW.SUBSCRIPTIONTYPES st ON s.SUBSCRIPTIONTYPE_CENTER = st.CENTER AND s.SUBSCRIPTIONTYPE_ID = st.ID
                LEFT JOIN
                        FW.PRODUCTS pr ON st.CENTER = pr.CENTER AND st.ID = pr.ID
                LEFT JOIN
                        CENTERS c ON p.CENTER = c.ID
                WHERE
                        p.PERSONTYPE = 2
                        AND e.BLOCKED = 0
and p.center = :scope  
                        
                        
WITH duplicated_emails AS
(
        SELECT
                pea.txtvalue AS emails,
                count(*)
        FROM
                chelseapiers.persons p
        JOIN 
                chelseapiers.person_ext_attrs pea ON p.center = pea.personcenter AND p.id = pea.personid 
                        AND pea.name = '_eClub_Email' AND pea.txtvalue IS NOT NULL
        WHERE
                pea.txtvalue NOT IN ('no@email.com','fitness@chelseapiers.com','noemail@gmail.com')
        GROUP BY
                pea.txtvalue
        HAVING COUNT(*) > 1
),
list_persons AS
(
        SELECT
                email.personcenter,
                email.personid,
                email.txtvalue AS email
        FROM chelseapiers.person_ext_attrs email
        WHERE
                email.name = '_eClub_Email'
                AND email.txtvalue IN (SELECT de.emails FROM duplicated_emails de)
),
list_subscriptions AS
(
        SELECT
                DISTINCT
                        s.owner_center,
                        s.owner_id
        FROM list_persons lp
        JOIN chelseapiers.subscriptions s ON lp.personcenter = s.owner_center AND lp.personid = s.owner_id AND s.state IN (2,4,8)
),
list_clipcards AS
(       
        SELECT
                DISTINCT
                        c.owner_center,
                        c.owner_id
        FROM list_persons lp
        JOIN chelseapiers.clipcards c ON lp.personcenter = c.owner_center AND lp.personid = c.owner_id 
                AND c.finished = false AND c.cancelled = false AND c.blocked = false
),
list_bookings AS
(
        WITH params AS
                (
                        SELECT
                                dateToLongC(TO_CHAR(TO_DATE(getCenterTime(c.id), 'YYYY-MM-DD'), 'YYYY-MM-DD'),c.id) AS cutDate,
                                c.id
                        FROM
                                chelseapiers.centers c
                ) 
        SELECT
                part.participant_center,
                part.participant_id,
                COUNT(*) AS total_bookings
        FROM list_persons lp
        JOIN chelseapiers.participations part ON lp.personcenter = part.participant_center AND lp.personid = part.participant_id
                AND part.state NOT IN ('CANCELLED')
        JOIN params par ON par.id = part.center
        WHERE
                part.start_time > par.cutDate
        GROUP BY 
                part.participant_center,
                part.participant_id
),
v_main AS
(
        SELECT 
                lp.email,
                lp.personcenter || 'p' || lp.personid AS PersonId,
                (CASE WHEN ls.owner_center IS NULL THEN 'NO' ELSE 'YES' END) AS Has_Subscriptions,
                (CASE WHEN lc.owner_center IS NULL THEN 'NO' ELSE 'YES' END) AS Has_Clipcards,
                lb.total_bookings AS Future_Bookings
        FROM list_persons lp
        LEFT JOIN list_subscriptions ls ON lp.personcenter = ls.owner_center AND lp.personid = ls.owner_id
        LEFT JOIN list_clipcards lc ON lp.personcenter = lc.owner_center AND lp.personid = lc.owner_id
        LEFT JOIN list_bookings lb ON lb.participant_center = lp.personcenter AND lb.participant_id = lp.personid
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(PersonId,1) OVER (PARTITION BY email ORDER BY email) AS PersonId2,
                LEAD(Has_Subscriptions,1) OVER (PARTITION BY email ORDER BY email) AS Has_Subscriptions2,
                LEAD(Has_Clipcards,1) OVER (PARTITION BY email ORDER BY email) AS Has_Clipcards2,
                LEAD(Future_Bookings,1) OVER (PARTITION BY email ORDER BY email) AS Future_Bookings2,
                
                LEAD(PersonId,2) OVER (PARTITION BY email ORDER BY email) AS PersonId3,
                LEAD(Has_Subscriptions,2) OVER (PARTITION BY email ORDER BY email) AS Has_Subscriptions3,
                LEAD(Has_Clipcards,2) OVER (PARTITION BY email ORDER BY email) AS Has_Clipcards3,
                LEAD(Future_Bookings,2) OVER (PARTITION BY email ORDER BY email) AS Future_Bookings3,
                
                LEAD(PersonId,3) OVER (PARTITION BY email ORDER BY email) AS PersonId4,
                LEAD(Has_Subscriptions,3) OVER (PARTITION BY email ORDER BY email) AS Has_Subscriptions4,
                LEAD(Has_Clipcards,3) OVER (PARTITION BY email ORDER BY email) AS Has_Clipcards4,
                LEAD(Future_Bookings,3) OVER (PARTITION BY email ORDER BY email) AS Future_Bookings4,
                
                LEAD(PersonId,4) OVER (PARTITION BY email ORDER BY email) AS PersonId5,
                LEAD(Has_Subscriptions,4) OVER (PARTITION BY email ORDER BY email) AS Has_Subscriptions5,
                LEAD(Has_Clipcards,4) OVER (PARTITION BY email ORDER BY email) AS Has_Clipcards5,
                LEAD(Future_Bookings,4) OVER (PARTITION BY email ORDER BY email) AS Future_Bookings5,
                
                LEAD(PersonId,5) OVER (PARTITION BY email ORDER BY email) AS PersonId6,
                LEAD(Has_Subscriptions,5) OVER (PARTITION BY email ORDER BY email) AS Has_Subscriptions6,
                LEAD(Has_Clipcards,5) OVER (PARTITION BY email ORDER BY email) AS Has_Clipcards6,
                LEAD(Future_Bookings,5) OVER (PARTITION BY email ORDER BY email) AS Future_Bookings6,
                
                ROW_NUMBER() OVER (PARTITION BY email ORDER BY email) AS ADDONSEQ
        FROM
            v_main
)
SELECT 
        v_pivot.email,
        v_pivot.personid AS personid1,
        v_pivot.has_subscriptions AS has_subscriptions1,
        v_pivot.has_clipcards AS has_clipcards1,
        v_pivot.future_bookings AS future_bookings1,
        v_pivot.personid2,
        v_pivot.has_subscriptions2,
        v_pivot.has_clipcards2,
        v_pivot.future_bookings2,
        v_pivot.personid3,
        v_pivot.has_subscriptions3,
        v_pivot.has_clipcards3,
        v_pivot.future_bookings3,
        v_pivot.personid4,
        v_pivot.has_subscriptions4,
        v_pivot.has_clipcards4,
        v_pivot.future_bookings4,
        v_pivot.personid5,
        v_pivot.has_subscriptions5,
        v_pivot.has_clipcards5,
        v_pivot.future_bookings5,
        v_pivot.personid6,
        v_pivot.has_subscriptions6,
        v_pivot.has_clipcards6,
        v_pivot.future_bookings6
FROM v_pivot
WHERE ADDONSEQ=1


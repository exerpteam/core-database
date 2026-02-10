-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT      
        t4.StaffPersonCenter,
        t4.StaffPersonId,
        t4.StaffPersonCenter || 'p' || t4.StaffPersonId AS "PERSONKEY",
        string_agg(t4.partlist2,CHR(13) || CHR(10)) AS partlist3
FROM
(
        SELECT
                t3.StaffPersonCenter,
                t3.StaffPersonId,
                t3.CenterName || '(' || t3.BookingCenter || ')' || CHR(13) || CHR(10) || lpad('-',length(t3.CenterName)+5,'-') || CHR(13) || CHR(10) || t3.partlist AS partlist2
        FROM
        (
                SELECT
                        t2.StaffPersonCenter,
                        t2.StaffPersonId,
                        t2.BookingCenter,
                        t2.CenterName,
                        string_agg(t2.bookinginfo,CHR(13) || CHR(10) ORDER BY t2.BookingDate, t2.BookingTime) AS partlist
                FROM
                (
                        SELECT
                                t1.StaffPersonCenter,
                                t1.StaffPersonId,
                                t1.BookingDate,
                                t1.BookingTime,
                                t1.BookingCenter,
                                c.NAME AS CenterName,
                                'Member: ' || t1.MemberName || ' (' || t1.MemberNumber || ')' || CHR(13) ||
                                CHR(10)|| 'Activity: ' || t1.ActivityName || CHR(13) || CHR(10) || 'Date : ' ||
                                t1.BookingDate || '    Time : ' || t1.BookingTime || CHR(13) || CHR(10) ||
                                '# of Sessions in Inventory: ' || coalesce(t1.clipsleft,0) || CHR(13) || CHR(10) ||
                                'Participant State: ' || t1.parState || CHR(13) || CHR(10) || 'Booking Center: ' || t1.BookingCenter || CHR(13) || CHR(10) AS bookinginfo
                        FROM
                        (
                                SELECT
                                        t1in.MemberName,
                                        t1in.MemberNumberCenter || 'p' || t1in.MemberNumberId AS MemberNumber,
                                        t1in.BookingDate,
                                        t1in.BookingTime,
                                        t1in.ActivityName,
                                        t1in.StaffPersonCenter,
                                        t1in.StaffPersonId,
                                        t1in.parState,
                                        t1in.BookingCenter,
                                        SUM(cc.clips_left) AS clipsleft
                                FROM
                                (
                                        WITH
                                                PARAMS AS
                                                (
                                                        SELECT
                                                                /*+ materialize */
                                                                CAST((datetolongC(TO_CHAR((CAST(CURRENT_DATE AS DATE)),
                                                                'YYYY-MM-dd HH24:MI'),c.id)) AS BIGINT) AS FROMDATE,
                                                                CAST((datetolongC(TO_CHAR((CAST(CURRENT_DATE AS DATE) + INTERVAL '3 day' ), 'YYYY-MM-dd HH24:MI'),c.id)) AS BIGINT) AS TODATE,
                                                                c.id AS CENTER_ID
                                                        FROM
                                                                centers c
                                                )
                                        SELECT
                                                p.fullname AS MemberName,
                                                p.center AS MemberNumberCenter,
                                                p.id AS MemberNumberId,
                                                TO_CHAR(longtodateC(b.starttime,b.center),'YYYY-MM-DD') BookingDate,
                                                TO_CHAR(longtodateC(b.starttime,b.center),'HH24:MI') BookingTime,
                                                ac.name AS ActivityName,
                                                su.person_center AS StaffPersonCenter,
                                                su.person_id AS StaffPersonId,
                                                par.state AS parState,
                                                b.center AS BookingCenter
                                        FROM bookings b
                                        JOIN params
                                                ON params.CENTER_ID = b.center
                                        JOIN staff_usage su
                                                ON su.booking_center = b.center AND su.booking_id = b.id
                                        JOIN participations par
                                                ON b.center = par.booking_center AND b.id = par.booking_id
                                        JOIN persons p
                                                ON par.participant_center = p.center AND par.participant_id = p.id
                                        JOIN activity ac
                                                ON b.activity = ac.id AND ac.activity_type = 4
                                        WHERE
                                                (su.person_center, su.person_id) IN 
                                                (       
                                                        SELECT 
                                                                DISTINCT
                                                                p.center,
                                                                p.id
                                                        FROM persons p
                                                        JOIN person_staff_groups ps
                                                                ON ps.person_center = p.center AND ps.person_id = p.id
                                                        WHERE
                                                            ps.staff_group_id IN (1,2,3,4,5,6,1601)
                                                            AND p.status IN (0,1,2,3,6,9)
                                                            AND p.center IN (:center)
                                                )
                                                AND b.starttime >= params.fromdate
                                                AND b.starttime < params.todate
                                ) t1in
                                LEFT JOIN clipcards cc 
                                        ON cc.owner_center = t1in.MemberNumberCenter AND cc.owner_id = t1in.MemberNumberId
                                        AND cc.CLIPS_LEFT > 0
                                        AND cc.FINISHED = 0
                                        AND cc.CANCELLED = 0
                                        AND cc.BLOCKED = 0
                                LEFT JOIN clipcardtypes ct
                                        ON ct.center = cc.center AND ct.id = cc.id
                                LEFT JOIN products pd
                                        ON pd.center = ct.center AND pd.id = ct.id
                                LEFT JOIN product_and_product_group_link plink
                                        ON plink.product_center = pd.center AND plink.product_id = pd.id AND plink.product_group_id = 220
                                GROUP BY
                                        t1in.MemberName,
                                        t1in.MemberNumberCenter,
                                        t1in.MemberNumberId,
                                        t1in.BookingDate,
                                        t1in.BookingTime,
                                        t1in.ActivityName,
                                        t1in.StaffPersonCenter,
                                        t1in.StaffPersonId,
                                        t1in.parState,
                                        t1in.BookingCenter
                        ) t1
                        JOIN centers c ON c.ID = t1.BookingCenter
                ) t2
                GROUP BY
                        t2.StaffPersonCenter,
                        t2.StaffPersonId,
                        t2.BookingCenter,
                        t2.CenterName
        ) t3
) t4
GROUP BY
        t4.StaffPersonCenter,
        t4.StaffPersonId
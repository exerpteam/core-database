-- The extract is extracted from Exerp on 2026-02-08
-- https://clublead.atlassian.net/servicedesk/customer/portal/9/EC-4759

approved 8/2/22
WITH
    params AS MATERIALIZED
    (
        SELECT
            c.id   AS CENTERID,
            c.name AS center_name,
            cast(datetolongTZ(to_char(TO_date(:CheckIn_From,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS'), c.time_zone) as BIGINT) AS FROMDATE,
            cast(datetolongTZ(to_char(TO_date(:CheckIn_To,'YYYY-MM-DD HH24:MI:SS')+INTERVAL'1 DAYS','YYYY-MM-DD HH24:MI:SS'), c.time_zone)-1 as BIGINT) AS TODATE
        FROM
            centers c
        WHERE c.id IN (:Scope)
    ),
v_main AS
(
        SELECT
                t1.*,
                (CASE 
                        WHEN t1.granter_service = 'GlobalSubscription' 
                                THEN subprod.name
                        WHEN t1.granter_service = 'GlobalCard'
                                THEN clipprod.name
                        WHEN t1.granter_service = 'ReceiverGroup'
                                THEN 'Target Group'
                        WHEN t1.granter_service = 'Addon'
                                THEN mpr.cached_productname
                        WHEN t1.granter_service IS NOT NULL 
                                THEN 'Find Granter'
                        ELSE 
                                NULL
                END) AS PrivilegeGrantedBy
                
        FROM
        (
                SELECT
                    ch.id,
                    ch.checkin_center,
                    params.center_name,
                    CASE p.PERSONTYPE 
                        WHEN 0 THEN 'PRIVATE' WHEN 1 THEN 'STUDENT' WHEN 2 THEN 'STAFF' WHEN 3 THEN 'FRIEND' 
                        WHEN 4 THEN 'CORPORATE' WHEN 5 THEN 'ONEMANCORPORATE' WHEN 6 THEN 'FAMILY' WHEN 7 THEN 'SENIOR' 
                        WHEN 8 THEN 'GUEST' WHEN 9 THEN 'CHILD' WHEN 10 THEN 'EXTERNAL_STAFF' ELSE 'Undefined' 
                    END AS PersonType,
                    CASE ch.checkin_result 
                        WHEN 0 THEN 'Undefined' WHEN 1 THEN 'Access Granted' WHEN 2 THEN 'Presence Registered' WHEN 3 THEN 'Access Denied' ELSE 'Unknown'
                    END AS CheckInState,
                    to_char(longtodatec(ch.checkin_time,ch.checkin_center),'FMDay')  AS Weekday,
                    to_char(longtodatec(ch.checkin_time,ch.checkin_center),'MM/DD/YYYY') AS CheckinDate,
                    to_char(longtodatec(ch.checkin_time,ch.checkin_center),'HH24') || ' - ' || to_char(longtodatec(ch.checkin_time+3600000,ch.checkin_center),'HH24') AS CheckinHour,
                    CASE WHEN ch.checkin_center = p.center 
                        THEN 1 
                        ELSE 0 
                    END AS LocalVisits,
                    CASE WHEN ch.checkin_center <> p.center 
                        THEN 1 
                        ELSE 0 
                    END AS GuestVisits,    
                    1                    AS Visits,
                    p.center ||'p'||p.id AS PersonID,
                    p.external_id        AS ExternalID,
                    p.firstname          AS FirstName,
                    p.lastname           AS LastName,
                    CASE p.STATUS 
                        WHEN 0 THEN 'LEAD' WHEN 1 THEN 'ACTIVE' WHEN 2 THEN 'INACTIVE' WHEN 3 THEN 'TEMPORARYINACTIVE' 
                        WHEN 4 THEN 'TRANSFERRED' WHEN 5 THEN 'DUPLICATE' WHEN 6 THEN 'PROSPECT' WHEN 7 THEN 'DELETED' 
                        WHEN 8 THEN 'ANONYMIZED' WHEN 9 THEN 'CONTACT' ELSE 'Undefined' 
                    END AS PersonStatus,
                    to_char(longtodatec(ch.checkin_time,ch.checkin_center),'YYYY-MM-DD HH24:MI') AS PersonTime,
                    to_char(longtodatec(ch.checkout_time,ch.checkin_center),'YYYY-MM-DD HH24:MI') AS CheckoutTime,
                    CASE 
                        WHEN IDENTITY_METHOD = 1 THEN 'Barcode' WHEN IDENTITY_METHOD = 2 THEN 'MagneticCard' WHEN IDENTITY_METHOD = 4 THEN 'RFCard' 
                        WHEN IDENTITY_METHOD = 5 THEN 'Pin' WHEN IDENTITY_METHOD = 6 THEN 'AntiDrown' WHEN IDENTITY_METHOD = 7 THEN 'QRCode' 
                        WHEN IDENTITY_METHOD = 8 THEN 'ExternalSystem' ELSE 'Undefined' 
                    END AS IdentityMethod,
                    br.name AS BookingResourceName,
                    pg.granter_service,
                    pu.source_center,
                    pu.source_id,
                    pu.source_subid,
                    pu.state AS PrivilegeState,
                    att.start_time AS startTimeAttend,
					ch.checkin_failed_reason
                FROM checkins ch
                JOIN params
                        ON ch.checkin_center = params.centerid
                        AND ch.checkin_time BETWEEN params.FROMDATE AND params.TODATE        
                JOIN persons p
                        ON ch.person_center = p.center
                        AND ch.person_id = p.id
                LEFT JOIN chelseapiers.attends att
                        ON att.person_center = ch.person_center
                        AND att.person_id = ch.person_id
                        AND att.start_time >= ch.checkin_time - (10*1000) -- Take 10 seconds
                        AND 
                        (
                                ch.checkout_time IS NULL
                                OR
                                att.start_time < ch.checkout_time
                        )
                LEFT JOIN booking_resources br
                        ON att.booking_resource_center = br.center
                        AND att.booking_resource_id = br.id   
                LEFT JOIN chelseapiers.privilege_usages pu
                        ON pu.target_center = att.center
                        AND pu.target_id = att.id
                        AND pu.target_service = 'Attend'
                        AND pu.cancel_time IS NULL
                LEFT JOIN chelseapiers.privilege_grants pg
                        ON pg.id = pu.grant_id              
        ) t1
        LEFT JOIN chelseapiers.subscriptions s
                ON s.center = t1.source_center
                AND s.id = t1.source_id
                AND t1.granter_service = 'GlobalSubscription'
        LEFT JOIN chelseapiers.products subprod
                ON s.subscriptiontype_center = subprod.center
                AND s.subscriptiontype_id = subprod.id
        LEFT JOIN chelseapiers.clipcards c
                ON c.center = t1.source_center
                AND c.id = t1.source_id
                AND c.subid = t1.source_subid
                AND t1.granter_service = 'GlobalCard'
        LEFT JOIN chelseapiers.products clipprod
                ON c.center = clipprod.center
                AND c.id = clipprod.id
        LEFT JOIN chelseapiers.subscription_addon sa
                ON sa.id = t1.source_id
                AND t1.granter_service = 'Addon'
        LEFT JOIN chelseapiers.masterproductregister mpr
                ON mpr.id = sa.addon_product_id
),
v_pivot AS
(
        SELECT
                v_main.*,
                LEAD(BookingResourceName, 1) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName2,
                LEAD(granter_service, 1) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service2,
                LEAD(BookingResourceName, 1) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy2,
                LEAD(BookingResourceName, 2) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName3,
                LEAD(granter_service, 2) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service3,
                LEAD(BookingResourceName, 2) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy3,
                LEAD(BookingResourceName, 3) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName4,
                LEAD(granter_service, 3) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service4,
                LEAD(BookingResourceName, 3) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy4,
                LEAD(BookingResourceName, 4) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName5,
                LEAD(granter_service, 4) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service5,
                LEAD(BookingResourceName, 4) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy5,
                LEAD(BookingResourceName, 5) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName6,
                LEAD(granter_service, 5) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service6,
                LEAD(BookingResourceName, 5) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy6,
                LEAD(BookingResourceName, 6) OVER (PARTITION BY id ORDER BY startTimeAttend) AS BookingResourceName7,
                LEAD(granter_service, 6) OVER (PARTITION BY id ORDER BY startTimeAttend) AS granter_service7,
                LEAD(BookingResourceName, 6) OVER (PARTITION BY id ORDER BY startTimeAttend) AS PrivilegeGrantedBy7,
                ROW_NUMBER() OVER (PARTITION BY id ORDER BY startTimeAttend) AS ADDONSEQ
        FROM 
                v_main
)
SELECT
        v_pivot.id AS "CheckinId",
        v_pivot.checkin_center AS "Center ID",
        v_pivot.center_name AS "Center Name",
        v_pivot.PersonType AS "Person Type",
        v_pivot.CheckInState AS "Check-In State",
		v_pivot.checkin_failed_reason AS "Check-In Failed Reason",
        v_pivot.Weekday AS "Weekday",
        v_pivot.CheckinDate AS "Date",
        v_pivot.CheckinHour AS "Hour",
        v_pivot.LocalVisits AS "Local Visits",
        v_pivot.GuestVisits AS "Guest Visits",  
        v_pivot.Visits AS "Visits",               
        v_pivot.PersonID AS "PersonID",
        v_pivot.ExternalID AS "ExternalID",
        v_pivot.FirstName AS "First Name",
        v_pivot.LastName AS "Last Name",
        v_pivot.PersonStatus AS "Person Status",
        v_pivot.PersonTime AS "Person Time",
        v_pivot.IdentityMethod AS "Identity Method",
        v_pivot.BookingResourceName AS "Booking Resource Name 1",
        v_pivot.granter_service AS "Granter Service 1",
        v_pivot.PrivilegeGrantedBy AS "Privilege Granted By 1",
        v_pivot.BookingResourceName2 AS "Booking Resource Name 2",
        v_pivot.granter_service2 AS "Granter Service 2",
        v_pivot.PrivilegeGrantedBy2 AS "Privilege Granted By 2",
        v_pivot.BookingResourceName3 AS "Booking Resource Name 3",
        v_pivot.granter_service3 AS "Granter Service 3",
        v_pivot.PrivilegeGrantedBy3 AS "Privilege Granted By 3",
        v_pivot.BookingResourceName4 AS "Booking Resource Name 4",
        v_pivot.granter_service4 AS "Granter Service 4",
        v_pivot.PrivilegeGrantedBy4 AS "Privilege Granted By 4",
        v_pivot.BookingResourceName5 AS "Booking Resource Name 5",
        v_pivot.granter_service5 AS "Granter Service 5",
        v_pivot.PrivilegeGrantedBy5 AS "Privilege Granted By 5",
        v_pivot.BookingResourceName6 AS "Booking Resource Name 6",
        v_pivot.granter_service6 AS "Granter Service 6",
        v_pivot.PrivilegeGrantedBy6 AS "Privilege Granted By 6",
        v_pivot.BookingResourceName7 AS "Booking Resource Name 7",
        v_pivot.granter_service7 AS "Granter Service 7",
        v_pivot.PrivilegeGrantedBy7 AS "Privilege Granted By 7"
FROM
        v_pivot
WHERE
        ADDONSEQ = 1
;

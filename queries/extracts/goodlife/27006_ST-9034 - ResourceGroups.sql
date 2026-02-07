WITH PARAMS AS
(
        SELECT
                datetolongC(to_char(to_date(getcentertime(c.id),'YYYY-MM-DD HH24:MI:SS')+8,'YYYY-MM-DD HH24:MI:SS'),c.ID) AS today,
                c.ID AS centerId
        FROM
                centers c
),
eligibles AS
(
        SELECT

                --count(*)
                --DISTINCT bru.state
                DISTINCT 
                        a.id AS Old_ActiviyID,
                        a.name  as ActivityName,
                        arc.booking_resource_group_id AS old_booking_resource_group_id,
                        brg.name AS old_booking_resource_group_name,
                        br.NAME AS ResourceName,
                        br.CENTER AS BookingCenter,
                        (CASE
                                WHEN a.ID=162	THEN 9630
WHEN a.ID=24	THEN 9622
WHEN a.ID=33	THEN 10602
WHEN a.ID=26	THEN 9631
WHEN a.ID=1018	THEN 9623
WHEN a.ID=1004	THEN 9637
WHEN a.ID=1005	THEN 9632
WHEN a.ID=4601	THEN 9625
WHEN a.ID=4203	THEN 9610
WHEN a.ID=1010	THEN 9627
WHEN a.ID=1009	THEN 9634
WHEN a.ID=1011	THEN 9638
WHEN a.ID=5803	THEN 9639
WHEN a.ID=8802	THEN 9629
WHEN a.ID=4201	THEN 9649
WHEN a.ID=4202	THEN 9619
WHEN a.ID=1406	THEN 9624
WHEN a.ID=6802	THEN 9611
WHEN a.ID=4209	THEN 9609
WHEN a.ID=76	THEN 9626
WHEN a.ID=72	THEN 9633
WHEN a.ID=56	THEN 9640
WHEN a.ID=60	THEN 9620
WHEN a.ID=4211	THEN 9612
WHEN a.ID=5201	THEN 9613
WHEN a.ID=4212	THEN 9644
WHEN a.ID=4213	THEN 9645
WHEN a.ID=5802	THEN 9641
WHEN a.ID=6401	THEN 9621
WHEN a.ID=1023	THEN 9635
WHEN a.ID=8801	THEN 9628
WHEN a.ID=4218	THEN 9646
WHEN a.ID=4214	THEN 9614
WHEN a.ID=4215	THEN 10002
WHEN a.ID=6602	THEN 9615
WHEN a.ID=6803	THEN 9617
WHEN a.ID=4219	THEN 9648
WHEN a.ID=4220	THEN 9618
WHEN a.ID=79	THEN 9636
ELSE 0
END) newActivityId
        FROM goodlife.activity a
        JOIN goodlife.activity_resource_configs arc ON arc.ACTIVITY_ID = a.ID
        JOIN goodlife.bookings b ON a.id = b.activity
        JOIN PARAMS ON params.centerId = b.center
        JOIN goodlife.booking_resource_usage bru ON bru.booking_center = b.center AND bru.booking_id = b.id
        JOIN goodlife.booking_resources br ON bru.booking_resource_center = br.center AND bru.booking_resource_id = br.id
        JOIN goodlife.booking_resource_groups brg ON brg.ID = arc.booking_resource_group_id
        --JOIN goodlife.booking_resource_configs brc ON br.center = brc.booking_resource_center AND br.id = brc.booking_resource_id
        WHERE
                b.activity IN (162,24,33,26,1018,1004,1005,4601,4203,1010,1009,1011,5803,8802,4201,4202,1406,6802,4209,76,
                72,56,60,4211,5201,4212,4213,5802,6401,1023,8801,4218,4214,4215,6602,6803,4219,4220,79)  
                AND b.starttime > params.today
                AND b.state != 'CANCELLED'
                AND bru.state != 'CANCELLED'
)
SELECT eligibles.*
FROM eligibles
LEFT JOIN
(
        SELECT
                DISTINCT
                a.id,
                a.name,
                br.name AS brname,
                br.center as BookingCenter
        FROM goodlife.activity a
        JOIN goodlife.activity_resource_configs arc ON arc.ACTIVITY_ID = a.ID
        JOIN goodlife.booking_resource_groups brg ON brg.id = arc.booking_resource_group_id
        JOIN goodlife.booking_resource_configs brc ON brc.group_id = brg.id
        JOIN goodlife.booking_resources br ON br.center = brc.booking_resource_center AND br.id = brc.booking_resource_id
        WHERE
                a.ID IN (9630,9622,10602,9631,9623,9637,9632,9625,9610,9627,9634,9638,9639,9629,9649,9619,9624,9611,9609,9626,
                9633,9640,9620,9612,9613,9644,9645,9641,9621,9635,9628,9646,9614,10002,9615,9617,9648,9618,9636)
) t1 ON eligibles.newactivityid=t1.id AND eligibles.BookingCenter = t1.BookingCenter AND eligibles.ResourceName = t1.brname
WHERE
        t1.id IS NULL
        order by 5,6
WITH
        params AS
                (
                SELECT
                        /*+ materialize */
                        to_date(getcentertime(c.id), 'YYYY-MM-DD')      AS cutDate
                        ,c.ID                                           AS center_id                  
                FROM
                        CENTERS c
                JOIN
                        COUNTRIES co
                ON
                        c.COUNTRY = co.ID
                ),
        sanction_late_cancel AS
                (
                SELECT
                        TO_CHAR(CAST((longtodatec(b.starttime,b.center)) AS date),'YYYY-MM') as start_yyyy_mm
                        ,CAST((longtodatec(b.starttime,b.center)) AS date) AS start_time
                        ,part.cancelation_reason
                        ,part.participant_center
                        ,part.participant_id
                        ,b.starttime
                        ,part.center
                        ,part.id
                FROM
                        bookings b
                JOIN
                        participations part
                        ON part.booking_center = b.center
                        AND part.booking_id = b.id
                        AND part.state = 'CANCELLED'
                        --AND part.cancelation_reason = 'USER_CANCEL_LATE'
                JOIN
                        params
                        ON params.center_id = b.center        
                --WHERE
                --        CAST((longtodatec(b.starttime,b.center)) AS date) = params.cutDate +1 --replaced by -7*/
                ),
        previous_cancel AS
                (
                SELECT
                        b.starttime
                        ,part.cancelation_reason
                        ,part.participant_center
                        ,part.participant_id
                FROM
                        bookings b
                JOIN
                        participations part
                        ON part.booking_center = b.center
                        AND part.booking_id = b.id
                        AND part.state = 'CANCELLED'
                        --AND part.cancelation_reason = 'USER_CANCEL_LATE'   
                JOIN
                        sanction_late_cancel slc
                        ON slc.participant_center = part.participant_center
                        AND slc.participant_id = part.participant_id
                        AND b.starttime < slc.starttime                        
                WHERE
                        TO_CHAR(CAST((longtodatec(b.starttime,b.center)) AS date),'YYYY-MM') = TO_CHAR(CAST((longtodatec(slc.starttime,b.center)) AS date),'YYYY-MM')
                        AND
                        slc.center||'part'||slc.id != part.center||'part'||part.id
                ),
        count_previous_cancel AS
                (                   
                SELECT
                        count(*) as counting
                        ,participant_center
                        ,participant_id
                FROM
                        previous_cancel
                GROUP BY
                        participant_center
                        ,participant_id                        
                )

SELECT
        slc.participant_center||'p'||slc.participant_id AS "PERSONKEY"
        ,*
FROM
        sanction_late_cancel slc
JOIN
        count_previous_cancel cpc
        ON slc.participant_center = cpc.participant_center
        AND slc.participant_id = cpc.participant_id
WHERE
        slc.start_time >= :from_date
		AND slc.start_time <= :to_date
		
  
                                   
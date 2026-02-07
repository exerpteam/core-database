WITH
    params AS
    (
        SELECT
            /*+ materialize */
			$$FreeFromDate$$ AS StartDate,
            $$FreeToDate$$ AS EndDate,
            ID                          AS Center,
            'COVID-19 '|| $$FreeFromDate$$ || ' - ' || $$FreeToDate$$  AS coment
		FROM
			CENTERS
		WHERE 
		    country = 'IT'
    )

select 
--floor((row_number() over(order by b.center,b.id,b.sub_start_date))/1000)+1 as threadnumber, 
--b.center, b.id, 
b.PersonId, b.center ||'ss'|| b.id as SubscriptionId, 
to_char(b.sub_end_date + 1,'YYYY-MM-DD') as Free_Day_start, 
(CASE
	       WHEN 
	               b.sub_end_date <= params.EndDate THEN 
	                       to_char((b.sub_end_date + interval '1' day * (b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod)) + (params.EndDate - b.sub_end_date), 'YYYY-MM-DD')
	               ELSE to_char(b.sub_end_date + interval '1' day * (b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod), 'YYYY-MM-DD')
        END) as Free_day_end 
--, b.coment
, b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod as Free_Days
, b.sub_start_date , b.sub_end_date , b.orig_end_date


from (    

select --a.center - mod(a.center,20) as threadgroup, 
 distinct a.center, a.id, a.start_date as sub_start_date, a.end_date as sub_end_date, a.orig_end_date, a.given_covid19_freeday_inperiod, params.coment
,a.PersonId
,
        -- days already given in a freeze in the period

        coalesce((SELECT
            sum(least(srd2.end_date,a.fullfreezeend) - greatest(srd2.start_date,a.fullfreezestart) + 1)
        FROM
            subscription_freeze_period srd2
        WHERE
            srd2.subscription_center = a.center
            AND srd2.subscription_id = a.id
            AND srd2.state = 'ACTIVE'
            AND srd2.start_date <= a.fullfreezeend
            AND srd2.end_date >= a.fullfreezestart), 0) as existing_freeze_days_in_period,
        
        
        -- max theoretical days to give     
        (a.fullfreezeend - a.fullfreezestart +1) as free_theoric_length
from (    
    
SELECT
    s.center, s.id,
    s.owner_center || 'p' || s.owner_id AS PersonId,
    s.center || 'ss' || s.id            AS SubscriptionId,
    s.start_date,
    s.end_date,
    coalesce(exist_free_days.orig_end_date, s.end_date) as orig_end_date,
    least(coalesce(exist_free_days.orig_end_date, s.end_date),params.EndDate) as fullfreezeend, 
    greatest(s.start_date, params.StartDate) as fullfreezestart,
    coalesce(exist_free_days.given_free_days, 0) as given_covid19_freeday_inperiod
    
FROM
    subscriptions s
    
    -- days given as COVID-19 free period and get orig_end_date
LEFT JOIN
    (
        SELECT
            s3.center, s3.id,  (s3.end_date - interval '1' day * sum(srd3.end_date - srd3.start_date + 1)) as orig_end_date, sum(srd3.end_date - srd3.start_date + 1) as given_free_days
        FROM
            subscriptions s3 join 
            subscription_reduced_period srd3
            on srd3.subscription_center = s3.center
            and srd3.subscription_id = s3.id
        JOIN 
			params
		ON
			params.center = s3.center
        WHERE
            srd3.state = 'ACTIVE'
            AND srd3.text = params.coment
        group by 
            s3.center,
            s3.id,
            s3.end_date
    ) exist_free_days on     
            exist_free_days.center = s.center
            AND exist_free_days.id = s.id


JOIN
    params
ON
	params.center = s.center
JOIN
    subscriptiontypes st
ON
    st.center = s.SUBSCRIPTIONTYPE_CENTER
    AND st.id = s.SUBSCRIPTIONTYPE_id
    AND st.st_type = 0
LEFT JOIN subscriptions s_prev on s_prev.extended_to_center = s.center and s_prev.extended_to_id = s.id and s.start_date > params.StartDate     
WHERE
    s.center = params.Center
	
	AND s.CENTER in (:Scope)
    -- Look at only ACTIVE AS PER TODAY 	
    AND s.state in (2,4,8)
	
    AND s.END_DATE >= PARAMS.StartDate 
    AND s.START_DATE <= PARAMS.EndDate 
	
	/* exclude subscription extended in the free period: TODO handle manually */
    AND NOT (s.state in (2,5) AND s.extended_to_center is not null AND coalesce(exist_free_days.orig_end_date, s.end_date) <= PARAMS.EndDate) 
    AND s_prev.center is null
	
	
            
) a 
join params
ON params.center = a.center

) b 
join params
ON params.center = b.center
where (b.free_theoric_length - b.existing_freeze_days_in_period - b.given_covid19_freeday_inperiod) > 0
--and b.id < 10



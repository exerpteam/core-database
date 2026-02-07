WITH
    /* Get all relevant bookings */
    v_init_bookings AS
    (
        SELECT
            bk.center,
            bk.id,
            bk.activity,
            bk.starttime,
            bk.stoptime,
            bk.name,
            bk.state
        FROM
            BOOKINGS bk
        WHERE
            bk.center IN ($$Scope$$)
            AND bk.STARTTIME >= $$FromDate$$
            AND bk.STARTTIME < $$ToDate$$ + (1000*60*60*24)
    )
    /* Get activity hieracrhy - with root values and hierarchy levels for each activity */
    ,
    v_activity AS
    (
        SELECT
            act.id,
            act.activity_group_id,
            act.scope_type,
            act.scope_id,
            connect_by_root act.id                act_root_id,
            connect_by_root act.activity_group_id act_root_group_id,
            level                                 act_node_level
        FROM
            ACTIVITY act START WITH act.top_node_id IS NULL CONNECT BY PRIOR act.id = act.top_node_id
    )
    /* For each booking, find all activities that exist as top node level or as an area override.
    Then for each activity, find areas at any level that come udner the activities scope *
    Give the activity with no more area branches in its scope the highest rank */
    ,
    v_bk_act_area_override AS
    (
        SELECT
            bk.*,
            act.id                                                                         act_override_id,
            NVL(act.activity_group_id, act_root_group_id)                                  activity_group_id,
            a.id                                                                           area_id,
            rank() over (partition BY act.act_root_id, a.id ORDER BY act_node_level DESC ) act_area_finallevel
        FROM
            v_init_bookings bk,
            v_activity act ,
            areas a
        WHERE
            act.act_root_id = bk.activity
            AND NVL(act.scope_type, 'Z') IN ('A',
                                             'G',
                                             'T') START WITH a.id = act.scope_id CONNECT BY PRIOR a.id = a.parent
            AND PRIOR act.id = act.id
            AND PRIOR bk.center = bk.center
            AND PRIOR bk.id = bk.id
    )
    /* Find the activity with no more area branches for the booking center */
    ,
    v_bk_act_area_centers_override AS
    (
        SELECT
            baao.*,
            ac.center center_id
        FROM
            v_bk_act_area_override baao
        JOIN
            area_centers ac
        ON
            baao.area_id = ac.area
            AND ac.center = baao.center
        WHERE
            baao.act_area_finallevel = 1
    )
    /* Find activity overrides made at center level */
    ,
    v_bk_act_center_override AS
    (
        SELECT
            bk.*,
            act.id act_override_id,
            act.activity_group_id,
            NULL         area_id,
            0            act_area_finallevel,
            act.scope_id center_id
        FROM
            v_init_bookings bk,
            v_activity act
        WHERE
            act.act_root_id = bk.activity
            AND NVL(act.scope_type, 'Z') = 'C'
            AND bk.center = act.scope_id
    )
    /* Use activity with center level override if available else most relevant area level override for the booking center */
    ,
    v_bookings AS
    (
        SELECT
            *
        FROM
            (
                SELECT
                    bk1.*,
                    rank() over (partition BY bk1.center, bk1.id, bk1.activity, bk1.center_id ORDER BY bk1.act_area_finallevel ASC) act_center_finallevel
                FROM
                    (
                        SELECT
                            *
                        FROM
                            v_bk_act_area_centers_override
                        UNION
                        SELECT
                            *
                        FROM
                            v_bk_act_center_override ) bk1 ) bk
        WHERE
            bk.act_center_finallevel = 1
    )
SELECT DISTINCT
    TO_CHAR(longtodate(bk.STARTTIME), 'YYYY-MM-DD') b_date,
    TO_CHAR(longtodate(bk.STOPTIME), 'MON')         b_month,
    TO_CHAR(longtodate(bk.STOPTIME), 'DY')          b_day,
    TO_CHAR(longtodate(bk.STARTTIME), 'HH24:MI')    startTime,
    TO_CHAR(longtodate(bk.STOPTIME), 'HH24:MI')     endTime,
    bk.NAME                                         activityname,
    actgr.NAME                                      activitygroup,
    stfg.NAME                                       staffgroup,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.CENTER || 'p' || ins.ID
    END instructorId,
    CASE
        WHEN ins.CENTER IS NULL
        THEN NULL
        ELSE ins.FIRSTNAME || ' ' || ins.LASTNAME
    END      instructorName,
    bk.STATE bookingState,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN par.PARTICIPANT_CENTER || 'p' || par.PARTICIPANT_ID
        ELSE NULL
    END participantId,
    CASE
        WHEN par.CENTER IS NOT NULL
        THEN per.FIRSTNAME || ' ' || per.LASTNAME
        ELSE NULL
    END       participantName,
    par.STATE participationState,
    par.CANCELATION_REASON,
    psg.SALARY staffSalary,
    CASE
        WHEN psg.SALARY IS NOT NULL
        THEN ROUND( (extract(MINUTE FROM(longtodate(bk.STOPTIME)- longtodate (bk.STARTTIME)) ) / 60) + extract(HOUR FROM (longtodate (bk.STOPTIME)- longtodate(bk.STARTTIME) )),2) * psg.SALARY
        ELSE NULL
    END                wages,
    per.address1       AS "Member  Address",
    per.zipcode        AS "Member  Zip Code",
    per.city           AS "Member  City",
    per_email.txtvalue AS "Member  Email-address",
    ins.address1       AS "Instructor Address",
    ins.zipcode        AS "Instructor Zip Code",
    ins.city           AS "Instructor City",
    ins_email.txtvalue AS "Instructor Email-address",
    pc.Name AS "PT Product",
   CASE WHEN s.SUBSCRIPTION_PRICE is null 
	   THEN
		 case when t2.transferno > 0
            then ROUND(il.net_amount /  il.QUANTITY, 2)
            else ROUND(il.net_amount /  t1.invtotal, 2)
         end 
       ELSE CASE WHEN il.NET_AMOUNT <> 0
          THEN 
    		 case when t2.transferno > 0
              then ROUND(il.net_amount / il.QUANTITY, 2)
              else ROUND(il.net_amount / t1.invtotal, 2)
         end 
       ELSE 
          ROUND(s.SUBSCRIPTION_PRICE / (1+prvat.rate),2)
       END
    END AS "PT Product Price excl VAT",  
    cc.CLIPS_INITIAL "PT product clips amount",
    longtodateC(inv.TRANS_TIME, inv.CENTER) "PT product sales date"
FROM
    v_bookings bk
JOIN
    ACTIVITY_GROUP actgr
ON
    bk.ACTIVITY_GROUP_ID = actgr.ID
LEFT JOIN
    ACTIVITY_STAFF_CONFIGURATIONS staffconfig
ON
    staffconfig.ACTIVITY_ID = bk.act_override_id -- uses bottom node if available else top node
LEFT JOIN
    STAFF_GROUPS stfg
ON
    stfg.ID = staffconfig.STAFF_GROUP_ID
LEFT JOIN
    PARTICIPATIONS par
ON
    par.BOOKING_CENTER = bk.CENTER
    AND par.BOOKING_ID = bk.ID
LEFT JOIN
    STAFF_USAGE st
ON
    bk.center = st.BOOKING_CENTER
    AND bk.id = st.BOOKING_ID
    AND st.state = 'ACTIVE'
LEFT JOIN
    PERSONS ins
ON
    st.PERSON_CENTER = ins.CENTER
    AND st.PERSON_ID = ins.ID
LEFT JOIN
    PERSON_EXT_ATTRS ins_email
ON
    ins.center=ins_email.PERSONCENTER
    AND ins.id=ins_email.PERSONID
    AND ins_email.name='_eClub_Email'
LEFT JOIN
    PERSONS per
ON
    par.PARTICIPANT_CENTER = per.CENTER
    AND par.PARTICIPANT_ID = per.ID
LEFT JOIN
    PERSON_EXT_ATTRS per_email
ON
    per.center=per_email.PERSONCENTER
    AND per.id=per_email.PERSONID
    AND per_email.name='_eClub_Email'
LEFT JOIN
    PERSON_STAFF_GROUPS psg
ON
    psg.PERSON_CENTER = ins.CENTER
    AND psg.PERSON_ID = ins.ID
    AND psg.STAFF_GROUP_ID = stfg.ID
    AND NVL(psg.SALARY, 0) <> 0
    AND psg.SCOPE_TYPE = 'C'
    AND psg.SCOPE_ID = bk.center
LEFT JOIN 
    PRIVILEGE_USAGES pu
ON
    pu.PERSON_CENTER = per.CENTER
    AND pu.PERSON_ID = per.ID
    AND pu.PRIVILEGE_TYPE = 'BOOKING' 
    AND pu.TARGET_SERVICE = 'Participation' 
    AND pu.TARGET_CENTER = par.CENTER 
    AND pu.TARGET_ID = par.ID
LEFT JOIN
    CLIPCARDS cc
ON
    pu.SOURCE_CENTER = cc.CENTER
    AND pu.SOURCE_ID = cc.ID
    AND pu.SOURCE_SUBID = cc.SUBID
LEFT JOIN
    PRODUCTS pc
ON
    pc.CENTER = cc.CENTER
    AND pc.ID = cc.ID
LEFT JOIN
    INVOICE_LINES_MT il
ON
    IL.CENTER = cc.INVOICELINE_CENTER 
    AND IL.ID = cc.INVOICELINE_ID 
    AND IL.SUBID = cc.INVOICELINE_SUBID
LEFT JOIN
(
SELECT il.CENTER, il.ID, il.subid, count(*) as invtotal
  FROM 
      CLIPCARDS cc
  JOIN
     INVOICE_LINES_MT il
  ON 
     cc.INVOICELINE_CENTER = il.CENTER
     AND cc.INVOICELINE_ID = il.ID
     AND cc.INVOICELINE_SUBID = il.SUBID
  GROUP BY il.CENTER, il.ID, il.subid
 ) t1
ON  
  t1.CENTER = il.CENTER
  AND t1.ID = il.ID
  AND t1.SUBID = il.SUBID
LEFT JOIN
(
select ccu.CARD_CENTER, ccu.CARD_ID, ccu.CARD_SUBID, count(*) as transferno
 from CARD_CLIP_USAGES ccu
  WHERE ccu.TYPE in ('TRANSFER_TO','TRANSFER_FROM')
  group by ccu.CARD_CENTER, ccu.CARD_ID, ccu.CARD_SUBID
)t2
ON 
  t2.card_center = cc.center
  and t2.card_id = cc.id
  and t2.card_subid = cc.subid	
LEFT JOIN
    INVOICES inv
ON
    il.CENTER = inv.CENTER
    AND il.ID = inv.ID
LEFT JOIN  
    PRIVILEGE_USAGES pu2
ON    
    pu2.PERSON_CENTER = per.CENTER
    AND pu2.PERSON_ID = per.ID
    AND pu2.PRIVILEGE_TYPE = 'PRODUCT' 
    and pu2.target_center = IL.CENTER
    and pu2.target_id = IL.ID
    and pu2.target_subid = IL.SUBID
LEFT JOIN
   PRIVILEGE_GRANTS pg
ON
    pg.id = pu2.GRANT_ID  
    AND pg.granter_service = 'GlobalSubscription'
LEFT JOIN  
    SUBSCRIPTIONS s
ON
    pu2.SOURCE_CENTER = s.CENTER
    AND pu2.SOURCE_ID = s.ID
LEFT JOIN
    (
    SELECT pr.CENTER, pr.ID, vt.rate
    FROM PRODUCTS pr
    JOIN
       PRODUCT_ACCOUNT_CONFIGURATIONS pag 
    ON
       pr.PRODUCT_ACCOUNT_CONFIG_ID = pag.ID
       --AND pr.blocked = 0
       --AND pag.blocked = 0
    JOIN
       ACCOUNTS acc
    ON
       acc.GLOBALID = pag.SALES_ACCOUNT_GLOBALID
       AND acc.CENTER = pr.CENTER
       --AND acc.blocked = 0
    JOIN
       ACCOUNT_VAT_TYPE_GROUP avtg
    ON
       avtg.account_center = acc.center
       AND avtg.account_id = acc.id
    JOIN 
       VAT_TYPES vt
    ON 
       vt.GLOBALID =  avtg.GLOBAL_ID
       AND vt.CENTER = pr.CENTER
   ) 
   prvat
   ON
     prvat.center = s.SUBSCRIPTIONTYPE_CENTER
     AND prvat.id = s.SUBSCRIPTIONTYPE_ID     
WHERE
    par.state = 'PARTICIPATION'

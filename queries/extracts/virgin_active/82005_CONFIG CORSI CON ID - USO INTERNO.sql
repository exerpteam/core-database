SELECT
         act.ID,
     -- act.SCOPE_TYPE,
    -- act.SCOPE_ID,
     act.NAME,
         act.EXTERNAL_ID,
   -- act.STATE,
    -- act.AVAILABILITY,
     CASE act.ACTIVITY_TYPE WHEN 1 THEN 'General' WHEN 2 THEN 'Class' WHEN 3 THEN 'resourceBooking' WHEN 4 THEN 'staffBooking' WHEN 6 THEN 'staffAvailability' WHEN 7 THEN 'resourceAvailability' WHEN 8 THEN 'childCare' END ACTIVITY_TYPE,
     ag.NAME Activity_group_name,
     ag.ID activity_group_id,
    cg.NAME colour_group_name,
	cg.id id_colour,
	cg.colour,
   --  COALESCE(btc.NAME ,btc.NAME ,'None') TIME_CONFIG_NAME,
   --  act.ENERGY_CONSUMPTION_KCAL_HOUR,
   --  act.DESCRIPTION,
    -- act.MAX_PARTICIPANTS,
   --  act.MAX_WAITING_LIST_PARTICIPANTS,
   --  act.ALLOW_RECURRING_BOOKINGS Recurring_perticipations,
    -- bpg.NAME Access_Group_Name,
   --  pc.PRIVILEGE_AT_SHOWUP_CLIENT,
    -- pc.PRIVILEGE_AT_SHOWUP_KIOSK,
  --   pc.PRIVILEGE_AT_SHOWUP_WEB,
   --  brg.NAME resource_group,
     --arc.OPTIONAL resource_optional --removed due to ES-24236
     act.DURATION_LIST AS "allowedDurations"
    -- act.REQUIRES_PLANNING,
    -- asconf.MINIMUM_STAFFS,
    -- asconf.MAXIMUM_STAFFS,
   --  sg.NAME staff_group
 FROM
     ACTIVITY act
 LEFT JOIN ACTIVITY_GROUP ag
 ON
     ag.id = act.ACTIVITY_GROUP_ID
 LEFT JOIN COLOUR_GROUPS cg
 ON
     cg.ID = act.COLOUR_GROUP_ID
 LEFT JOIN ACTIVITY_STAFF_CONFIGURATIONS asconf
 ON
     asconf.ACTIVITY_ID = act.ID
 LEFT JOIN STAFF_GROUPS sg
 ON
     sg.ID = asconf.STAFF_GROUP_ID
 LEFT JOIN BOOKING_TIME_CONFIGS btc
 ON
     btc.ID = act.TIME_CONFIG_ID
 LEFT JOIN ACTIVITY_RESOURCE_CONFIGS arc
 ON
     arc.ACTIVITY_ID = act.ID
 LEFT JOIN BOOKING_RESOURCE_GROUPS brg
 ON
     brg.ID = arc.BOOKING_RESOURCE_GROUP_ID
 LEFT JOIN PARTICIPATION_CONFIGURATIONS pc
 ON
     pc.ACTIVITY_ID = act.ID
     and pc.NAME in ('Class','Participants')
 LEFT JOIN BOOKING_PRIVILEGE_GROUPS bpg
 ON
     bpg.ID = pc.ACCESS_GROUP_ID
 WHERE
     act.STATE = 'ACTIVE'
AND act.SCOPE_ID = '24'
 
SELECT 
            c.id as "Center ID",
            c.shortname as "Center Name",
            cl.name as "Client Name",
            d.name as "Device Name",
            g.name as "Gate Name",
            up.name as "Access Point",
            cl.type as "Device Type"
            



FROM centers c

JOIN clients cl ON c.id = cl.center

JOIN devices d ON cl.id = d.client

JOIN gates g ON d.id = g.device_id AND c.id = g.center

JOIN usage_point_resources upr ON upr.gate_center = g.center AND upr.gate_id = g.id

join usage_points up on up.center = upr.usage_point_center and up.id = upr.usage_point_id

WHERE cl.state = 'ACTIVE' --AND NOT d.name IN ('turnstilesecuritysystemsinc.gatecontroller','virtual turnstiles','virtual - turnstilesecuritysystemsinc.','Virtual - turnstilesecuritysystemsinc')

      SELECT
            c.id as "Club ID Exerp",
            cea1.txt_value as "Delegation ID", 
            c.name as "Exerp name", 
            c.web_name as "Web name",
            c.city as "City",
            c.startupdate as "Startup date",
            cea2.txt_value as "CenterAvailableOnWebFrom", 
            cea3.txt_value as "ClubLegalGroup"

       FROM
            centers c
        LEFT JOIN center_ext_attrs cea1 ON cea1.center_id = c.id AND cea1.name = 'IdDelegacion'
        LEFT JOIN center_ext_attrs cea2 ON cea2.center_id = c.id AND cea2.name = 'CenterAvailableOnWebFrom'
        LEFT JOIN center_ext_attrs cea3 ON cea3.center_id = c.id AND cea3.name = 'ClubLegalGroup'
        ORDER BY c.id 
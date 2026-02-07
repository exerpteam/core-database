CREATE TABLE 
    campaign_codes 
    ( 
        id int4 NOT NULL, 
        campaign_id int4, 
        campaign_type text(2147483647) NOT NULL, 
        code          text(2147483647) NOT NULL, 
        creation_time int8 NOT NULL, 
        usage_time int8, 
        usage_count int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id) 
    );

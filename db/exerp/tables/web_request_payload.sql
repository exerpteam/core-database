CREATE TABLE 
    web_request_payload 
    ( 
        id int4 NOT NULL, 
        web_request_type VARCHAR(30) NOT NULL, 
        reference_center int4 NOT NULL, 
        reference_id int4 NOT NULL, 
        reference_subid int4, 
        payload bytea NOT NULL, 
        send_counter int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (id) 
    );

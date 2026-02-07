CREATE TABLE 
    jbm_msg_ref 
    ( 
        message_id int8 NOT NULL, 
        channel_id int8 NOT NULL, 
        transaction_id int8, 
        STATE bpchar(1), 
        ord int8, 
        page_ord int8, 
        delivery_count int4, 
        sched_delivery int8, 
        PRIMARY KEY (message_id, channel_id) 
    );

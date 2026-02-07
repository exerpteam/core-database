CREATE TABLE 
    push_messages 
    ( 
        id int4 NOT NULL, 
        receiver_center int4 NOT NULL, 
        receiver_id int4 NOT NULL, 
        template_id int4, 
        template_type int4, 
        sent_time int8 NOT NULL, 
        push_target_id int4, 
        subject       VARCHAR(500), 
        response_code VARCHAR(50), 
        error_message VARCHAR(500), 
        mimetype      VARCHAR(200), 
        mimevalue bytea, 
        s3bucket VARCHAR(64), 
        s3key    VARCHAR(1024), 
        PRIMARY KEY (id) 
    );

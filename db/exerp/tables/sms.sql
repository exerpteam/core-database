CREATE TABLE 
    sms 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        reference_id int4, 
        message_center int4, 
        message_id int4, 
        message_sub_id int4, 
        ack_code text(2147483647), 
        ack_text text(2147483647), 
        STATE int4 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT sms_to_message_fk FOREIGN KEY (message_center, message_id, message_sub_id) 
        REFERENCES "exerp"."messages" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

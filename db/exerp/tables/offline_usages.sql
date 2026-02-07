CREATE TABLE 
    offline_usages 
    ( 
        id int4 NOT NULL, 
        offline_usage_packet_id int4 NOT NULL, 
        center int4 NOT NULL, 
                      TIMESTAMP int8 NOT NULL, 
        card_identity text(2147483647), 
        card_identity_method int4 NOT NULL, 
        pincode text(2147483647), 
        reader_device_id int4 NOT NULL, 
        reader_device_sub_id text(2147483647), 
        person_center int4, 
        person_id int4, 
        usage_point_action_center int4, 
        usage_point_action_id int4, 
        client_id int4 NOT NULL, 
        event_type int4 DEFAULT 0 NOT NULL, 
        device_part int4, 
        PRIMARY KEY (id), 
        CONSTRAINT offline_usage_to_packet_fk FOREIGN KEY (offline_usage_packet_id) REFERENCES 
        "exerp"."offline_usage_packets" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

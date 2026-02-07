CREATE TABLE 
    booking_resource_configs 
    ( 
        booking_resource_center int4 NOT NULL, 
        booking_resource_id int4 NOT NULL, 
        group_id int4 NOT NULL, 
        availability bytea, 
        maximum_participations int4, 
        business_starttimes text(2147483647), 
        other_starttimes    text(2147483647), 
        availability_period_id int4, 
        last_modified int8, 
        PRIMARY KEY (booking_resource_center, booking_resource_id, group_id), 
        CONSTRAINT book_res_conf_to_group_fk FOREIGN KEY (group_id) REFERENCES 
        "exerp"."booking_resource_groups" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT book_res_conf_to_book_res_fk FOREIGN KEY (booking_resource_center, 
    booking_resource_id) REFERENCES "exerp"."booking_resources" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

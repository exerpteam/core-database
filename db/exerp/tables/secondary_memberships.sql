CREATE TABLE 
    secondary_memberships 
    ( 
        id int4 NOT NULL, 
        secondary_member_person_center int4 NOT NULL, 
        secondary_member_person_id int4 NOT NULL, 
        subscription_add_on_id int4 NOT NULL, 
        start_time int8 NOT NULL, 
        stop_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT sec_mem_to_to_person_fk FOREIGN KEY (secondary_member_person_center, 
        secondary_member_person_id) REFERENCES "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sec_mem_to_to_soa_fk FOREIGN KEY (subscription_add_on_id) REFERENCES 
    "exerp"."subscription_addon" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

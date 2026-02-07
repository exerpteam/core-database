CREATE TABLE 
    receiver_group_caches 
    ( 
        receiver_group_id int4 NOT NULL, 
        privilege_id int4 NOT NULL, 
        privilege_type VARCHAR(20) NOT NULL, 
        valid_from int8, 
        valid_to int8, 
        CONSTRAINT rgc_to_rg FOREIGN KEY (receiver_group_id) REFERENCES 
        "exerp"."privilege_receiver_groups" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

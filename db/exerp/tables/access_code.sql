CREATE TABLE 
    access_code 
    ( 
        id int4 NOT NULL, 
        access_code text(2147483647) NOT NULL, 
        usage_point_center int4, 
        usage_point_id int4, 
        access_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT ac_to_upa_fk FOREIGN KEY (usage_point_center, usage_point_id) REFERENCES 
        "exerp"."usage_points" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

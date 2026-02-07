CREATE TABLE 
    person_staff_groups 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        staff_group_id int4 NOT NULL, 
        salary NUMERIC(0,0) NOT NULL, 
        commissionable bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT pers_staff_group_to_pers_fk FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT pers_staff_grp_to_staff_grp_fk FOREIGN KEY (staff_group_id) REFERENCES 
    "exerp"."staff_groups" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

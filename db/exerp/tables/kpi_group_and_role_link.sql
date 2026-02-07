CREATE TABLE 
    kpi_group_and_role_link 
    ( 
        kpi_group_id int4 NOT NULL, 
        role_id int4 NOT NULL, 
        PRIMARY KEY (kpi_group_id, role_id), 
        CONSTRAINT kpi_grp_and_role_to_kpi_grp_fk FOREIGN KEY (kpi_group_id) REFERENCES 
        "exerp"."kpi_group" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT kpi_grp_and_role_to_role_fk FOREIGN KEY (role_id) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

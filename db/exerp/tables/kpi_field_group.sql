CREATE TABLE 
    kpi_field_group 
    ( 
        field_id int4 NOT NULL, 
        group_id int4 NOT NULL, 
        PRIMARY KEY (field_id, group_id), 
        CONSTRAINT kpifg_field_fk FOREIGN KEY (field_id) REFERENCES "exerp"."kpi_fields" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT kpifg_group_fk FOREIGN KEY (group_id) REFERENCES "exerp"."kpi_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

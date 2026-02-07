CREATE TABLE 
    kpi_data 
    ( 
        field int4 NOT NULL, 
        center int4 NOT NULL, 
        for_date DATE NOT NULL, 
        VALUE    NUMERIC(0,0) NOT NULL, 
                 TIMESTAMP int8, 
        kind int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (field, center, for_date), 
        CONSTRAINT kpid_to_ce_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT kpid_to_kpif_fk FOREIGN KEY (field) REFERENCES "exerp"."kpi_fields" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

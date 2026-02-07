CREATE TABLE 
    accountingperiods 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        opened bool DEFAULT FALSE NOT NULL, 
        starttime int8 NOT NULL, 
        endtime int8 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT accperiod_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
        ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

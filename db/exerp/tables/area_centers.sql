CREATE TABLE 
    area_centers 
    ( 
        area int4 NOT NULL, 
        center int4 NOT NULL, 
        PRIMARY KEY (area, center), 
        CONSTRAINT areacenter_to_area_fk FOREIGN KEY (area) REFERENCES "exerp"."areas" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT areacenter_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

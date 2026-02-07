CREATE TABLE 
    areas 
    ( 
        id int4 NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        name text(2147483647) NOT NULL, 
        parent int4, 
        types text(2147483647), 
        copied_from int4, 
        root_area int4 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT area_to_area_fk FOREIGN KEY (parent) REFERENCES "exerp"."areas" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT area_to_root_fk FOREIGN KEY (root_area) REFERENCES "exerp"."areas" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

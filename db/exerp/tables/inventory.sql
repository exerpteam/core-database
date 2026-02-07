CREATE TABLE 
    inventory 
    ( 
        id int4 NOT NULL, 
        center int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        name  text(2147483647) NOT NULL, 
        def bool DEFAULT FALSE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT in_to_ce_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    privilege_cache_validity 
    ( 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        is_valid bool DEFAULT TRUE NOT NULL, 
        TIME int8, 
        PRIMARY KEY (person_center, person_id), 
        CONSTRAINT pcv_to_person FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

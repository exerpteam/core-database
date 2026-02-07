CREATE TABLE 
    privilege_cache 
    ( 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        privilege_id int4 NOT NULL, 
        privilege_type VARCHAR(20) NOT NULL, 
        valid_from int8, 
        valid_to int8, 
        grant_id int4 NOT NULL, 
        source_globalid VARCHAR(30), 
        source_center int4, 
        source_id int4, 
        source_subid int4, 
        extension bool DEFAULT FALSE NOT NULL, 
        CONSTRAINT priv_cache_to_person FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT priv_cache_to_pcv FOREIGN KEY (person_center, person_id) REFERENCES 
    "exerp"."privilege_cache_validity" ("person_center", "person_id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT priv_cache_to_grant FOREIGN KEY (grant_id) REFERENCES "exerp"."privilege_grants" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

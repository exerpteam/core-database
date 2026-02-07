CREATE TABLE 
    person_login_tokens 
    ( 
        id int4 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        created_at int8 NOT NULL, 
        token text(2147483647) NOT NULL, 
        version int8, 
        usage_type VARCHAR(30) DEFAULT 'MEMBER_APP'::character VARYING NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_plt_created_to_person FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    public_messages_person 
    ( 
        id int4 NOT NULL, 
        version int8 NOT NULL, 
        person_center int4 NOT NULL, 
        person_id int4 NOT NULL, 
        delivered bool NOT NULL, 
        delivered_at int8 NOT NULL, 
        delivery_code int4 NOT NULL, 
        READ bool NOT NULL, 
        read_at int8 NOT NULL, 
        deleted bool NOT NULL, 
        deleted_at int8 NOT NULL, 
        PRIMARY KEY (id, person_center, person_id), 
        CONSTRAINT fk_pmp_person FOREIGN KEY (person_center, person_id) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_pmp_id FOREIGN KEY (id) REFERENCES "exerp"."public_messages" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

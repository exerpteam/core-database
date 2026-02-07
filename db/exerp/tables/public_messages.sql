CREATE TABLE 
    public_messages 
    ( 
        id int4 NOT NULL, 
        version int8 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        STATE text(2147483647) NOT NULL, 
        created_at int8 NOT NULL, 
        created_by_center int4 NOT NULL, 
        created_by_id int4 NOT NULL, 
        valid_from int8 NOT NULL, 
        valid_to int8 NOT NULL, 
        subject text(2147483647) NOT NULL, 
        body    text(2147483647) NOT NULL, 
        important bool NOT NULL, 
        deleted bool NOT NULL, 
        deleted_at int8, 
        deleted_by_center int4, 
        deleted_by_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_pubmsg_created_by FOREIGN KEY (created_by_center, created_by_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_pubmsg_deleted_by FOREIGN KEY (deleted_by_center, deleted_by_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

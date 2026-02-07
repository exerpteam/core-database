CREATE TABLE 
    person_ext_attrs 
    ( 
        personcenter int4 NOT NULL, 
        personid int4 NOT NULL, 
        name     VARCHAR(50) NOT NULL, 
        txtvalue text(2147483647), 
        mimetype text(2147483647), 
        mimevalue bytea, 
        last_edit_time int8, 
        encrypted_value VARCHAR(400), 
        encryption_time int8, 
        PRIMARY KEY (personcenter, personid, name), 
        CONSTRAINT person_ext_attr_to_person_fk FOREIGN KEY (personcenter, personid) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

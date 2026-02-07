CREATE TABLE 
    journalentries 
    ( 
        id int4 NOT NULL, 
        person_center int4, 
        person_id int4, 
        person_subid int4, 
        jetype int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        creatorcenter int4, 
        creatorid int4, 
        creation_time int8 NOT NULL, 
                          text text(2147483647), 
        big_text_mimetype text(2147483647), 
        big_text bytea, 
        document_name text(2147483647), 
        document_layout int4, 
        document_mimetype text(2147483647), 
        document bytea, 
        signable bool DEFAULT FALSE NOT NULL, 
        ref_globalid text(2147483647), 
        ref_center int4, 
        ref_id int4, 
        ref_subid int4, 
        expiration_date DATE, 
        checked_signed_doc bool, 
        s3bucket       text(2147483647), 
        s3key          text(2147483647), 
        text_encrypted text(2147483647), 
        big_text_encrypted bytea, 
        encryption_time int8, 
        last_modified int8, 
        custom_type int4, 
        issue_date DATE, 
        replaced_by int4, 
        STATE VARCHAR(20), 
        PRIMARY KEY (id), 
        CONSTRAINT journal_entry_replaced_by FOREIGN KEY (replaced_by) REFERENCES 
        "exerp"."journalentries" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT je_to_person_fk FOREIGN KEY (person_center, person_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

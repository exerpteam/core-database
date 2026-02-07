CREATE TABLE 
    journalentry_and_role_link 
    ( 
        journalentry_id int4 NOT NULL, 
        role_id int4 NOT NULL, 
        PRIMARY KEY (journalentry_id, role_id), 
        CONSTRAINT je_and_role_to_je_fk FOREIGN KEY (journalentry_id) REFERENCES 
        "exerp"."journalentries" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT je_and_role_to_role_fk FOREIGN KEY (role_id) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

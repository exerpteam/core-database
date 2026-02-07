CREATE TABLE 
    journalentry_signatures 
    ( 
        id int4 NOT NULL, 
        journalentry_id int4 NOT NULL, 
        name text(2147483647) NOT NULL, 
        reason int4 NOT NULL, 
        rank int4 NOT NULL, 
        signature_center int4, 
        signature_id int4, 
        position_left NUMERIC(0,0), 
        position_top  NUMERIC(0,0), 
        width         NUMERIC(0,0), 
        height        NUMERIC(0,0), 
        page int4, 
        PRIMARY KEY (id), 
        CONSTRAINT signature_to_je_fk FOREIGN KEY (journalentry_id) REFERENCES 
        "exerp"."journalentries" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT jes_to_signature_fk FOREIGN KEY (signature_center, signature_id) REFERENCES 
    "exerp"."signatures" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

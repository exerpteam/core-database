CREATE TABLE 
    cashcollectionjournalentries 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        creationtime int8 NOT NULL, 
        step int4, 
        journalentry_id int4, 
        employee_center int4, 
        employee_id int4, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT ccje_to_cccases_fk FOREIGN KEY (center, id) REFERENCES 
        "exerp"."cashcollectioncases" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccje_to_empt_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
    "exerp"."employees" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT ccje_to_je_fk FOREIGN KEY (journalentry_id) REFERENCES "exerp"."journalentries" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    CASCADE 
    );

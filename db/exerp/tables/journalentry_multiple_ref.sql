CREATE TABLE 
    journalentry_multiple_ref 
    ( 
        journalentry_id int4 NOT NULL, 
        ref_center int4 NOT NULL, 
        ref_id int4 NOT NULL, 
        PRIMARY KEY (journalentry_id, ref_center, ref_id) 
    );

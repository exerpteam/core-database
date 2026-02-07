CREATE TABLE 
    doc_requirement_items 
    ( 
        id int4 NOT NULL, 
        documentation_requirement_key int4 NOT NULL, 
        type VARCHAR(30) NOT NULL, 
        name VARCHAR(50) NOT NULL, 
        item_type_key int4, 
        itm_instance_journal_entry_key int4, 
        item_instance_center int4, 
        item_instance_id int4, 
        item_instance_sub_id int4, 
        STATE VARCHAR(20) DEFAULT 'INCOMPLETE'::character VARYING NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT doc_req_itm_to_doc_req_fk FOREIGN KEY (documentation_requirement_key) REFERENCES 
        "exerp"."documentation_requirements" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT doc_req_itm_to_ins_jour_ent_fk FOREIGN KEY (itm_instance_journal_entry_key) 
    REFERENCES "exerp"."journalentries" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

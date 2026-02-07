CREATE TABLE 
    customer_credit_note 
    ( 
        id int4 NOT NULL, 
        reference_center int4 NOT NULL, 
        reference_id int4 NOT NULL, 
        issued_date int8 NOT NULL, 
        created_by_emp_center int4 NOT NULL, 
        created_by_emp_id int4 NOT NULL, 
        formatted_doc_mimetype VARCHAR(200), 
        formatted_doc_mimevalue bytea, 
        person_center int4, 
        person_id int4, 
        PRIMARY KEY (id), 
        CONSTRAINT customer_credit_notes_to_person_fk FOREIGN KEY (person_center, person_id) 
        REFERENCES "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

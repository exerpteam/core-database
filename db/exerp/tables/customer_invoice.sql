CREATE TABLE 
    customer_invoice 
    ( 
        id int4 NOT NULL, 
        reference_center int4 NOT NULL, 
        reference_id int4 NOT NULL, 
        reference_sub_id int4, 
        reference_type    text(2147483647) NOT NULL, 
        invoice_reference text(2147483647) NOT NULL, 
        issued_date int8 NOT NULL, 
        created_by_emp_center int4 NOT NULL, 
        created_by_emp_id int4 NOT NULL, 
        formatted_doc_mimetype text(2147483647), 
        formatted_doc_mimevalue bytea, 
        person_id int4, 
        person_center int4, 
        PRIMARY KEY (id), 
        CONSTRAINT customer_invoice_to_person_fk FOREIGN KEY (person_id, person_center) REFERENCES 
        "exerp"."persons" ("id", "center") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

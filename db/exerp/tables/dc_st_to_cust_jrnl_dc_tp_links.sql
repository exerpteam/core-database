CREATE TABLE 
    dc_st_to_cust_jrnl_dc_tp_links 
    ( 
        documentation_setting_key int4 NOT NULL, 
        custom_journal_doc_type_key int4 NOT NULL, 
        PRIMARY KEY (documentation_setting_key, custom_journal_doc_type_key), 
        CONSTRAINT dstcjdtl_to_cstm_jrnl_dc_tp_fk FOREIGN KEY (custom_journal_doc_type_key) 
        REFERENCES "exerp"."custom_journal_document_types" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT dstcjdtl_to_doc_setting_fk FOREIGN KEY (documentation_setting_key) REFERENCES 
    "exerp"."documentation_settings" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

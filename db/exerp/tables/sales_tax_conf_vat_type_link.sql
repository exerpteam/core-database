CREATE TABLE 
    sales_tax_conf_vat_type_link 
    ( 
        id int4 NOT NULL, 
        sales_tax_configuration_id int4 NOT NULL, 
        master_vat_type_global_id text(2147483647) NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT stcvtl_to_stc_fk FOREIGN KEY (sales_tax_configuration_id) REFERENCES 
        "exerp"."sales_tax_configuration" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

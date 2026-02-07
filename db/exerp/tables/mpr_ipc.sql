CREATE TABLE 
    mpr_ipc 
    ( 
        id int4 NOT NULL, 
        selecting_product_id int4 NOT NULL, 
        selected_ipc_id int4 NOT NULL, 
        created int8 NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT mpripc_ipc_fk FOREIGN KEY (selected_ipc_id) REFERENCES 
        "exerp"."installment_plan_configs" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT mpripc_product_fk FOREIGN KEY (selecting_product_id) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

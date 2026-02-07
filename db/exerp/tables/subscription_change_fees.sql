CREATE TABLE 
    subscription_change_fees 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        subscr_type_from int4, 
        subscr_type_to int4, 
        change_fee_product int4 NOT NULL, 
        type     text(2147483647) NOT NULL, 
        STATE    text(2147483647) NOT NULL, 
        created  TIMESTAMP NOT NULL, 
        modified TIMESTAMP NOT NULL, 
        deleted  TIMESTAMP, 
        version int8, 
        change_fee_percentage int4, 
        use_remaining_contract_value bool DEFAULT FALSE, 
        PRIMARY KEY (id), 
        CONSTRAINT change_fee_to_product_fk FOREIGN KEY (change_fee_product) REFERENCES 
        "exerp"."masterproductregister" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT change_fee_to_type_from_fk FOREIGN KEY (subscr_type_from) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT change_fee_to_type_to_fk FOREIGN KEY (subscr_type_to) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

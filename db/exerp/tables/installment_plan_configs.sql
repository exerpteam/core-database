CREATE TABLE 
    installment_plan_configs 
    ( 
        id int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name     text(2147483647) NOT NULL, 
        quantity NUMERIC(0,0) NOT NULL, 
        type     text(2147483647) NOT NULL, 
        rounding text(2147483647), 
        first_inst_paid_in_pos bool DEFAULT FALSE NOT NULL, 
        contract_template_id int4, 
        admin_fee_product int4, 
        roles text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        created int8 NOT NULL, 
        modified int8 NOT NULL, 
        deleted int8, 
        version int8, 
        external_id           text(2147483647), 
        installment_plan_type VARCHAR(30) DEFAULT 'CLIPCARD'::character VARYING NOT NULL, 
        threshold int4 DEFAULT 0 NOT NULL, 
        property_type VARCHAR(50), 
        property_configuration bytea, 
        initial_amount NUMERIC(0,0) DEFAULT 0 NOT NULL, 
        ref_type       VARCHAR(20), 
        ref_globalid   VARCHAR(40), 
        ref_center int4, 
        ref_id int4, 
        ref_program_type_id int4, 
        available_on_web bool DEFAULT TRUE NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT ipc_admin_fee_to_product_fk FOREIGN KEY (admin_fee_product) REFERENCES 
        "exerp"."masterproductregister" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

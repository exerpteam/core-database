CREATE TABLE 
    masterproductregister 
    ( 
        id int4 NOT NULL, 
        definition_key int4 NOT NULL, 
        scope_type text(2147483647), 
        scope_id int4, 
        product bytea, 
        globalid text(2147483647) NOT NULL, 
        masterproductregistertype int4 NOT NULL, 
        masterproductgroup int4, 
        cached_productname      text(2147483647), 
        cached_productprice     NUMERIC(0,0), 
        cached_productcostprice NUMERIC(0,0), 
        cached_producttype int4, 
        cached_external_id text(2147483647), 
        info_text          text(2147483647), 
        clearing_house_restriction int4 DEFAULT 0 NOT NULL, 
        globally_blocked bool DEFAULT FALSE NOT NULL, 
        STATE text(2147483647), 
        primary_product_group_id int4, 
        product_account_config_id int4, 
        creation_account_config_id int4, 
        prorata_account_config_id int4, 
        admin_fee_config_id int4, 
        use_contract_template bool DEFAULT FALSE NOT NULL, 
        contract_template_id int4, 
        last_state_change int8, 
        last_modified int8, 
        has_future_price_change bool DEFAULT TRUE NOT NULL, 
        mapi_selling_points text(2147483647), 
        mapi_rank int4, 
        mapi_description text(2147483647), 
        buyout_fee_config_id int4, 
        recurring_clipcard_id int4, 
        recurring_clipcard_clips int4, 
        sale_startup_clipcard bool, 
        sales_commission int4, 
        sales_units int4, 
        period_commission int4, 
        print_qr_on_receipt bool DEFAULT FALSE NOT NULL, 
        single_use bool, 
        buyout_fee_percentage int4, 
        change_requiredrole int4, 
        clipcard_pack_size   text(2147483647), 
        flat_rate_commission NUMERIC(0,0), 
        webname              VARCHAR(1024), 
        use_documentation_settings bool DEFAULT FALSE NOT NULL, 
        documentation_settings_id int4, 
        family_membership_type VARCHAR(20), 
        commissionable         VARCHAR(20) DEFAULT 'NONE'::character VARYING NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT mpr_to_masterproductgroup_fk FOREIGN KEY (masterproductgroup) REFERENCES 
        "exerp"."masterproductgroups" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prod_ovr_to_prod_def_fk FOREIGN KEY (definition_key) REFERENCES 
    "exerp"."masterproductregister" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT mast_prod_to_cr_acc_conf_fk FOREIGN KEY (creation_account_config_id) REFERENCES 
    "exerp"."product_account_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT mast_prod_to_pro_acc_conf_fk FOREIGN KEY (prorata_account_config_id) REFERENCES 
    "exerp"."product_account_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT mast_prod_to_prod_acc_conf_fk FOREIGN KEY (product_account_config_id) REFERENCES 
    "exerp"."product_account_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT mast_prod_to_prim_prod_grp_fk FOREIGN KEY (primary_product_group_id) REFERENCES 
    "exerp"."product_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    add_on_product_definition 
    ( 
        id int4 NOT NULL, 
        price_period_count int4, 
        price_period_unit int4, 
        scope_selection text(2147483647), 
        include_home_center bool NOT NULL, 
        required bool NOT NULL, 
        secondary_membership bool DEFAULT FALSE, 
        secondary_membership_type int4, 
        sec_mem_age_restriction_type int4, 
        sec_mem_age_restriction_value int4, 
        sec_mem_sex_restriction_type int4, 
        quantity_min int4 DEFAULT 1, 
        quantity_max int4 DEFAULT 1, 
        quantity_default int4 DEFAULT 1, 
        num_secondary_members_per_unit int4 DEFAULT 1, 
        use_individual_price bool DEFAULT FALSE NOT NULL, 
        freeze_fee_product_id int4, 
        include_in_pro_rata_period bool DEFAULT TRUE NOT NULL, 
        binding_period_count int4, 
        binding_period_unit int4, 
        start_date_restriction text(2147483647), 
        added_by_default bool DEFAULT FALSE NOT NULL, 
        sec_mem_age_rest_min_value int4, 
        sec_mem_age_rest_max_value int4, 
        PRIMARY KEY (id), 
        CONSTRAINT add_on_prod_def_to_prod_def_fk FOREIGN KEY (id) REFERENCES 
        "exerp"."masterproductregister" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

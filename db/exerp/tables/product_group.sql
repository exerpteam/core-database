CREATE TABLE 
    product_group 
    ( 
        id int4 NOT NULL, 
        top_node_id int4, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        name  text(2147483647), 
        STATE text(2147483647) NOT NULL, 
        parent_product_group_id int4, 
        dimension_product_group_id int4, 
        show_in_shop bool, 
        product_account_config_id int4, 
        colour_group_id int4, 
        ranking int4, 
        description text(2147483647), 
        in_subscription_sales bool, 
        hide_in_report_parameters bool, 
        exclude_from_member_count bool DEFAULT FALSE NOT NULL, 
        exclude_from_product_cleaning bool DEFAULT FALSE, 
        client_profile_id int4, 
        external_id text(2147483647), 
        last_modified int8, 
        single_product_in_basket bool, 
        show_on_web bool, 
        installment_plans_enabled bool DEFAULT FALSE, 
        PRIMARY KEY (id), 
        CONSTRAINT prod_grp_to_cli_prof_fk FOREIGN KEY (client_profile_id) REFERENCES 
        "exerp"."client_profiles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prod_grp_to_col_grp FOREIGN KEY (colour_group_id) REFERENCES "exerp"."colour_groups" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prod_grp_to_prod_acc_conf_fk FOREIGN KEY (product_account_config_id) REFERENCES 
    "exerp"."product_account_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

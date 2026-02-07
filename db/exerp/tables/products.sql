CREATE TABLE 
    products 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        blocked bool NOT NULL, 
        ptype int4 NOT NULL, 
        name        text(2147483647) NOT NULL, 
        coment      text(2147483647), 
        external_id text(2147483647), 
        income_accountcenter int4, 
        income_accountid int4, 
        expense_accountcenter int4, 
        expense_accountid int4, 
        refund_accountcenter int4, 
        refund_accountid int4, 
        price      NUMERIC(0,0) NOT NULL, 
        min_price  NUMERIC(0,0), 
        cost_price NUMERIC(0,0), 
        requiredrole int4, 
        globalid text(2147483647), 
        max_buy_qty int4, 
        max_buy_qty_period int4, 
        max_buy_qty_period_type int4, 
        needs_privilege bool DEFAULT FALSE NOT NULL, 
        show_in_sale bool DEFAULT TRUE NOT NULL, 
        returnable bool DEFAULT FALSE NOT NULL, 
        show_on_web bool DEFAULT TRUE NOT NULL, 
        show_on_mobile_api bool DEFAULT FALSE NOT NULL, 
        primary_product_group_id int4, 
        product_account_config_id int4, 
        override_price_and_text_role int4, 
        ipc_available bool DEFAULT FALSE NOT NULL, 
        last_modified int8, 
        restriction_type int4, 
        last_recount_date int8, 
        mapi_selling_points text(2147483647), 
        mapi_rank int4, 
        mapi_description text(2147483647), 
        sales_commission int4, 
        sales_units int4, 
        sold_outside_home_center bool DEFAULT FALSE NOT NULL, 
        period_commission int4, 
        print_qr_on_receipt bool DEFAULT FALSE NOT NULL, 
        single_use bool, 
        assigned_staff_group int4, 
        flat_rate_commission NUMERIC(0,0), 
        webname              VARCHAR(1024), 
        commissionable       VARCHAR(20) DEFAULT 'NONE'::character VARYING NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT product_to_expenseaccount_fk FOREIGN KEY (expense_accountcenter, 
        expense_accountid) REFERENCES "exerp"."accounts" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT product_to_incomeaccount_fk FOREIGN KEY (income_accountcenter, income_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT product_to_refundaccount_fk FOREIGN KEY (refund_accountcenter, refund_accountid) 
    REFERENCES "exerp"."accounts" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT product_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prod_to_prod_acc_conf_fk FOREIGN KEY (product_account_config_id) REFERENCES 
    "exerp"."product_account_configurations" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT prod_to_prim_prod_grp_fk FOREIGN KEY (primary_product_group_id) REFERENCES 
    "exerp"."product_group" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT product_to_emprole_fk FOREIGN KEY (requiredrole) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    subscriptiontypes 
    ( 
        center int4 NOT NULL, 
        change_requiredrole int4, 
        reactivation_allowed bool DEFAULT FALSE NOT NULL, 
        id int4 NOT NULL, 
        st_type int4 NOT NULL, 
        use_individual_price bool DEFAULT TRUE NOT NULL, 
        productnew_center int4, 
        productnew_id int4, 
        floatingperiod bool DEFAULT FALSE NOT NULL, 
        prorataperiodcount int4, 
        extend_binding_by_prorata bool DEFAULT FALSE, 
        initialperiodcount int4, 
        extend_binding_by_initial bool DEFAULT FALSE, 
        bindingperiodcount int4, 
        periodunit int4 NOT NULL, 
        periodcount int4 NOT NULL, 
        age_restriction_type int4 NOT NULL, 
        age_restriction_value int4 NOT NULL, 
        sex_restriction int4 NOT NULL, 
        freezelimit bytea, 
        freezeperiodproduct_center int4, 
        freezeperiodproduct_id int4, 
        freezestartupproduct_center int4, 
        freezestartupproduct_id int4, 
        transferproduct_center int4, 
        transferproduct_id int4, 
        add_on_to_center int4, 
        add_on_to_id int4, 
        renew_window int4, 
        rank int4 NOT NULL, 
        is_addon_subscription bool DEFAULT FALSE NOT NULL, 
        prorataproduct_center int4, 
        prorataproduct_id int4, 
        adminfeeproduct_center int4, 
        adminfeeproduct_id int4, 
        info_text text(2147483647), 
        clearing_house_restriction int4 DEFAULT 0 NOT NULL, 
        is_price_update_excluded bool DEFAULT FALSE, 
        start_date_limit_count int4, 
        start_date_limit_unit  text(2147483647), 
        start_date_restriction text(2147483647), 
        auto_stop_on_binding_end_date bool DEFAULT FALSE NOT NULL, 
        roundup_end_unit int4, 
        buyoutfeeproduct_center int4, 
        buyoutfeeproduct_id int4, 
        rec_clipcard_product_center int4, 
        rec_clipcard_product_id int4, 
        rec_clipcard_product_clips int4, 
        sale_startup_clipcard bool, 
        autorenew_binding_count int4, 
        autorenew_binding_unit text(2147483647), 
        autorenew_binding_notice_count int4, 
        autorenew_binding_notice_unit text(2147483647), 
        unrestricted_freeze_allowed bool DEFAULT TRUE NOT NULL, 
        buyout_fee_percentage int4, 
        can_be_reassigned bool DEFAULT FALSE NOT NULL, 
        reassign_product_center int4, 
        reassign_product_id int4, 
        reassign_template int4, 
        rec_clipcard_pack_size text(2147483647), 
        age_restriction_min_value int4, 
        age_restriction_max_value int4, 
        documentation_setting_id int4, 
        reassign_restrict_quantity int4, 
        reassign_restrict_span_unit int4, 
        reassign_restrict_span_value int4, 
        reassign_restrict_type_id int4, 
        family_membership_type VARCHAR(20), 
        renewal_requires_privilege bool DEFAULT FALSE NOT NULL, 
        is_member_operations_restricted_around_deduction_date bool DEFAULT FALSE NOT NULL, 
        member_operations_restricted_days_before_deduction_date int4 DEFAULT 0 NOT NULL, 
        member_operations_restricted_days_after_deduction_date int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT subtype_to_product_fk FOREIGN KEY (center, id) REFERENCES "exerp"."products" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productafp_fk FOREIGN KEY (adminfeeproduct_center, adminfeeproduct_id) 
    REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productbfp_fk FOREIGN KEY (buyoutfeeproduct_center, buyoutfeeproduct_id) 
    REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productfcp_fk FOREIGN KEY (freezestartupproduct_center, 
    freezestartupproduct_id) REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productfpp_fk FOREIGN KEY (freezeperiodproduct_center, 
    freezeperiodproduct_id) REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productnew_fk FOREIGN KEY (productnew_center, productnew_id) REFERENCES 
    "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_productrcp_fk FOREIGN KEY (rec_clipcard_product_center, 
    rec_clipcard_product_id) REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subtype_to_producttransfer_fk FOREIGN KEY (transferproduct_center, 
    transferproduct_id) REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

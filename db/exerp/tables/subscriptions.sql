CREATE TABLE 
    subscriptions 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        STATE int4 NOT NULL, 
        sub_state int4, 
        subscriptiontype_center int4, 
        subscriptiontype_id int4, 
        owner_center int4, 
        owner_id int4, 
        binding_end_date DATE, 
        binding_price    NUMERIC(0,0) NOT NULL, 
        individual_price bool DEFAULT FALSE NOT NULL, 
        subscription_price NUMERIC(0,0) NOT NULL, 
        start_date         DATE, 
        end_date           DATE, 
        end_date_auto_binding_end_date bool DEFAULT FALSE NOT NULL, 
        billed_until_date DATE, 
        refmain_center int4, 
        refmain_id int4, 
        creation_time int8, 
        creator_center int4, 
        creator_id int4, 
        orig_creator_center int4, 
        orig_creator_id int4, 
        saved_free_days int4 NOT NULL, 
        saved_free_months int4, 
        invoiceline_center int4, 
        invoiceline_id int4, 
        invoiceline_subid int4, 
        adminfee_invoiceline_subid int4, 
        transferred_center int4, 
        transferred_id int4, 
        sub_comment text(2147483647), 
        extended_to_center int4, 
        extended_to_id int4, 
        renewal_reminder_sent bool DEFAULT FALSE NOT NULL, 
        renewal_policy_override int4, 
        campaign_code_id int4, 
        is_price_update_excluded bool DEFAULT FALSE, 
        startup_free_period_id int4, 
        stup_free_period_unit int4, 
        stup_free_period_value int4, 
        stup_free_period_type text(2147483647), 
        stup_freep_extends_binding bool DEFAULT FALSE, 
        last_modified int8, 
        changed_to_center int4, 
        changed_to_id int4, 
        change_type int4, 
        period_commission int4, 
        payment_agreement_center int4, 
        payment_agreement_id int4, 
        payment_agreement_subid int4, 
        last_edit_time int8, 
        is_change_restricted bool DEFAULT FALSE NOT NULL, 
        reassigned_center int4, 
        reassigned_id int4, 
        rec_clipcard_clips int4, 
        buyoutfeeproduct_center int4, 
        buyoutfeeproduct_id int4, 
        assigned_staff_center int4, 
        assigned_staff_id int4, 
        installment_plan_id int4, 
        reassigned_time int8, 
        family_id int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT sub_to_campaign_code_fk FOREIGN KEY (campaign_code_id) REFERENCES 
        "exerp"."campaign_codes" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_center_fk FOREIGN KEY (center) REFERENCES "exerp"."centers" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subscriptions_family_fk FOREIGN KEY (family_id) REFERENCES "exerp"."families" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_installment_plan_fk FOREIGN KEY (installment_plan_id) REFERENCES 
    "exerp"."installment_plans" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_involine_fk FOREIGN KEY (invoiceline_center, invoiceline_id, 
    invoiceline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT subadminfee_to_involine_fk FOREIGN KEY (invoiceline_center, invoiceline_id, 
    adminfee_invoiceline_subid) REFERENCES "exerp"."invoice_lines_mt" ("center", "id", "subid") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_person_fk FOREIGN KEY (owner_center, owner_id) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_product_fk FOREIGN KEY (subscriptiontype_center, subscriptiontype_id) 
    REFERENCES "exerp"."products" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_startup_fk FOREIGN KEY (startup_free_period_id) REFERENCES 
    "exerp"."startup_campaign" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_extended_tofk FOREIGN KEY (extended_to_center, extended_to_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT trans_to_sub_fk FOREIGN KEY (transferred_center, transferred_id) REFERENCES 
    "exerp"."subscriptions" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT sub_to_subtype_fk FOREIGN KEY (subscriptiontype_center, subscriptiontype_id) 
    REFERENCES "exerp"."subscriptiontypes" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

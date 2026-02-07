CREATE TABLE 
    clipcardtypes 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        add_on_to_center int4, 
        add_on_to_id int4, 
        clip_count int4 NOT NULL, 
        period_unit int4, 
        period_count int4, 
        period_round text(2147483647) DEFAULT 'NONE'::text, 
        age_restriction_type int4 NOT NULL, 
        age_restriction_value int4 NOT NULL, 
        sex_restriction int4 NOT NULL, 
        info_text text(2147483647), 
        buyoutfeeproduct_center int4, 
        buyoutfeeproduct_id int4, 
        contract_template_id int4, 
        clipcard_usage_commission int4, 
        assigned_staff_group int4, 
        buyout_fee_percentage int4, 
        clips_pack_size text(2147483647), 
        age_restriction_min_value int4, 
        age_restriction_max_value int4, 
        ct_type int4 DEFAULT 0 NOT NULL, 
        PRIMARY KEY (center, id), 
        CONSTRAINT ccardtype_to_product_fk FOREIGN KEY (center, id) REFERENCES "exerp"."products" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    privilege_grants 
    ( 
        id int4 NOT NULL, 
        privilege_set int4, 
        punishment int4, 
        granter_service  text(2147483647) NOT NULL, 
        granter_globalid text(2147483647), 
        granter_center int4, 
        granter_id int4, 
        granter_subid int4, 
        valid_from int8, 
        valid_to int8, 
        sponsorship_name     text(2147483647), 
        sponsorship_amount   NUMERIC(0,0), 
        sponsorship_rounding text(2147483647), 
        usage_product        text(2147483647), 
        usage_quantity int4, 
        usage_duration_value int4, 
        usage_duration_unit int4, 
        usage_duration_round text(2147483647) DEFAULT 'NONE'::text, 
        usage_use_at_planning bool, 
        extension bool, 
        frequency_restriction_target VARCHAR(10) DEFAULT 'NULL::character varying' NOT NULL, 
        PRIMARY KEY (id), 
        CONSTRAINT priv_grant_to_priv_punishment FOREIGN KEY (punishment) REFERENCES 
        "exerp"."privilege_punishments" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT priv_grant_to_priv_set FOREIGN KEY (privilege_set) REFERENCES 
    "exerp"."privilege_sets" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

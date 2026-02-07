CREATE TABLE 
    message_type_config_relations 
    ( 
        event_type_config_id int4 NOT NULL, 
        ranking int4 NOT NULL, 
        delivery_method_id int4 NOT NULL, 
        template_id int4 NOT NULL, 
        delivery_schedule bytea, 
        charge_product text(2147483647), 
        availability_period_id int4, 
        receiver_address_type int4 DEFAULT 0 NOT NULL, 
        sender_address_type int4 DEFAULT 0 NOT NULL, 
        delay int4 DEFAULT 0 NOT NULL, 
        messagecategory text(2147483647), 
        PRIMARY KEY (delivery_method_id, event_type_config_id, ranking, template_id), 
        CONSTRAINT option_to_configuration FOREIGN KEY (event_type_config_id) REFERENCES 
        "exerp"."event_type_config" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT option_to_templates FOREIGN KEY (template_id) REFERENCES "exerp"."templates" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

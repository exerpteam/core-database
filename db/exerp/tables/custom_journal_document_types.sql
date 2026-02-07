CREATE TABLE 
    custom_journal_document_types 
    ( 
        id int4 NOT NULL, 
        definition_key int4, 
        scope_type VARCHAR(1) NOT NULL, 
        scope_id int4 NOT NULL, 
        STATE VARCHAR(10), 
        name  VARCHAR(50), 
        override_name bool NOT NULL, 
        external_id VARCHAR(200), 
        override_external_id bool NOT NULL, 
        validity_period       VARCHAR(20), 
        validity_period_start VARCHAR(20), 
        validity_period_overr_role_key int4, 
        override_validity_period bool NOT NULL, 
        mandatory_attachment bool, 
        override_mandatory_attachment bool NOT NULL, 
        required_role_key int4, 
        override_required_role_key bool NOT NULL, 
        availability    VARCHAR(2000), 
        expiration_date DATE, 
        PRIMARY KEY (id), 
        CONSTRAINT period_overr_role_to_role_fk FOREIGN KEY (validity_period_overr_role_key) 
        REFERENCES "exerp"."roles" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT required_role_to_role_fk FOREIGN KEY (required_role_key) REFERENCES "exerp"."roles" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

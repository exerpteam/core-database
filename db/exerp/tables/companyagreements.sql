CREATE TABLE 
    companyagreements 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        name text(2147483647), 
        roleid int4, 
        terms text(2147483647), 
        STATE int4 NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        documentation_required bool DEFAULT FALSE NOT NULL, 
        employee_number_required bool DEFAULT FALSE NOT NULL, 
        documentation_interval_unit int4 NOT NULL, 
        documentation_interval int4, 
        target_employee_count int4, 
        target_time int8, 
        contactcenter int4, 
        contactid int4, 
        own_privileges bytea, 
        REF           text(2147483647), 
        stop_new_date DATE, 
        cash_subscription_stop_date bool DEFAULT FALSE NOT NULL, 
        availability text(2147483647), 
        external_id  text(2147483647), 
        web_text     text(2147483647), 
        family_corporate_status int4 DEFAULT 0 NOT NULL, 
        max_family_corporate int4, 
        require_other_payer bool DEFAULT FALSE NOT NULL, 
        last_member_update int8 DEFAULT 0 NOT NULL, 
        creation_date   DATE, 
        start_date      DATE, 
        activation_date DATE, 
        last_modified int8, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT companyag_to_company_fk FOREIGN KEY (center, id) REFERENCES "exerp"."persons" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT companyag_to_contact_fk FOREIGN KEY (contactcenter, contactid) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT fk_ca_role FOREIGN KEY (roleid) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

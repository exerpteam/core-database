CREATE TABLE 
    employees 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        blocked bool DEFAULT FALSE NOT NULL, 
        use_api bool DEFAULT FALSE NOT NULL, 
        personcenter int4 NOT NULL, 
        personid int4 NOT NULL, 
        last_login        DATE, 
        passwd            text(2147483647), 
        passwd_expiration DATE, 
        passwd_never_expires bool DEFAULT FALSE NOT NULL, 
        passwd_expiration_warned bool DEFAULT FALSE NOT NULL, 
        external_id text(2147483647), 
        pause_messages bool DEFAULT FALSE NOT NULL, 
        employee_set_password_center int4, 
        employee_set_password_id int4, 
        password_hash VARCHAR(65), 
        password_hash_method int4 DEFAULT 1, 
        skip_set_pwd_before_expiring bool DEFAULT FALSE, 
        enterprise_subject VARCHAR(1000), 
        created_at int8, 
        block_status_changed_at int8, 
        PRIMARY KEY (center, id), 
        CONSTRAINT employee_to_person_fk FOREIGN KEY (personcenter, personid) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

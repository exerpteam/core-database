CREATE TABLE 
    enterprise_account_invites 
    ( 
        id VARCHAR(256) NOT NULL, 
        employee_center int4 NOT NULL, 
        employee_id int4 NOT NULL, 
        created    TIMESTAMP NOT NULL, 
        claimed_by VARCHAR(1024), 
        PRIMARY KEY (id), 
        CONSTRAINT account_invite_employee_fk FOREIGN KEY (employee_center, employee_id) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

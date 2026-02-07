CREATE TABLE 
    employeesroles 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        roleid int4 NOT NULL, 
        scope_type text(2147483647) NOT NULL, 
        scope_id int4 NOT NULL, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT empsrole_to_employee_fk FOREIGN KEY (center, id) REFERENCES "exerp"."employees" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT empsrole_to_emprole_fk FOREIGN KEY (roleid) REFERENCES "exerp"."roles" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    questionnaires 
    ( 
        id int4 NOT NULL, 
        name     text(2147483647) NOT NULL, 
        headline text(2147483647) NOT NULL, 
                 text text(2147483647) NOT NULL, 
        questions bytea, 
        employeecenter int4, 
        employeeid int4, 
        creation_time DATE NOT NULL, 
        scope_type    text(2147483647), 
        scope_id int4, 
        ENCRYPTED bool DEFAULT FALSE NOT NULL, 
        externalid VARCHAR(50), 
        PRIMARY KEY (id), 
        CONSTRAINT quest_to_employee_fk FOREIGN KEY (employeecenter, employeeid) REFERENCES 
        "exerp"."employees" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

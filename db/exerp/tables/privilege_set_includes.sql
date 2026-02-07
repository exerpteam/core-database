CREATE TABLE 
    privilege_set_includes 
    ( 
        id int4 NOT NULL, 
        parent_id int4, 
        child_id int4, 
        valid_from int8 NOT NULL, 
        valid_to int8, 
        PRIMARY KEY (id), 
        CONSTRAINT privilege_set_include_child FOREIGN KEY (child_id) REFERENCES 
        "exerp"."privilege_sets" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT privilege_set_include_parent FOREIGN KEY (parent_id) REFERENCES 
    "exerp"."privilege_sets" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

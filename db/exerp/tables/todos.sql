CREATE TABLE 
    todos 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        todo_type int4 NOT NULL, 
        assignedtocenter int4 NOT NULL, 
        assignedtoid int4 NOT NULL, 
        creatorcenter int4, 
        creatorid int4, 
        creation_time int8 NOT NULL, 
        deadline int8 NOT NULL, 
        status int4 NOT NULL, 
        subject text(2147483647) NOT NULL, 
        personcenter int4, 
        personid int4, 
        todo_group_id int4, 
        PRIMARY KEY (center, id), 
        CONSTRAINT todo_to_asssigned_fk FOREIGN KEY (assignedtocenter, assignedtoid) REFERENCES 
        "exerp"."persons" ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT todo_to_creator_fk FOREIGN KEY (creatorcenter, creatorid) REFERENCES 
    "exerp"."persons" ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT todo_to_person_fk FOREIGN KEY (personcenter, personid) REFERENCES "exerp"."persons" 
    ("center", "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT todo_to_todogroup_fk FOREIGN KEY (todo_group_id) REFERENCES "exerp"."todo_groups" 
    ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

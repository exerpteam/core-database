CREATE TABLE 
    messages_of_todos 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        message_center int4 NOT NULL, 
        message_id int4 NOT NULL, 
        message_subid int4 NOT NULL, 
        PRIMARY KEY (center, id, message_center, message_id, message_subid), 
        CONSTRAINT msgtodo_to_message_fk FOREIGN KEY (message_center, message_id, message_subid) 
        REFERENCES "exerp"."messages" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT msgtodo_to_todo_fk FOREIGN KEY (center, id) REFERENCES "exerp"."todos" ("center", 
    "id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

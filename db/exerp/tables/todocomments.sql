CREATE TABLE 
    todocomments 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        employeecenter int4 NOT NULL, 
        employeeid int4 NOT NULL, 
        comment_time int8 NOT NULL, 
        coment text(2147483647) NOT NULL, 
        ACTION text(2147483647) NOT NULL, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT todocomment_to_todo_fk FOREIGN KEY (center, id) REFERENCES "exerp"."todos" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

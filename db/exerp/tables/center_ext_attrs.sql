CREATE TABLE 
    center_ext_attrs 
    ( 
        id int4 NOT NULL, 
        center_id int4 NOT NULL, 
        name      text(2147483647) NOT NULL, 
        txt_value text(2147483647), 
        mime_type text(2147483647), 
        mime_value bytea, 
        last_edit_time int8, 
        PRIMARY KEY (id), 
        CONSTRAINT center_ext_attr_to_center_fk FOREIGN KEY (center_id) REFERENCES 
        "exerp"."centers" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

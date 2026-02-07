CREATE TABLE 
    extract_parameter 
    ( 
        id int4 NOT NULL, 
        EXTRACT int4, 
        name        text(2147483647) NOT NULL, 
        type        text(2147483647) NOT NULL, 
        label       text(2147483647) NOT NULL, 
        description text(2147483647), 
        configuration bytea, 
        default_value_text_value text(2147483647), 
        default_value_mime_type  text(2147483647), 
        default_value_mime_value bytea, 
        PRIMARY KEY (id), 
        CONSTRAINT fk_ep_extract FOREIGN KEY (EXTRACT) REFERENCES "exerp"."extract" ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

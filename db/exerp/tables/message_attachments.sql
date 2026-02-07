CREATE TABLE 
    message_attachments 
    ( 
        id int4 NOT NULL, 
        message_center int4 NOT NULL, 
        message_id int4 NOT NULL, 
        message_subid int4 NOT NULL, 
        attachment_mimetype text(2147483647), 
        attachment_mimevalue bytea, 
        attachment_filename text(2147483647), 
        s3bucket            text(2147483647), 
        s3key               text(2147483647), 
        PRIMARY KEY (id), 
        CONSTRAINT attachment_to_message_fk FOREIGN KEY (message_center, message_id, message_subid) 
        REFERENCES "exerp"."messages" ("center", "id", "subid") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

CREATE TABLE 
    messages 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        subid int4 NOT NULL, 
        deliverycode int4 DEFAULT 0 NOT NULL, 
        delivery_ref text(2147483647), 
        deliverymethod int4 DEFAULT 0 NOT NULL, 
        templatetype int4, 
        templateid int4, 
        senderid int4, 
        sendercenter int4, 
        sender_ext_ref text(2147483647) NOT NULL, 
        senttime int8 NOT NULL, 
        earliest_delivery_time int8, 
        receivedtime int8, 
        expiretime int8, 
        subject  text(2147483647) NOT NULL, 
        mimetype text(2147483647), 
        mimevalue bytea, 
        message_type_id int4, 
        delivered_by_center int4, 
        delivered_by_id int4, 
        invoice_line_center int4, 
        invoice_line_id int4, 
        invoice_line_subid int4, 
        use_work_address bool, 
        REFERENCE text(2147483647), 
        receiver_address_type int4 DEFAULT 0 NOT NULL, 
        sender_address_type int4 DEFAULT 0 NOT NULL, 
        payload         text(2147483647), 
        payload_type    text(2147483647), 
        messagecategory text(2147483647), 
        s3bucket        text(2147483647), 
        s3key           text(2147483647), 
        last_modified int8, 
        PRIMARY KEY (center, id, subid), 
        CONSTRAINT message_to_person_fk FOREIGN KEY (center, id) REFERENCES "exerp"."persons" 
        ("center", "id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION, 
    CONSTRAINT message_to_templates FOREIGN KEY (templateid) REFERENCES "exerp"."templates" ("id") 
ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

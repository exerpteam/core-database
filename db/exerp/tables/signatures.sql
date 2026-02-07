CREATE TABLE 
    signatures 
    ( 
        center int4 NOT NULL, 
        id int4 NOT NULL, 
        signature_document bytea, 
        signed_document bytea, 
        signed_document_mimetype text(2147483647), 
        signature_image_mimetype text(2147483647), 
        signature_image_data bytea, 
        signature_receipt int4 NOT NULL, 
        signature_hash text(2147483647), 
        signature_hash_b bytea, 
        document_receipt int4 NOT NULL, 
        document_hash text(2147483647), 
        document_hash_b bytea, 
        device_key text(2147483647) DEFAULT 'SIG_PLUS'::text NOT NULL, 
        creation_time int8, 
        s3bucket_signature_image_data text(2147483647), 
        s3bucket_signed_document      text(2147483647), 
        s3key_signature_image_data    text(2147483647), 
        s3key_signed_document         text(2147483647), 
        PRIMARY KEY (center, id) 
    );

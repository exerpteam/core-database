CREATE TABLE 
    client_instances 
    ( 
        id int4 NOT NULL, 
        client int4 NOT NULL, 
        session_id text(2147483647), 
        ipaddress  text(2147483647), 
        macaddress text(2147483647), 
        username   text(2147483647), 
        hostname   text(2147483647), 
        javainfo   text(2147483647), 
        osinfo     text(2147483647), 
        clientname text(2147483647), 
        locale     text(2147483647), 
        creation_time int8 DEFAULT 0, 
        startuptime int8 NOT NULL, 
        shutdowntime int8, 
        clientversion     text(2147483647), 
        certificate_name  text(2147483647), 
        jvm_arch          VARCHAR(20), 
        bootstrap_version VARCHAR(50), 
        jms_token         VARCHAR(30), 
        PRIMARY KEY (id), 
        CONSTRAINT client_instance_to_client_fk FOREIGN KEY (client) REFERENCES "exerp"."clients" 
        ("id") ON 
UPDATE 
    NO ACTION 
ON 
DELETE 
    NO ACTION 
    );

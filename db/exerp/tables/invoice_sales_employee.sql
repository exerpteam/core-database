CREATE TABLE 
    invoice_sales_employee 
    ( 
        id int4 NOT NULL, 
        invoice_id int4 NOT NULL, 
        invoice_center int4 NOT NULL, 
        sales_employee_id int4 NOT NULL, 
        sales_employee_center int4 NOT NULL, 
        change_employee_id int4 NOT NULL, 
        change_employee_center int4 NOT NULL, 
        start_time int8 NOT NULL, 
        stop_time int8, 
        PRIMARY KEY (id) 
    );

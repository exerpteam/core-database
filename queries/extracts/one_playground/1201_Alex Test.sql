-- The extract is extracted from Exerp on 2026-02-08
--  
SELECT
    subscription_freeze_period.id,
    subscription_freeze_period.subscription_center,
    subscription_freeze_period.subscription_id,
    subscription_freeze_period.start_invoice_line_center,
    subscription_freeze_period.start_invoice_line_id,
    subscription_freeze_period.start_invoice_line_subid,
    subscription_freeze_period.start_date,
    subscription_freeze_period.end_date,
    subscription_freeze_period.type,
    subscription_freeze_period.state,
    subscription_freeze_period.entry_time,
    subscription_freeze_period.cancel_time,
    subscription_freeze_period.text,
    subscription_freeze_period.employee_center,
    subscription_freeze_period.employee_id,
    subscription_freeze_period.entry_interface_type,
    subscription_freeze_period.cancel_employee_center,
    subscription_freeze_period.cancel_employee_id,
    subscription_freeze_period.cancel_interface_type,
    subscription_freeze_period.end_notified,
    subscription_freeze_period.last_modified
FROM subscription_freeze_period
where subscription_center = 101 and subscription_id = 1711
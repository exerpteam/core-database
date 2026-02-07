# payment_cycle_config
Configuration table for payment cycle config behavior and defaults. It is typically used where it appears in approximately 95 query files; common companions include [payment_agreements](payment_agreements.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `company` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `cycle_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `interval_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `INTERVAL` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `day_in_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `days_before_due` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `relative_renewal_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `deduction_date` | Date for deduction. | `int4` | Yes | No | - | - |
| `cashcollection_delay` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `booking_date` | Date for booking. | `int4` | Yes | No | - | - |
| `sign_up_deadline` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `sign_off_deadline` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `payment_coll_policy` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `renewal_policy` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `notify_deduction_change` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `pay_req_notification_mode` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `refunds_enablement_mode` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `recollect_account_balance` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `collect_future_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `exclude_collection_on_debt` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deduction_days_allowed` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [payment_agreements](payment_agreements.md) (89 query files), [account_receivables](account_receivables.md) (88 query files), [persons](persons.md) (87 query files), [payment_accounts](payment_accounts.md) (75 query files), [relatives](relatives.md) (58 query files), [clearinghouses](clearinghouses.md) (58 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [deduction_day_validations](deduction_day_validations.md).
- Second-level FK neighborhood includes: [clearinghouses](clearinghouses.md).

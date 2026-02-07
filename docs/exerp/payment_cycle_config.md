# payment_cycle_config
Configuration table for payment cycle config behavior and defaults. It is typically used where it appears in approximately 95 query files; common companions include [payment_agreements](payment_agreements.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `company` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `cycle_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `interval_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `INTERVAL` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `day_in_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `days_before_due` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `relative_renewal_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `deduction_date` | Date for deduction. | `int4` | Yes | No | - | - | `42` |
| `cashcollection_delay` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `booking_date` | Date for booking. | `int4` | Yes | No | - | - | `42` |
| `sign_up_deadline` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `sign_off_deadline` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `payment_coll_policy` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `renewal_policy` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `notify_deduction_change` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `pay_req_notification_mode` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `refunds_enablement_mode` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `recollect_account_balance` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `collect_future_days` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `exclude_collection_on_debt` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `deduction_days_allowed` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- Commonly used with: [payment_agreements](payment_agreements.md) (89 query files), [account_receivables](account_receivables.md) (88 query files), [persons](persons.md) (87 query files), [payment_accounts](payment_accounts.md) (75 query files), [relatives](relatives.md) (58 query files), [clearinghouses](clearinghouses.md) (58 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [deduction_day_validations](deduction_day_validations.md).
- Second-level FK neighborhood includes: [clearinghouses](clearinghouses.md).

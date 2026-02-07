# payment_cycle_config
Configuration table for payment cycle config behavior and defaults. It is typically used where it appears in approximately 95 query files; common companions include [payment_agreements](payment_agreements.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `company` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `cycle_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `interval_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `INTERVAL` | Operational field `INTERVAL` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `day_in_interval` | Business attribute `day_in_interval` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `days_before_due` | Business attribute `days_before_due` used by payment cycle config workflows and reporting. | `int4` | No | No | - | - |
| `relative_renewal_days` | Business attribute `relative_renewal_days` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `deduction_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int4` | Yes | No | - | - |
| `cashcollection_delay` | Business attribute `cashcollection_delay` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `booking_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int4` | Yes | No | - | - |
| `sign_up_deadline` | Business attribute `sign_up_deadline` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `sign_off_deadline` | Business attribute `sign_off_deadline` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `payment_coll_policy` | Business attribute `payment_coll_policy` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `renewal_policy` | Business attribute `renewal_policy` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `notify_deduction_change` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `pay_req_notification_mode` | Business attribute `pay_req_notification_mode` used by payment cycle config workflows and reporting. | `text(2147483647)` | No | No | - | - |
| `refunds_enablement_mode` | Business attribute `refunds_enablement_mode` used by payment cycle config workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `recollect_account_balance` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `collect_future_days` | Business attribute `collect_future_days` used by payment cycle config workflows and reporting. | `int4` | Yes | No | - | - |
| `exclude_collection_on_debt` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `deduction_days_allowed` | Business attribute `deduction_days_allowed` used by payment cycle config workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [payment_agreements](payment_agreements.md) (89 query files), [account_receivables](account_receivables.md) (88 query files), [persons](persons.md) (87 query files), [payment_accounts](payment_accounts.md) (75 query files), [relatives](relatives.md) (58 query files), [clearinghouses](clearinghouses.md) (58 query files).
- FK-linked tables: incoming FK from [ch_and_pcc_link](ch_and_pcc_link.md), [deduction_day_validations](deduction_day_validations.md).
- Second-level FK neighborhood includes: [clearinghouses](clearinghouses.md).

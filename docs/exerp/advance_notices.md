# advance_notices
Operational table for advance notices records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | No | No | - | - | `1` |
| `next_deduction_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `next_deduction_date` | Date for next deduction. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `normal_deduction_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `source_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `source_id` | Identifier of the related source record. | `int4` | No | No | - | - | `1001` |
| `agreement_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `101` |
| `agreement_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `agreement_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - | `1` |
| `employee_center` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `101` |
| `employee_id` | Foreign key field linking this record to `employees`. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - | `1001` |
| `deduction_data` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `template_data` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `s3bucket` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `s3key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md), [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

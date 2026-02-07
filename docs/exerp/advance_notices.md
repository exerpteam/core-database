# advance_notices
Operational table for advance notices records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | No | No | - | - |
| `next_deduction_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `next_deduction_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `normal_deduction_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `source_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `source_id` | Identifier for the related source entity used by this record. | `int4` | No | No | - | - |
| `agreement_center` | Center component of the composite reference to the related agreement record. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `agreement_id` | Identifier component of the composite reference to the related agreement record. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `agreement_subid` | Identifier of the related payment agreements record used by this row. | `int4` | No | No | [payment_agreements](payment_agreements.md) via (`agreement_center`, `agreement_id`, `agreement_subid` -> `center`, `id`, `subid`) | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | No | No | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) | - |
| `deduction_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `template_data` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `s3bucket` | Business attribute `s3bucket` used by advance notices workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key` | Business attribute `s3key` used by advance notices workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [employees](employees.md), [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

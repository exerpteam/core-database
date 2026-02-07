# ar_trans
Operational table for ar trans records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 984 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `trans_time` | Epoch timestamp for trans. | `int8` | No | No | - | - | `1738281600000` |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - | `42` |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - | `42` |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `due_date` | Date for due. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `transferred` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - | `1738281600000` |
| `payreq_spec_center` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - | `101` |
| `payreq_spec_id` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `payreq_spec_subid` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - | `1` |
| `collected` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `ref_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - | `101` |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - | `1001` |
| `ref_subid` | Sub-identifier for related ref detail rows. | `int4` | Yes | No | - | - | `1` |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | Yes | No | - | - | `1` |
| `match_info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `unsettled_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `collected_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - | `99.95` |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - | `1001` |
| `installment_plan_subindex` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `collect_agreement_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - | `101` |
| `collect_agreement_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - | `1001` |
| `collect_agreement_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - | `1` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |
| `collection_mode` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (869 query files), [persons](persons.md) (795 query files), [centers](centers.md) (621 query files), [invoices](invoices.md) (362 query files), [products](products.md) (359 query files), [account_trans](account_trans.md) (353 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md); incoming FK from [art_match](art_match.md), [cashregistertransactions](cashregistertransactions.md), [crt_art_link](crt_art_link.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

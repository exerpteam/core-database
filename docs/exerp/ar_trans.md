# ar_trans
Operational table for ar trans records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 984 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `trans_time` | Epoch timestamp for trans. | `int8` | No | No | - | - |
| `employeecenter` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Foreign key field linking this record to `employees`. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `due_date` | Date for due. | `DATE` | Yes | No | - | - |
| `info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `transferred` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | No | No | - | - |
| `payreq_spec_center` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `payreq_spec_id` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `payreq_spec_subid` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `collected` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `ref_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Sub-identifier for related ref detail rows. | `int4` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `text(2147483647)` | Yes | No | - | - |
| `match_info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `unsettled_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `collected_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `installment_plan_id` | Foreign key field linking this record to `installment_plans`. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `installment_plan_subindex` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `collect_agreement_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `collect_agreement_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `collect_agreement_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `collection_mode` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (869 query files), [persons](persons.md) (795 query files), [centers](centers.md) (621 query files), [invoices](invoices.md) (362 query files), [products](products.md) (359 query files), [account_trans](account_trans.md) (353 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md); incoming FK from [art_match](art_match.md), [cashregistertransactions](cashregistertransactions.md), [crt_art_link](crt_art_link.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

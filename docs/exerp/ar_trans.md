# ar_trans
Operational table for ar trans records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 984 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `trans_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `employeecenter` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `employeeid` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | [employees](employees.md) via (`employeecenter`, `employeeid` -> `center`, `id`) | - |
| `amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `due_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `info` | Operational field `info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `text` | Free-text content providing business context or operator notes for the record. | `text(2147483647)` | Yes | No | - | - |
| `transferred` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `payreq_spec_center` | Center component of the composite reference to the related payreq spec record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `payreq_spec_id` | Identifier component of the composite reference to the related payreq spec record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `payreq_spec_subid` | Identifier of the related payment request specifications record used by this row. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`payreq_spec_center`, `payreq_spec_id`, `payreq_spec_subid` -> `center`, `id`, `subid`) | - |
| `collected` | Operational field `collected` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `text(2147483647)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_subid` | Operational field `ref_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `text(2147483647)` | Yes | No | - | - |
| `match_info` | Business attribute `match_info` used by ar trans workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `unsettled_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `collected_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `installment_plan_id` | Identifier of the related installment plans record used by this row. | `int4` | Yes | No | [installment_plans](installment_plans.md) via (`installment_plan_id` -> `id`) | - |
| `installment_plan_subindex` | Business attribute `installment_plan_subindex` used by ar trans workflows and reporting. | `int4` | Yes | No | - | - |
| `collect_agreement_center` | Center component of the composite reference to the related collect agreement record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `collect_agreement_id` | Identifier component of the composite reference to the related collect agreement record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `collect_agreement_subid` | Identifier of the related payment agreements record used by this row. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`collect_agreement_center`, `collect_agreement_id`, `collect_agreement_subid` -> `center`, `id`, `subid`) | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `collection_mode` | Business attribute `collection_mode` used by ar trans workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (869 query files), [persons](persons.md) (795 query files), [centers](centers.md) (621 query files), [invoices](invoices.md) (362 query files), [products](products.md) (359 query files), [account_trans](account_trans.md) (353 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [employees](employees.md), [installment_plans](installment_plans.md), [payment_agreements](payment_agreements.md), [payment_request_specifications](payment_request_specifications.md); incoming FK from [art_match](art_match.md), [cashregistertransactions](cashregistertransactions.md), [crt_art_link](crt_art_link.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

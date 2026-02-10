# payment_requests
Financial/transactional table for payment requests records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 575 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`)<br>[payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`)<br>[payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | [payment_requests_state](../master%20tables/payment_requests_state.md) |
| `request_type` | Classification code describing the request type category (for example: Billing, DEBT COLLECTION, Debt Collection, LEGACY). | `int4` | Yes | No | - | [payment_requests_request_type](../master%20tables/payment_requests_request_type.md) |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `full_reference` | Operational field `full_reference` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `req_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `req_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `req_delivery` | Identifier of the related clearing out record used by this row. | `int4` | Yes | No | [clearing_out](clearing_out.md) via (`req_delivery` -> `id`) | - |
| `inv_coll_center` | Center component of the composite reference to the related inv coll record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `inv_coll_id` | Identifier component of the composite reference to the related inv coll record. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `inv_coll_subid` | Identifier of the related payment request specifications record used by this row. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_center` | Center component of the composite reference to the related reject fee invline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_id` | Identifier component of the composite reference to the related reject fee invline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `xfr_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `xfr_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `xfr_delivery` | Identifier of the related clearing in record used by this row. | `int4` | Yes | No | [clearing_in](clearing_in.md) via (`xfr_delivery` -> `id`) | - |
| `xfr_info` | Operational field `xfr_info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `clearinghouse_id` | Identifier of the related clearinghouse creditors record used by this row. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse_id`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `creditor_id` | Identifier of the related clearinghouse creditors record used by this row. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse_id`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `agr_subid` | Operational field `agr_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `formatted_doc_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `formatted_doc_mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `coll_fee_invline_center` | Center component of the composite reference to the related coll fee invline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `coll_fee_invline_id` | Identifier component of the composite reference to the related coll fee invline record. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `coll_fee_invline_subid` | Identifier of the related invoice lines mt record used by this row. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `due_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `rejected_reason_code` | Operational field `rejected_reason_code` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `uuid` | Business attribute `uuid` used by payment requests workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `employee_center` | Center component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier component of the composite reference to the assigned staff member. | `int4` | Yes | No | - | - |
| `notification_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `invoice_created_at` | Business attribute `invoice_created_at` used by payment requests workflows and reporting. | `int8` | Yes | No | - | - |
| `invoice_created_by_emp_center` | Center component of the composite reference to the related invoice created by emp record. | `int4` | Yes | No | - | - |
| `invoice_created_by_emp_id` | Identifier component of the composite reference to the related invoice created by emp record. | `int4` | Yes | No | - | - |
| `handler_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `specification_doc_mimetype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `specification_doc_mimevalue` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `clearinghouse_payment_ref` | Business attribute `clearinghouse_payment_ref` used by payment requests workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3key_formatted_doc` | Business attribute `s3key_formatted_doc` used by payment requests workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket_formatted_doc` | Business attribute `s3bucket_formatted_doc` used by payment requests workflows and reporting. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (515 query files), [persons](persons.md) (462 query files), [centers](centers.md) (362 query files), [payment_request_specifications](payment_request_specifications.md) (339 query files), [ar_trans](ar_trans.md) (281 query files), [payment_agreements](payment_agreements.md) (254 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [invoice_lines_mt](invoice_lines_mt.md), [payment_accounts](payment_accounts.md), [payment_request_specifications](payment_request_specifications.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [ar_trans](ar_trans.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashcollection_requests](cashcollection_requests.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouses](clearinghouses.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

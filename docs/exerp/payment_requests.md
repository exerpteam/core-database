# payment_requests
Financial/transactional table for payment requests records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 575 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`)<br>[payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [account_receivables](account_receivables.md) via (`center`, `id` -> `center`, `id`)<br>[payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `request_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `full_reference` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `req_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - |
| `req_date` | Date for req. | `DATE` | No | No | - | - |
| `req_delivery` | Foreign key field linking this record to `clearing_out`. | `int4` | Yes | No | [clearing_out](clearing_out.md) via (`req_delivery` -> `id`) | - |
| `inv_coll_center` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `inv_coll_id` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `inv_coll_subid` | Foreign key field linking this record to `payment_request_specifications`. | `int4` | Yes | No | [payment_request_specifications](payment_request_specifications.md) via (`inv_coll_center`, `inv_coll_id`, `inv_coll_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `reject_fee_invline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`reject_fee_invline_center`, `reject_fee_invline_id`, `reject_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `xfr_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `xfr_date` | Date for xfr. | `DATE` | Yes | No | - | - |
| `xfr_delivery` | Foreign key field linking this record to `clearing_in`. | `int4` | Yes | No | [clearing_in](clearing_in.md) via (`xfr_delivery` -> `id`) | - |
| `xfr_info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `clearinghouse_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse_id`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `creditor_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse_id`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `agr_subid` | Sub-identifier for related agr detail rows. | `int4` | Yes | No | - | - |
| `formatted_doc_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `formatted_doc_mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `coll_fee_invline_center` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `coll_fee_invline_id` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `coll_fee_invline_subid` | Foreign key field linking this record to `invoice_lines_mt`. | `int4` | Yes | No | [invoice_lines_mt](invoice_lines_mt.md) via (`coll_fee_invline_center`, `coll_fee_invline_id`, `coll_fee_invline_subid` -> `center`, `id`, `subid`) | - |
| `due_date` | Date for due. | `DATE` | Yes | No | - | - |
| `entry_time` | Epoch timestamp for entry. | `int8` | Yes | No | - | - |
| `rejected_reason_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `uuid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `employee_center` | Center part of the reference to related employee data. | `int4` | Yes | No | - | [employees](employees.md) via (`employee_center`, `employee_id` -> `center`, `id`) |
| `employee_id` | Identifier of the related employee record. | `int4` | Yes | No | - | - |
| `notification_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `invoice_created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `invoice_created_by_emp_center` | Center part of the reference to related invoice created by emp data. | `int4` | Yes | No | - | - |
| `invoice_created_by_emp_id` | Identifier of the related invoice created by emp record. | `int4` | Yes | No | - | - |
| `handler_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `specification_doc_mimetype` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `specification_doc_mimevalue` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `clearinghouse_payment_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3key_formatted_doc` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `s3bucket_formatted_doc` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (515 query files), [persons](persons.md) (462 query files), [centers](centers.md) (362 query files), [payment_request_specifications](payment_request_specifications.md) (339 query files), [ar_trans](ar_trans.md) (281 query files), [payment_agreements](payment_agreements.md) (254 query files).
- FK-linked tables: outgoing FK to [account_receivables](account_receivables.md), [clearing_in](clearing_in.md), [clearing_out](clearing_out.md), [clearinghouse_creditors](clearinghouse_creditors.md), [invoice_lines_mt](invoice_lines_mt.md), [payment_accounts](payment_accounts.md), [payment_request_specifications](payment_request_specifications.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [ar_trans](ar_trans.md), [bundle_campaign_usages](bundle_campaign_usages.md), [cashcollection_requests](cashcollection_requests.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouses](clearinghouses.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

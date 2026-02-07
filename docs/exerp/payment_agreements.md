# payment_agreements
Financial/transactional table for payment agreements records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 805 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - |
| `active` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `clearinghouse` | Foreign key field linking this record to `clearinghouse_creditors`. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `creditor_id` | Foreign key field linking this record to `clearinghouse_creditors`. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `bank_regno` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_branch_no` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_control_digits` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_accno` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_holder` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `extra_info` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `request_serial` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `requests_sent` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `clearinghouse_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `iban` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bic` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `notify_payment` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `maximum_deduction_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `standard_deduction_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `payment_cycle_config_id` | Identifier of the related payment cycle config record. | `int4` | No | No | - | [payment_cycle_config](payment_cycle_config.md) via (`payment_cycle_config_id` -> `id`) |
| `individual_deduction_day` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `expiration_date` | Date for expiration. | `DATE` | Yes | No | - | - |
| `expiration_notified` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `prev_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `prev_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `prev_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `current_center` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `current_id` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `current_subid` | Foreign key field linking this record to `payment_agreements`. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `ended_reason_code` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ended_reason_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ended_date` | Date for ended. | `DATE` | Yes | No | - | - |
| `ended_clearing_in` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `valid_agreement_change` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `deduction_day_changed` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `pr_approval_enabled` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `pr_auto_approval_enabled` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `pr_auto_approval_lower_pct` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `pr_auto_approval_upper_pct` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `ignore_missing_agreement` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `account_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `example_reference` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_details` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `clearinghouse_init_ref` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_number_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_reg_accno_search_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `bank_accno_search_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `agreement_completion_method` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `use_electronic_invoicing` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `credit_card_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `enable_card_on_file` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(100)` | Yes | No | - | - |
| `billing_address_id` | Foreign key field linking this record to `postal_address`. | `int4` | Yes | No | [postal_address](postal_address.md) via (`billing_address_id` -> `id`) | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (780 query files), [persons](persons.md) (736 query files), [payment_accounts](payment_accounts.md) (569 query files), [centers](centers.md) (449 query files), [subscriptions](subscriptions.md) (342 query files), [products](products.md) (285 query files).
- FK-linked tables: outgoing FK to [clearinghouse_creditors](clearinghouse_creditors.md), [payment_accounts](payment_accounts.md), [payment_agreements](payment_agreements.md), [postal_address](postal_address.md); incoming FK from [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [payment_accounts](payment_accounts.md), [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accounts](accounts.md), [art_match](art_match.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouses](clearinghouses.md), [crt_art_link](crt_art_link.md), [employees](employees.md), [installment_plans](installment_plans.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

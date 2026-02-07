# payment_agreements
Financial/transactional table for payment agreements records. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 805 query files; common companions include [account_receivables](account_receivables.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [payment_accounts](payment_accounts.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | - |
| `active` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `clearinghouse` | Identifier of the related clearinghouse creditors record used by this row. | `int4` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `creditor_id` | Identifier of the related clearinghouse creditors record used by this row. | `text(2147483647)` | Yes | No | [clearinghouse_creditors](clearinghouse_creditors.md) via (`clearinghouse`, `creditor_id` -> `clearinghouse`, `creditor_id`) | - |
| `bank_regno` | Operational field `bank_regno` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_branch_no` | Operational field `bank_branch_no` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_name` | Business attribute `bank_name` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_control_digits` | Business attribute `bank_control_digits` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_accno` | Operational field `bank_accno` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_holder` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `extra_info` | Operational field `extra_info` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `request_serial` | Business attribute `request_serial` used by payment agreements workflows and reporting. | `int4` | No | No | - | - |
| `requests_sent` | Operational field `requests_sent` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `clearinghouse_ref` | Operational field `clearinghouse_ref` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `iban` | Operational field `iban` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `bic` | Operational field `bic` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `notify_payment` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `maximum_deduction_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `standard_deduction_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `payment_cycle_config_id` | Identifier for the related payment cycle config entity used by this record. | `int4` | No | No | - | [payment_cycle_config](payment_cycle_config.md) via (`payment_cycle_config_id` -> `id`) |
| `individual_deduction_day` | Operational field `individual_deduction_day` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `expiration_notified` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `prev_center` | Center component of the composite reference to the related prev record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `prev_id` | Identifier component of the composite reference to the related prev record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `prev_subid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`prev_center`, `prev_id`, `prev_subid` -> `center`, `id`, `subid`) | - |
| `current_center` | Center component of the composite reference to the related current record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `current_id` | Identifier component of the composite reference to the related current record. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `current_subid` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [payment_agreements](payment_agreements.md) via (`current_center`, `current_id`, `current_subid` -> `center`, `id`, `subid`) | - |
| `ended_reason_code` | Business attribute `ended_reason_code` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `ended_reason_text` | Business attribute `ended_reason_text` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `ended_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `ended_clearing_in` | Business attribute `ended_clearing_in` used by payment agreements workflows and reporting. | `int4` | Yes | No | - | - |
| `valid_agreement_change` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `deduction_day_changed` | Business attribute `deduction_day_changed` used by payment agreements workflows and reporting. | `DATE` | Yes | No | - | - |
| `pr_approval_enabled` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `pr_auto_approval_enabled` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `pr_auto_approval_lower_pct` | Business attribute `pr_auto_approval_lower_pct` used by payment agreements workflows and reporting. | `int4` | No | No | - | - |
| `pr_auto_approval_upper_pct` | Business attribute `pr_auto_approval_upper_pct` used by payment agreements workflows and reporting. | `int4` | No | No | - | - |
| `ignore_missing_agreement` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `account_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `example_reference` | Business attribute `example_reference` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_details` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `clearinghouse_init_ref` | Business attribute `clearinghouse_init_ref` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_account_number_hash` | Operational counter/limit used for processing control and performance monitoring. | `text(2147483647)` | Yes | No | - | - |
| `bank_reg_accno_search_hash` | Business attribute `bank_reg_accno_search_hash` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `bank_accno_search_hash` | Business attribute `bank_accno_search_hash` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `agreement_completion_method` | Business attribute `agreement_completion_method` used by payment agreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `use_electronic_invoicing` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `credit_card_type` | Classification code describing the credit card type category (for example: AmericanExpress, Dankort, DinersClub, JcB). | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `enable_card_on_file` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(100)` | Yes | No | - | - |
| `billing_address_id` | Identifier of the related postal address record used by this row. | `int4` | Yes | No | [postal_address](postal_address.md) via (`billing_address_id` -> `id`) | - |

# Relations
- Commonly used with: [account_receivables](account_receivables.md) (780 query files), [persons](persons.md) (736 query files), [payment_accounts](payment_accounts.md) (569 query files), [centers](centers.md) (449 query files), [subscriptions](subscriptions.md) (342 query files), [products](products.md) (285 query files).
- FK-linked tables: outgoing FK to [clearinghouse_creditors](clearinghouse_creditors.md), [payment_accounts](payment_accounts.md), [payment_agreements](payment_agreements.md), [postal_address](postal_address.md); incoming FK from [advance_notices](advance_notices.md), [agreement_change_log](agreement_change_log.md), [ar_trans](ar_trans.md), [payment_accounts](payment_accounts.md), [payment_agreements](payment_agreements.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [accounts](accounts.md), [art_match](art_match.md), [cashregistertransactions](cashregistertransactions.md), [centers](centers.md), [clearinghouse_cred_receivers](clearinghouse_cred_receivers.md), [clearinghouses](clearinghouses.md), [crt_art_link](crt_art_link.md), [employees](employees.md), [installment_plans](installment_plans.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

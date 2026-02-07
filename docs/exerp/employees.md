# employees
People-related master or relationship table for employees data. It is typically used where rows are center-scoped; it appears in approximately 826 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `use_api` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `personcenter` | Center component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `personid` | Identifier component of the composite reference to the related person. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `last_login` | Operational field `last_login` used in query filtering and reporting transformations. | `DATE` | Yes | No | - | - |
| `passwd` | Business attribute `passwd` used by employees workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `passwd_expiration` | Business attribute `passwd_expiration` used by employees workflows and reporting. | `DATE` | Yes | No | - | - |
| `passwd_never_expires` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `passwd_expiration_warned` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `pause_messages` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `employee_set_password_center` | Center component of the composite reference to the related employee set password record. | `int4` | Yes | No | - | - |
| `employee_set_password_id` | Identifier component of the composite reference to the related employee set password record. | `int4` | Yes | No | - | - |
| `password_hash` | Business attribute `password_hash` used by employees workflows and reporting. | `VARCHAR(65)` | Yes | No | - | - |
| `password_hash_method` | Business attribute `password_hash_method` used by employees workflows and reporting. | `int4` | Yes | No | - | - |
| `skip_set_pwd_before_expiring` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `enterprise_subject` | Business attribute `enterprise_subject` used by employees workflows and reporting. | `VARCHAR(1000)` | Yes | No | - | - |
| `created_at` | Business attribute `created_at` used by employees workflows and reporting. | `int8` | Yes | No | - | - |
| `block_status_changed_at` | State indicator used to control lifecycle transitions and filtering. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (810 query files), [centers](centers.md) (558 query files), [products](products.md) (463 query files), [subscriptions](subscriptions.md) (372 query files), [person_ext_attrs](person_ext_attrs.md) (299 query files), [subscriptiontypes](subscriptiontypes.md) (199 query files).
- FK-linked tables: outgoing FK to [persons](persons.md); incoming FK from [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md), [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md), [delivery](delivery.md), [employee_login_tokens](employee_login_tokens.md), [employee_password_history](employee_password_history.md), [employeesroles](employeesroles.md), [enterprise_account_invites](enterprise_account_invites.md), [exchanged_file](exchanged_file.md), [exchanged_file_op](exchanged_file_op.md), [extract_usage](extract_usage.md), [gift_card_usages](gift_card_usages.md), [installment_plans](installment_plans.md), [inventory_trans](inventory_trans.md), [invoices](invoices.md), [license_change_logs](license_change_logs.md), [public_messages](public_messages.md), [questionnaires](questionnaires.md), [report_usage](report_usage.md), [state_change_log](state_change_log.md), [subscription_blocked_period](subscription_blocked_period.md), [subscription_change](subscription_change.md), [subscription_freeze_period](subscription_freeze_period.md), [subscription_price](subscription_price.md), [subscription_reduced_period](subscription_reduced_period.md), [subscription_sales](subscription_sales.md), [training_programs](training_programs.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [art_match](art_match.md), [attends](attends.md), [bill_lines_mt](bill_lines_mt.md), [booking_program_levels](booking_program_levels.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollection_requests](cashcollection_requests.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.

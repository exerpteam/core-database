# employees
People-related master or relationship table for employees data. It is typically used where rows are center-scoped; it appears in approximately 826 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | - | [centers](centers.md) via (`center` -> `id`) |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `use_api` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `personcenter` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `personid` | Foreign key field linking this record to `persons`. | `int4` | No | No | [persons](persons.md) via (`personcenter`, `personid` -> `center`, `id`) | - |
| `last_login` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `passwd` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `passwd_expiration` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `passwd_never_expires` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `passwd_expiration_warned` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `pause_messages` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `employee_set_password_center` | Center part of the reference to related employee set password data. | `int4` | Yes | No | - | - |
| `employee_set_password_id` | Identifier of the related employee set password record. | `int4` | Yes | No | - | - |
| `password_hash` | Text field containing descriptive or reference information. | `VARCHAR(65)` | Yes | No | - | - |
| `password_hash_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `skip_set_pwd_before_expiring` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `enterprise_subject` | Text field containing descriptive or reference information. | `VARCHAR(1000)` | Yes | No | - | - |
| `created_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `block_status_changed_at` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (810 query files), [centers](centers.md) (558 query files), [products](products.md) (463 query files), [subscriptions](subscriptions.md) (372 query files), [person_ext_attrs](person_ext_attrs.md) (299 query files), [subscriptiontypes](subscriptiontypes.md) (199 query files).
- FK-linked tables: outgoing FK to [persons](persons.md); incoming FK from [account_receivables](account_receivables.md), [advance_notices](advance_notices.md), [ar_trans](ar_trans.md), [bank_account_blocks](bank_account_blocks.md), [bills](bills.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_skills](booking_program_skills.md), [card_clip_usages](card_clip_usages.md), [cashcollectionjournalentries](cashcollectionjournalentries.md), [cashregisterreports](cashregisterreports.md), [cashregistertransactions](cashregistertransactions.md), [credit_notes](credit_notes.md), [delivery](delivery.md), [employee_login_tokens](employee_login_tokens.md), [employee_password_history](employee_password_history.md), [employeesroles](employeesroles.md), [enterprise_account_invites](enterprise_account_invites.md), [exchanged_file](exchanged_file.md), [exchanged_file_op](exchanged_file_op.md), [extract_usage](extract_usage.md), [gift_card_usages](gift_card_usages.md), [installment_plans](installment_plans.md), [inventory_trans](inventory_trans.md), [invoices](invoices.md), [license_change_logs](license_change_logs.md), [public_messages](public_messages.md), [questionnaires](questionnaires.md), [report_usage](report_usage.md), [state_change_log](state_change_log.md), [subscription_blocked_period](subscription_blocked_period.md), [subscription_change](subscription_change.md), [subscription_freeze_period](subscription_freeze_period.md), [subscription_price](subscription_price.md), [subscription_reduced_period](subscription_reduced_period.md), [subscription_sales](subscription_sales.md), [training_programs](training_programs.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accounts](accounts.md), [art_match](art_match.md), [attends](attends.md), [bill_lines_mt](bill_lines_mt.md), [booking_program_levels](booking_program_levels.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollection_requests](cashcollection_requests.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier.

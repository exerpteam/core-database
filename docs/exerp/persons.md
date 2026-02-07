# persons
People-related master or relationship table for persons data. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 5262 query files; common companions include [centers](centers.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `blacklisted` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `persontype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - |
| `firstname` | First name value. | `text(2147483647)` | Yes | No | - | - |
| `middlename` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `lastname` | Last name value. | `text(2147483647)` | Yes | No | - | - |
| `fullname` | Combined full name representation. | `text(2147483647)` | Yes | No | - | - |
| `nickname` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address1` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address2` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `address3` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `country` | Foreign key field linking this record to `zipcodes`. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `zipcode` | Foreign key field linking this record to `zipcodes`. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `city` | Foreign key field linking this record to `zipcodes`. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `birthdate` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `sex` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `pincode` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `password_hash` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `co_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `ssn` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `friends_allowance` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `passwd_expiration` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `first_active_start_date` | Date for first active start. | `DATE` | Yes | No | - | - |
| `last_active_start_date` | Date for last active start. | `DATE` | Yes | No | - | - |
| `last_active_end_date` | Date for last active end. | `DATE` | Yes | No | - | - |
| `memberdays` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `accumulated_memberdays` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `current_person_center` | Center part of the reference to related current person data. | `int4` | Yes | No | - | - |
| `current_person_id` | Identifier of the related current person record. | `int4` | Yes | No | - | - |
| `suspension_internal_note` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `suspension_external_note` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - |
| `prefer_invoice_by_email` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `member_status` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `member_status_context` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `password_reset_token` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `password_reset_token_exp` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `password_reset_token_used` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `fullname_search` | Table field used by operational and reporting workloads. | `tsvector` | Yes | No | - | - |
| `transfers_current_prs_center` | Center part of the reference to related transfers current prs data. | `int4` | Yes | No | - | - |
| `STATE` | State code representing the current processing state. | `VARCHAR(60)` | Yes | No | - | - |
| `transfers_current_prs_id` | Identifier of the related transfers current prs record. | `int4` | Yes | No | - | - |
| `encrypted_ssn` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `encryption_time` | Epoch timestamp for encryption. | `int8` | Yes | No | - | - |
| `national_id` | Identifier of the related national record. | `VARCHAR(100)` | Yes | No | - | - |
| `resident_id` | Identifier of the related resident record. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (3073 query files), [subscriptions](subscriptions.md) (2204 query files), [products](products.md) (2203 query files), [person_ext_attrs](person_ext_attrs.md) (1802 query files), [account_receivables](account_receivables.md) (1593 query files), [subscriptiontypes](subscriptiontypes.md) (1156 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [zipcodes](zipcodes.md); incoming FK from [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [checkins](checkins.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md), [credit_notes](credit_notes.md), [customer_credit_note](customer_credit_note.md), [customer_invoice](customer_invoice.md), [daily_member_status_changes](daily_member_status_changes.md), [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_monitor_period](data_cleaning_monitor_period.md), [data_cleaning_out_line](data_cleaning_out_line.md), [delivery](delivery.md), [documentation_requirements](documentation_requirements.md), [employees](employees.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [invoices](invoices.md), [journalentries](journalentries.md), [messages](messages.md), [participations](participations.md), [person_ext_attrs](person_ext_attrs.md), [person_login_tokens](person_login_tokens.md), [person_staff_groups](person_staff_groups.md), [privilege_cache](privilege_cache.md), [privilege_cache_validity](privilege_cache_validity.md), [public_messages_person](public_messages_person.md), [questionnaire_answer](questionnaire_answer.md), [recurring_participations](recurring_participations.md), [relatives](relatives.md), [secondary_memberships](secondary_memberships.md), [staff_subscribed_centers](staff_subscribed_centers.md), [staff_usage](staff_usage.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [supplier](supplier.md), [task_log](task_log.md), [tasks](tasks.md), [todos](todos.md), [training_programs](training_programs.md), [usage_point_usages](usage_point_usages.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [activity](activity.md), [activity_staff_configurations](activity_staff_configurations.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bank_account_blocks](bank_account_blocks.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

# persons
People-related master or relationship table for persons data. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 5262 query files; common companions include [centers](centers.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [centers](centers.md) via (`center` -> `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | - | - |
| `blacklisted` | Operational field `blacklisted` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `persontype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [persons_persontype](../master%20tables/persons_persontype.md) |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | No | No | - | [persons_status](../master%20tables/persons_status.md) |
| `firstname` | Operational field `firstname` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `middlename` | Operational field `middlename` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `lastname` | Operational field `lastname` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `fullname` | Operational field `fullname` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `nickname` | Business attribute `nickname` used by persons workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `address1` | Operational field `address1` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `address2` | Operational field `address2` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `address3` | Operational field `address3` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `country` | Identifier of the related zipcodes record used by this row. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `zipcode` | Identifier of the related zipcodes record used by this row. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `city` | Identifier of the related zipcodes record used by this row. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `birthdate` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `sex` | Operational field `sex` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | [persons_sex](../master%20tables/persons_sex.md) |
| `pincode` | Operational field `pincode` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `password_hash` | Business attribute `password_hash` used by persons workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `co_name` | Business attribute `co_name` used by persons workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `ssn` | Operational field `ssn` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `friends_allowance` | Operational field `friends_allowance` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `passwd_expiration` | Business attribute `passwd_expiration` used by persons workflows and reporting. | `DATE` | Yes | No | - | - |
| `first_active_start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `last_active_start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `last_active_end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `memberdays` | Operational field `memberdays` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `accumulated_memberdays` | Operational field `accumulated_memberdays` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `current_person_center` | Center component of the composite reference to the related current person record. | `int4` | Yes | No | - | - |
| `current_person_id` | Identifier component of the composite reference to the related current person record. | `int4` | Yes | No | - | - |
| `suspension_internal_note` | Business attribute `suspension_internal_note` used by persons workflows and reporting. | `int4` | Yes | No | - | - |
| `suspension_external_note` | Business attribute `suspension_external_note` used by persons workflows and reporting. | `int4` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `prefer_invoice_by_email` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `member_status` | State indicator used to control lifecycle transitions and filtering. | `int4` | Yes | No | - | [persons_member_status](../master%20tables/persons_member_status.md) |
| `member_status_context` | State indicator used to control lifecycle transitions and filtering. | `int4` | Yes | No | - | - |
| `password_reset_token` | Business attribute `password_reset_token` used by persons workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `password_reset_token_exp` | Business attribute `password_reset_token_exp` used by persons workflows and reporting. | `int8` | Yes | No | - | - |
| `password_reset_token_used` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `fullname_search` | Business attribute `fullname_search` used by persons workflows and reporting. | `tsvector` | Yes | No | - | - |
| `transfers_current_prs_center` | Center component of the composite reference to the related transfers current prs record. | `int4` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(60)` | Yes | No | - | - |
| `transfers_current_prs_id` | Identifier component of the composite reference to the related transfers current prs record. | `int4` | Yes | No | - | - |
| `encrypted_ssn` | Business attribute `encrypted_ssn` used by persons workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `encryption_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `national_id` | Identifier for the related national entity used by this record. | `VARCHAR(100)` | Yes | No | - | - |
| `resident_id` | Identifier for the related resident entity used by this record. | `VARCHAR(100)` | Yes | No | - | - |

# Relations
- Commonly used with: [centers](centers.md) (3073 query files), [subscriptions](subscriptions.md) (2204 query files), [products](products.md) (2203 query files), [person_ext_attrs](person_ext_attrs.md) (1802 query files), [account_receivables](account_receivables.md) (1593 query files), [subscriptiontypes](subscriptiontypes.md) (1156 query files).
- FK-linked tables: outgoing FK to [centers](centers.md), [zipcodes](zipcodes.md); incoming FK from [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [checkins](checkins.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md), [credit_notes](credit_notes.md), [customer_credit_note](customer_credit_note.md), [customer_invoice](customer_invoice.md), [daily_member_status_changes](daily_member_status_changes.md), [data_cleaning_in_line](data_cleaning_in_line.md), [data_cleaning_monitor_period](data_cleaning_monitor_period.md), [data_cleaning_out_line](data_cleaning_out_line.md), [delivery](delivery.md), [documentation_requirements](documentation_requirements.md), [employees](employees.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [invoices](invoices.md), [journalentries](journalentries.md), [messages](messages.md), [participations](participations.md), [person_ext_attrs](person_ext_attrs.md), [person_login_tokens](person_login_tokens.md), [person_staff_groups](person_staff_groups.md), [privilege_cache](privilege_cache.md), [privilege_cache_validity](privilege_cache_validity.md), [public_messages_person](public_messages_person.md), [questionnaire_answer](questionnaire_answer.md), [recurring_participations](recurring_participations.md), [relatives](relatives.md), [secondary_memberships](secondary_memberships.md), [staff_subscribed_centers](staff_subscribed_centers.md), [staff_usage](staff_usage.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [supplier](supplier.md), [task_log](task_log.md), [tasks](tasks.md), [todos](todos.md), [training_programs](training_programs.md), [usage_point_usages](usage_point_usages.md).
- Second-level FK neighborhood includes: [account_trans](account_trans.md), [accountingperiods](accountingperiods.md), [accounts](accounts.md), [activity](activity.md), [activity_staff_configurations](activity_staff_configurations.md), [advance_notices](advance_notices.md), [aggregated_transactions](aggregated_transactions.md), [ar_trans](ar_trans.md), [area_centers](area_centers.md), [bank_account_blocks](bank_account_blocks.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

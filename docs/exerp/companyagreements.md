# companyagreements
Operational table for companyagreements records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 404 query files; common companions include [persons](persons.md), [relatives](relatives.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | Yes | No | - | - |
| `roleid` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`roleid` -> `id`) | - |
| `terms` | Business attribute `terms` used by companyagreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `int4` | No | No | - | [companyagreements_state](../master%20tables/companyagreements_state.md) |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `documentation_required` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `employee_number_required` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `documentation_interval_unit` | Business attribute `documentation_interval_unit` used by companyagreements workflows and reporting. | `int4` | No | No | - | - |
| `documentation_interval` | Business attribute `documentation_interval` used by companyagreements workflows and reporting. | `int4` | Yes | No | - | - |
| `target_employee_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `target_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `contactcenter` | Center component of the composite reference to the related contact record. | `int4` | Yes | No | [persons](persons.md) via (`contactcenter`, `contactid` -> `center`, `id`) | - |
| `contactid` | Identifier component of the composite reference to the related contact record. | `int4` | Yes | No | [persons](persons.md) via (`contactcenter`, `contactid` -> `center`, `id`) | - |
| `own_privileges` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `REF` | Operational field `REF` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `stop_new_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `cash_subscription_stop_date` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `availability` | Operational field `availability` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `web_text` | Business attribute `web_text` used by companyagreements workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `family_corporate_status` | Business classification code used in reporting transformations (for example: CORPORATE_FAMILY, EMPLOYEES, EMPLOYEES_AND_CORPORATE_FAMILY). | `int4` | No | No | - | [companyagreements_family_corporate_status](../master%20tables/companyagreements_family_corporate_status.md) |
| `max_family_corporate` | Business attribute `max_family_corporate` used by companyagreements workflows and reporting. | `int4` | Yes | No | - | - |
| `require_other_payer` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `last_member_update` | Business attribute `last_member_update` used by companyagreements workflows and reporting. | `int8` | No | No | - | - |
| `creation_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `activation_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (389 query files), [relatives](relatives.md) (357 query files), [products](products.md) (294 query files), [subscriptions](subscriptions.md) (285 query files), [centers](centers.md) (256 query files), [subscriptiontypes](subscriptiontypes.md) (210 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [roles](roles.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

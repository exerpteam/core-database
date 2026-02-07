# companyagreements
Operational table for companyagreements records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 404 query files; common companions include [persons](persons.md), [relatives](relatives.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - | `101` |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - | `1001` |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `roleid` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`roleid` -> `id`) | - | `42` |
| `terms` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `STATE` | State code representing the current processing state. | `int4` | No | No | - | - | `1` |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `documentation_required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `employee_number_required` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `documentation_interval_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `documentation_interval` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `target_employee_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `target_time` | Epoch timestamp for target. | `int8` | Yes | No | - | - | `1738281600000` |
| `contactcenter` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`contactcenter`, `contactid` -> `center`, `id`) | - | `42` |
| `contactid` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`contactcenter`, `contactid` -> `center`, `id`) | - | `42` |
| `own_privileges` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `REF` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `stop_new_date` | Date for stop new. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `cash_subscription_stop_date` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `availability` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `web_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `family_corporate_status` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `max_family_corporate` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `require_other_payer` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `last_member_update` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `creation_date` | Date for creation. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `start_date` | Date when the record becomes effective. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `activation_date` | Date for activation. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [persons](persons.md) (389 query files), [relatives](relatives.md) (357 query files), [products](products.md) (294 query files), [subscriptions](subscriptions.md) (285 query files), [centers](centers.md) (256 query files), [subscriptiontypes](subscriptiontypes.md) (210 query files).
- FK-linked tables: outgoing FK to [persons](persons.md), [roles](roles.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

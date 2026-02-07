# relatives
Operational table for relatives records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 928 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that scopes the record to a center. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used as a child/sub-record identifier. | `int4` | No | Yes | - | - |
| `rtype` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `relativecenter` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `relativeid` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `relativesubid` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - |
| `expiredate` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - |
| `family_allow_card_on_file` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (888 query files), [subscriptions](subscriptions.md) (667 query files), [products](products.md) (551 query files), [centers](centers.md) (550 query files), [person_ext_attrs](person_ext_attrs.md) (463 query files), [subscriptiontypes](subscriptiontypes.md) (423 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

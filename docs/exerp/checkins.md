# checkins
Operational table for checkins records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 541 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `person_center` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Foreign key field linking this record to `persons`. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `checkin_center` | Center part of the reference to related checkin data. | `int4` | No | No | - | - |
| `checkin_time` | Epoch timestamp for checkin. | `int8` | No | No | - | - |
| `checkout_time` | Epoch timestamp for checkout. | `int8` | Yes | No | - | - |
| `checked_out` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `card_checked_in` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `checkin_result` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `identity_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `origin` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `checkout_reminder_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `person_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - |
| `checkin_failed_reason` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (486 query files), [centers](centers.md) (392 query files), [subscriptions](subscriptions.md) (237 query files), [person_ext_attrs](person_ext_attrs.md) (236 query files), [products](products.md) (206 query files), [subscriptiontypes](subscriptiontypes.md) (119 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.

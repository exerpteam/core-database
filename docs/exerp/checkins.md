# checkins
Operational table for checkins records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 541 query files; common companions include [persons](persons.md), [centers](centers.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | - |
| `checkin_center` | Operational field `checkin_center` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `checkin_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `checkout_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `checked_out` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `card_checked_in` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `checkin_result` | Operational field `checkin_result` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `identity_method` | Business attribute `identity_method` used by checkins workflows and reporting. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `origin` | Business attribute `origin` used by checkins workflows and reporting. | `int4` | Yes | No | - | - |
| `checkout_reminder_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `person_type` | Classification code describing the person type category (for example: CORPORATE, Corporate, FAMILY, FRIEND). | `int4` | No | No | - | - |
| `checkin_failed_reason` | Business attribute `checkin_failed_reason` used by checkins workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (486 query files), [centers](centers.md) (392 query files), [subscriptions](subscriptions.md) (237 query files), [person_ext_attrs](person_ext_attrs.md) (236 query files), [products](products.md) (206 query files), [subscriptiontypes](subscriptiontypes.md) (119 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [clipcards](clipcards.md), [companyagreements](companyagreements.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.

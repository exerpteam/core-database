# relatives
Operational table for relatives records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 928 query files; common companions include [persons](persons.md), [subscriptions](subscriptions.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [persons](persons.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `rtype` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [relatives_rtype](../master%20tables/relatives_rtype.md) |
| `relativecenter` | Center component of the composite reference to the related relative record. | `int4` | No | No | - | - |
| `relativeid` | Identifier component of the composite reference to the related relative record. | `int4` | No | No | - | - |
| `relativesubid` | Operational field `relativesubid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | No | No | - | [relatives_status](../master%20tables/relatives_status.md) |
| `expiredate` | Business attribute `expiredate` used by relatives workflows and reporting. | `DATE` | Yes | No | - | - |
| `family_allow_card_on_file` | Business attribute `family_allow_card_on_file` used by relatives workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (888 query files), [subscriptions](subscriptions.md) (667 query files), [products](products.md) (551 query files), [centers](centers.md) (550 query files), [person_ext_attrs](person_ext_attrs.md) (463 query files), [subscriptiontypes](subscriptiontypes.md) (423 query files).
- FK-linked tables: outgoing FK to [persons](persons.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [attends](attends.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_restrictions](booking_restrictions.md), [bookings](bookings.md), [cashcollectioncases](cashcollectioncases.md), [centers](centers.md), [checkins](checkins.md), [clipcards](clipcards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

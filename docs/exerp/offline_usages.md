# offline_usages
Operational table for offline usages records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 6 query files; common companions include [checkins](checkins.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `offline_usage_packet_id` | Identifier of the related offline usage packets record used by this row. | `int4` | No | No | [offline_usage_packets](offline_usage_packets.md) via (`offline_usage_packet_id` -> `id`) | - |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `TIMESTAMP` | Operational field `TIMESTAMP` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `card_identity` | Business attribute `card_identity` used by offline usages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `card_identity_method` | Business attribute `card_identity_method` used by offline usages workflows and reporting. | `int4` | No | No | - | - |
| `pincode` | Operational field `pincode` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `reader_device_id` | Identifier for the related reader device entity used by this record. | `int4` | No | No | - | - |
| `reader_device_sub_id` | Identifier for the related reader device sub entity used by this record. | `text(2147483647)` | Yes | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | - | - |
| `usage_point_action_center` | Center component of the composite reference to the related usage point action record. | `int4` | Yes | No | - | - |
| `usage_point_action_id` | Identifier component of the composite reference to the related usage point action record. | `int4` | Yes | No | - | - |
| `client_id` | Identifier for the related client entity used by this record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) |
| `event_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | - |
| `device_part` | Business attribute `device_part` used by offline usages workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [checkins](checkins.md) (6 query files), [persons](persons.md) (6 query files), [products](products.md) (6 query files), [subscriptions](subscriptions.md) (6 query files), [extract](extract.md) (2 query files), [entityidentifiers](entityidentifiers.md) (2 query files).
- FK-linked tables: outgoing FK to [offline_usage_packets](offline_usage_packets.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.

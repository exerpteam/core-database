# offline_usages
Operational table for offline usages records in the Exerp schema. It is typically used where rows are center-scoped; it appears in approximately 6 query files; common companions include [checkins](checkins.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `offline_usage_packet_id` | Foreign key field linking this record to `offline_usage_packets`. | `int4` | No | No | [offline_usage_packets](offline_usage_packets.md) via (`offline_usage_packet_id` -> `id`) | - | `1001` |
| `center` | Center identifier associated with the record. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) | `101` |
| `TIMESTAMP` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `card_identity` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `card_identity_method` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `pincode` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `reader_device_id` | Identifier of the related reader device record. | `int4` | No | No | - | - | `1001` |
| `reader_device_sub_id` | Identifier of the related reader device sub record. | `text(2147483647)` | Yes | No | - | - | `1001` |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - | `1001` |
| `usage_point_action_center` | Center part of the reference to related usage point action data. | `int4` | Yes | No | - | - | `101` |
| `usage_point_action_id` | Identifier of the related usage point action record. | `int4` | Yes | No | - | - | `1001` |
| `client_id` | Identifier of the related client record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) | `1001` |
| `event_type` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `device_part` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [checkins](checkins.md) (6 query files), [persons](persons.md) (6 query files), [products](products.md) (6 query files), [subscriptions](subscriptions.md) (6 query files), [EXTRACT](EXTRACT.md) (2 query files), [entityidentifiers](entityidentifiers.md) (2 query files).
- FK-linked tables: outgoing FK to [offline_usage_packets](offline_usage_packets.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.

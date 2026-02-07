# offline_usage_packets
Operational table for offline usage packets records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | No | No | - | - | `EXT-1001` |
| `received` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `client_id` | Identifier of the related client record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) | `1001` |
| `status` | Lifecycle status code for the record. | `int4` | No | No | - | - | `1` |

# Relations
- FK-linked tables: incoming FK from [offline_usages](offline_usages.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

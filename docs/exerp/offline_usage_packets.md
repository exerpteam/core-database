# offline_usage_packets
Operational table for offline usage packets records in the Exerp schema. It is typically used where lifecycle state codes are present.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | No | No | - | - |
| `received` | Operational field `received` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `client_id` | Identifier for the related client entity used by this record. | `int4` | No | No | - | [clients](clients.md) via (`client_id` -> `id`) |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `int4` | No | No | - | - |

# Relations
- FK-linked tables: incoming FK from [offline_usages](offline_usages.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

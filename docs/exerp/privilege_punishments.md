# privilege_punishments
Operational table for privilege punishments records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 17 query files; common companions include [privilege_grants](privilege_grants.md), [masterproductregister](masterproductregister.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `restriction_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `restriction_value` | Business attribute `restriction_value` used by privilege punishments workflows and reporting. | `int4` | Yes | No | - | - |
| `restriction_unit` | Business attribute `restriction_unit` used by privilege punishments workflows and reporting. | `int4` | Yes | No | - | - |
| `restrict_by_access_group` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `service_id` | Identifier for the related service entity used by this record. | `text(2147483647)` | No | No | - | - |
| `configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (16 query files), [masterproductregister](masterproductregister.md) (13 query files), [privilege_sets](privilege_sets.md) (11 query files), [centers](centers.md) (11 query files), [extract](extract.md) (7 query files), [product_account_configurations](product_account_configurations.md) (7 query files).
- FK-linked tables: incoming FK from [privilege_grants](privilege_grants.md).
- Second-level FK neighborhood includes: [privilege_cache](privilege_cache.md), [privilege_sets](privilege_sets.md), [privilege_usages](privilege_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

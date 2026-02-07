# privilege_punishments
Operational table for privilege punishments records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 17 query files; common companions include [privilege_grants](privilege_grants.md), [masterproductregister](masterproductregister.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `restriction_count` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `restriction_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `restriction_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `restrict_by_access_group` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `service_id` | Identifier of the related service record. | `text(2147483647)` | No | No | - | - |
| `configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (16 query files), [masterproductregister](masterproductregister.md) (13 query files), [privilege_sets](privilege_sets.md) (11 query files), [centers](centers.md) (11 query files), [extract](extract.md) (7 query files), [product_account_configurations](product_account_configurations.md) (7 query files).
- FK-linked tables: incoming FK from [privilege_grants](privilege_grants.md).
- Second-level FK neighborhood includes: [privilege_cache](privilege_cache.md), [privilege_sets](privilege_sets.md), [privilege_usages](privilege_usages.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

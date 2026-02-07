# privilege_receiver_groups
Operational table for privilege receiver groups records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 142 query files; common companions include [privilege_grants](privilege_grants.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `rgtype` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `plugin_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `plugin_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `endtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - |
| `web_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `available_scopes` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `free_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Epoch timestamp when the row was created. | `int8` | Yes | No | - | - |
| `creator_id` | Identifier of the related creator record. | `int4` | Yes | No | - | - |
| `creator_center` | Center part of the reference to related creator data. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |
| `last_editor_id` | Identifier of the related last editor record. | `int4` | Yes | No | - | - |
| `last_editor_center` | Center part of the reference to related last editor data. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (110 query files), [products](products.md) (103 query files), [startup_campaign](startup_campaign.md) (103 query files), [privilege_usages](privilege_usages.md) (101 query files), [centers](centers.md) (88 query files), [campaign_codes](campaign_codes.md) (70 query files).
- FK-linked tables: incoming FK from [receiver_group_caches](receiver_group_caches.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.

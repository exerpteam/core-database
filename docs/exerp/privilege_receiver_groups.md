# privilege_receiver_groups
Operational table for privilege receiver groups records in the Exerp schema. It is typically used where change-tracking timestamps are available; it appears in approximately 142 query files; common companions include [privilege_grants](privilege_grants.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `rgtype` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | Yes | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | Yes | No | - | - |
| `blocked` | Boolean flag indicating whether the record is blocked from normal use. | `bool` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `plugin_name` | Business attribute `plugin_name` used by privilege receiver groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `plugin_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `endtime` | Operational field `endtime` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `web_text` | Business attribute `web_text` used by privilege receiver groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `available_scopes` | Business attribute `available_scopes` used by privilege receiver groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_name` | Operational field `plugin_codes_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `free_text` | Business attribute `free_text` used by privilege receiver groups workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `creation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `creator_id` | Identifier component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `creator_center` | Center component of the composite reference to the creator staff member. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `last_editor_id` | Identifier component of the composite reference to the related last editor record. | `int4` | Yes | No | - | - |
| `last_editor_center` | Center component of the composite reference to the related last editor record. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [privilege_grants](privilege_grants.md) (110 query files), [products](products.md) (103 query files), [startup_campaign](startup_campaign.md) (103 query files), [privilege_usages](privilege_usages.md) (101 query files), [centers](centers.md) (88 query files), [campaign_codes](campaign_codes.md) (70 query files).
- FK-linked tables: incoming FK from [receiver_group_caches](receiver_group_caches.md).
- Interesting data points: change timestamps support incremental extraction and reconciliation.

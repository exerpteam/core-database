# privilege_usages
Operational table for privilege usages records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 378 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `misuse_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `grant_id` | Foreign key field linking this record to `privilege_grants`. | `int4` | Yes | No | [privilege_grants](privilege_grants.md) via (`grant_id` -> `id`) | - | `1001` |
| `privilege_id` | Identifier of the related privilege record. | `int4` | No | No | - | - | `1001` |
| `privilege_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `source_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `source_center` | Center part of the reference to related source data. | `int4` | Yes | No | - | - | `101` |
| `source_id` | Identifier of the related source record. | `int4` | Yes | No | - | - | `1001` |
| `source_subid` | Sub-identifier for related source detail rows. | `int4` | Yes | No | - | - | `1` |
| `target_service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `target_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `target_center` | Center part of the reference to related target data. | `int4` | Yes | No | - | - | `101` |
| `target_id` | Identifier of the related target record. | `int4` | Yes | No | - | - | `1001` |
| `target_subid` | Sub-identifier for related target detail rows. | `int4` | Yes | No | - | - | `1` |
| `target_start_time` | Epoch timestamp for target start. | `int8` | Yes | No | - | - | `1738281600000` |
| `deduction_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `deduction_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `deduction_usage` | Foreign key field linking this record to `privilege_usages`. | `int4` | Yes | No | [privilege_usages](privilege_usages.md) via (`deduction_usage` -> `id`) | - | `42` |
| `deduction_time` | Epoch timestamp for deduction. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `plan_time` | Epoch timestamp for plan. | `int8` | No | No | - | - | `1738281600000` |
| `use_time` | Epoch timestamp for use. | `int8` | Yes | No | - | - | `1738281600000` |
| `cancel_time` | Epoch timestamp for cancel. | `int8` | Yes | No | - | - | `1738281600000` |
| `punishment_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `campaign_code_id` | Foreign key field linking this record to `campaign_codes`. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - | `1001` |
| `COUNT` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) | `101` |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - | `1001` |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - | `42` |

# Relations
- Commonly used with: [products](products.md) (306 query files), [persons](persons.md) (299 query files), [subscriptions](subscriptions.md) (227 query files), [centers](centers.md) (224 query files), [privilege_grants](privilege_grants.md) (209 query files), [invoice_lines_mt](invoice_lines_mt.md) (132 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [privilege_grants](privilege_grants.md), [privilege_usages](privilege_usages.md); incoming FK from [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [campaign_code_usages](campaign_code_usages.md), [privilege_cache](privilege_cache.md), [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

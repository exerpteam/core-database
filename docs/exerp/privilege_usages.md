# privilege_usages
Operational table for privilege usages records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 378 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `misuse_state` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `grant_id` | Foreign key field linking this record to `privilege_grants`. | `int4` | Yes | No | [privilege_grants](privilege_grants.md) via (`grant_id` -> `id`) | - |
| `privilege_id` | Identifier of the related privilege record. | `int4` | No | No | - | - |
| `privilege_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `source_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `source_center` | Center part of the reference to related source data. | `int4` | Yes | No | - | - |
| `source_id` | Identifier of the related source record. | `int4` | Yes | No | - | - |
| `source_subid` | Sub-identifier for related source detail rows. | `int4` | Yes | No | - | - |
| `target_service` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `target_globalid` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `target_center` | Center part of the reference to related target data. | `int4` | Yes | No | - | - |
| `target_id` | Identifier of the related target record. | `int4` | Yes | No | - | - |
| `target_subid` | Sub-identifier for related target detail rows. | `int4` | Yes | No | - | - |
| `target_start_time` | Epoch timestamp for target start. | `int8` | Yes | No | - | - |
| `deduction_quantity` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `deduction_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `deduction_usage` | Foreign key field linking this record to `privilege_usages`. | `int4` | Yes | No | [privilege_usages](privilege_usages.md) via (`deduction_usage` -> `id`) | - |
| `deduction_time` | Epoch timestamp for deduction. | `text(2147483647)` | Yes | No | - | - |
| `plan_time` | Epoch timestamp for plan. | `int8` | No | No | - | - |
| `use_time` | Epoch timestamp for use. | `int8` | Yes | No | - | - |
| `cancel_time` | Epoch timestamp for cancel. | `int8` | Yes | No | - | - |
| `punishment_key` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `campaign_code_id` | Foreign key field linking this record to `campaign_codes`. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |
| `COUNT` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - |
| `person_center` | Center part of the reference to related person data. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier of the related person record. | `int4` | Yes | No | - | - |
| `last_modified` | Epoch timestamp for the latest update on the row. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (306 query files), [persons](persons.md) (299 query files), [subscriptions](subscriptions.md) (227 query files), [centers](centers.md) (224 query files), [privilege_grants](privilege_grants.md) (209 query files), [invoice_lines_mt](invoice_lines_mt.md) (132 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [privilege_grants](privilege_grants.md), [privilege_usages](privilege_usages.md); incoming FK from [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [campaign_code_usages](campaign_code_usages.md), [privilege_cache](privilege_cache.md), [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

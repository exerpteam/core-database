# privilege_usages
Operational table for privilege usages records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 378 query files; common companions include [products](products.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `misuse_state` | State indicator used to control lifecycle transitions and filtering. | `text(2147483647)` | No | No | - | - |
| `grant_id` | Identifier of the related privilege grants record used by this row. | `int4` | Yes | No | [privilege_grants](privilege_grants.md) via (`grant_id` -> `id`) | - |
| `privilege_id` | Identifier for the related privilege entity used by this record. | `int4` | No | No | - | - |
| `privilege_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `source_globalid` | Business attribute `source_globalid` used by privilege usages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `source_center` | Center component of the composite reference to the related source record. | `int4` | Yes | No | - | - |
| `source_id` | Identifier component of the composite reference to the related source record. | `int4` | Yes | No | - | - |
| `source_subid` | Operational field `source_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `target_service` | Operational field `target_service` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `target_globalid` | Business attribute `target_globalid` used by privilege usages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `target_center` | Center component of the composite reference to the related target record. | `int4` | Yes | No | - | - |
| `target_id` | Identifier component of the composite reference to the related target record. | `int4` | Yes | No | - | - |
| `target_subid` | Operational field `target_subid` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `target_start_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `deduction_quantity` | Business attribute `deduction_quantity` used by privilege usages workflows and reporting. | `int4` | Yes | No | - | - |
| `deduction_key` | Business attribute `deduction_key` used by privilege usages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `deduction_usage` | Identifier referencing another record in the same table hierarchy. | `int4` | Yes | No | [privilege_usages](privilege_usages.md) via (`deduction_usage` -> `id`) | - |
| `deduction_time` | Timestamp used for event ordering and operational tracking. | `text(2147483647)` | Yes | No | - | - |
| `plan_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `use_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `cancel_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `punishment_key` | Business attribute `punishment_key` used by privilege usages workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `campaign_code_id` | Identifier of the related campaign codes record used by this row. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |
| `COUNT` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `person_center` | Center component of the composite reference to the related person. | `int4` | Yes | No | - | [persons](persons.md) via (`person_center`, `person_id` -> `center`, `id`) |
| `person_id` | Identifier component of the composite reference to the related person. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (306 query files), [persons](persons.md) (299 query files), [subscriptions](subscriptions.md) (227 query files), [centers](centers.md) (224 query files), [privilege_grants](privilege_grants.md) (209 query files), [invoice_lines_mt](invoice_lines_mt.md) (132 query files).
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [privilege_grants](privilege_grants.md), [privilege_usages](privilege_usages.md); incoming FK from [privilege_usages](privilege_usages.md).
- Second-level FK neighborhood includes: [campaign_code_usages](campaign_code_usages.md), [privilege_cache](privilege_cache.md), [privilege_punishments](privilege_punishments.md), [privilege_sets](privilege_sets.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

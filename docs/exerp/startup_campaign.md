# startup_campaign
Operational table for startup campaign records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 171 query files; common companions include [products](products.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `plugin_name` | Business attribute `plugin_name` used by startup campaign workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `plugin_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `endtime` | Operational field `endtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `period_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `period_unit` | Business attribute `period_unit` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `period_value` | Business attribute `period_value` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `period_round` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `period_start` | Business attribute `period_start` used by startup campaign workflows and reporting. | `DATE` | Yes | No | - | - |
| `period_end` | Business attribute `period_end` used by startup campaign workflows and reporting. | `DATE` | Yes | No | - | - |
| `web_text` | Business attribute `web_text` used by startup campaign workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `available_scopes` | Business attribute `available_scopes` used by startup campaign workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_name` | Operational field `plugin_codes_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `free_period_unit` | Business attribute `free_period_unit` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `free_period_value` | Business attribute `free_period_value` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `free_period_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | Yes | No | - | - |
| `free_period_extends_binding` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `campaign_apply_for` | Business attribute `campaign_apply_for` used by startup campaign workflows and reporting. | `VARCHAR(50)` | No | No | - | - |
| `privilege_change_binding_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(50)` | No | No | - | - |
| `relative_to_start_date_value` | Business attribute `relative_to_start_date_value` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `relative_to_start_date_unit` | Business attribute `relative_to_start_date_unit` used by startup campaign workflows and reporting. | `int4` | Yes | No | - | - |
| `relative_to_start_date_round` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `fixed_binding_end_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |

# Relations
- Commonly used with: [products](products.md) (131 query files), [privilege_grants](privilege_grants.md) (124 query files), [privilege_usages](privilege_usages.md) (120 query files), [subscriptions](subscriptions.md) (108 query files), [centers](centers.md) (104 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (103 query files).
- FK-linked tables: incoming FK from [startup_campaign_subscription](startup_campaign_subscription.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [recurring_participations](recurring_participations.md), [subscription_addon](subscription_addon.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

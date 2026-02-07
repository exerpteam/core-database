# startup_campaign
Operational table for startup campaign records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 171 query files; common companions include [products](products.md), [privilege_grants](privilege_grants.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `plugin_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `plugin_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `endtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `1738281600000` |
| `period_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `period_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `period_round` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `period_start` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `period_end` | Calendar date used for lifecycle and reporting filters. | `DATE` | Yes | No | - | - | `2025-01-31` |
| `web_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `available_scopes` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `plugin_codes_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Example Name` |
| `plugin_codes_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `free_period_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `free_period_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `free_period_type` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `free_period_extends_binding` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `campaign_apply_for` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Sample value` |
| `privilege_change_binding_type` | Text field containing descriptive or reference information. | `VARCHAR(50)` | No | No | - | - | `Sample value` |
| `relative_to_start_date_value` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `relative_to_start_date_unit` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `relative_to_start_date_round` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `fixed_binding_end_date` | Date for fixed binding end. | `DATE` | Yes | No | - | - | `2025-01-31` |

# Relations
- Commonly used with: [products](products.md) (131 query files), [privilege_grants](privilege_grants.md) (124 query files), [privilege_usages](privilege_usages.md) (120 query files), [subscriptions](subscriptions.md) (108 query files), [centers](centers.md) (104 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (103 query files).
- FK-linked tables: incoming FK from [startup_campaign_subscription](startup_campaign_subscription.md), [subscription_retention_campaigns](subscription_retention_campaigns.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [recurring_participations](recurring_participations.md), [subscription_addon](subscription_addon.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

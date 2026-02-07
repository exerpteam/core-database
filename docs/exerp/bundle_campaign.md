# bundle_campaign
Operational table for bundle campaign records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 9 query files; common companions include [invoices](invoices.md), [privilege_receiver_groups](privilege_receiver_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - |
| `starttime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `endtime` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - |
| `auto_add_products` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `price_modification_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `price_modification_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_modification_one_time` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - |
| `prompt_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - |
| `prompt_text` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_name` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_config` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - |
| `basket_threshold` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | Yes | No | - | - |

# Relations
- Commonly used with: [invoices](invoices.md) (5 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (4 query files), [centers](centers.md) (4 query files), [persons](persons.md) (4 query files), [startup_campaign](startup_campaign.md) (3 query files), [product_group](product_group.md) (3 query files).
- FK-linked tables: incoming FK from [bundle_campaign_product](bundle_campaign_product.md), [bundle_campaign_usages](bundle_campaign_usages.md).
- Second-level FK neighborhood includes: [invoice_lines_mt](invoice_lines_mt.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

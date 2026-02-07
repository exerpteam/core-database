# bundle_campaign
Operational table for bundle campaign records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 9 query files; common companions include [invoices](invoices.md), [privilege_receiver_groups](privilege_receiver_groups.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `starttime` | Operational field `starttime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `endtime` | Operational field `endtime` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `auto_add_products` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `price_modification_name` | Monetary value used in financial calculation, settlement, or reporting. | `text(2147483647)` | Yes | No | - | - |
| `price_modification_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `price_modification_one_time` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `prompt_type` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |
| `prompt_text` | Business attribute `prompt_text` used by bundle campaign workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_name` | Operational field `plugin_codes_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `plugin_codes_config` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `basket_threshold` | Business attribute `basket_threshold` used by bundle campaign workflows and reporting. | `NUMERIC(0,0)` | Yes | No | - | - |

# Relations
- Commonly used with: [invoices](invoices.md) (5 query files), [privilege_receiver_groups](privilege_receiver_groups.md) (4 query files), [centers](centers.md) (4 query files), [persons](persons.md) (4 query files), [startup_campaign](startup_campaign.md) (3 query files), [product_group](product_group.md) (3 query files).
- FK-linked tables: incoming FK from [bundle_campaign_product](bundle_campaign_product.md), [bundle_campaign_usages](bundle_campaign_usages.md).
- Second-level FK neighborhood includes: [invoice_lines_mt](invoice_lines_mt.md).
- Interesting data points: `status`/`state` fields are typically used for active/inactive lifecycle filtering.

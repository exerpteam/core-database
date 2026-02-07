# installment_plan_configs
Configuration table for installment plan configs behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [installment_plans](installment_plans.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `text(2147483647)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `quantity` | Operational field `quantity` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | No | No | - | - |
| `type` | Classification code describing the type category (for example: AMERICAN_EXPRESS, Add, AmericanExpress, CHANGE). | `text(2147483647)` | No | No | - | - |
| `rounding` | Business attribute `rounding` used by installment plan configs workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `first_inst_paid_in_pos` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `contract_template_id` | Identifier for the related contract template entity used by this record. | `int4` | Yes | No | - | - |
| `admin_fee_product` | Identifier of the related masterproductregister record used by this row. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`admin_fee_product` -> `id`) | - |
| `roles` | Operational field `roles` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `text(2147483647)` | No | No | - | - |
| `created` | Operational field `created` used in query filtering and reporting transformations. | `int8` | No | No | - | - |
| `modified` | Business attribute `modified` used by installment plan configs workflows and reporting. | `int8` | No | No | - | - |
| `deleted` | Operational field `deleted` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `version` | Operational field `version` used in query filtering and reporting transformations. | `int8` | Yes | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `installment_plan_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(30)` | No | No | - | - |
| `threshold` | Business attribute `threshold` used by installment plan configs workflows and reporting. | `int4` | No | No | - | - |
| `property_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(50)` | Yes | No | - | - |
| `property_configuration` | Serialized configuration payload used by runtime processing steps. | `bytea` | Yes | No | - | - |
| `initial_amount` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | No | No | - | - |
| `ref_type` | Classification code describing the ref type category (for example: PERSON). | `VARCHAR(20)` | Yes | No | - | - |
| `ref_globalid` | Operational field `ref_globalid` used in query filtering and reporting transformations. | `VARCHAR(40)` | Yes | No | - | - |
| `ref_center` | Center component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_id` | Identifier component of the composite reference to the related ref record. | `int4` | Yes | No | - | - |
| `ref_program_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `available_on_web` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |

# Relations
- Commonly used with: [installment_plans](installment_plans.md) (5 query files), [account_receivables](account_receivables.md) (4 query files), [person_ext_attrs](person_ext_attrs.md) (4 query files), [persons](persons.md) (4 query files), [products](products.md) (4 query files), [ar_trans](ar_trans.md) (3 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md); incoming FK from [installment_plans](installment_plans.md), [mpr_ipc](mpr_ipc.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [ar_trans](ar_trans.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_lines_mt](credit_note_lines_mt.md), [employees](employees.md), [frequent_products_item](frequent_products_item.md), [invoice_lines_mt](invoice_lines_mt.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [persons](persons.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

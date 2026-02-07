# installment_plan_configs
Configuration table for installment plan configs behavior and defaults. It is typically used where lifecycle state codes are present; it appears in approximately 5 query files; common companions include [installment_plans](installment_plans.md), [account_receivables](account_receivables.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `scope_type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `name` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `Example Name` |
| `quantity` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `type` | Text field containing descriptive or reference information. | `text(2147483647)` | No | No | - | - | `1` |
| `rounding` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `first_inst_paid_in_pos` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `contract_template_id` | Identifier of the related contract template record. | `int4` | Yes | No | - | - | `1001` |
| `admin_fee_product` | Foreign key field linking this record to `masterproductregister`. | `int4` | Yes | No | [masterproductregister](masterproductregister.md) via (`admin_fee_product` -> `id`) | - | `42` |
| `roles` | Text field containing descriptive or reference information. | `text(2147483647)` | Yes | No | - | - | `Sample value` |
| `STATE` | State code representing the current processing state. | `text(2147483647)` | No | No | - | - | `1` |
| `created` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `modified` | Numeric field used for identifiers, counters, or coded values. | `int8` | No | No | - | - | `42` |
| `deleted` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `version` | Numeric field used for identifiers, counters, or coded values. | `int8` | Yes | No | - | - | `42` |
| `external_id` | External/business identifier used in integrations and exports. | `text(2147483647)` | Yes | No | - | - | `EXT-1001` |
| `installment_plan_type` | Text field containing descriptive or reference information. | `VARCHAR(30)` | No | No | - | - | `Sample value` |
| `threshold` | Numeric field used for identifiers, counters, or coded values. | `int4` | No | No | - | - | `42` |
| `property_type` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Sample value` |
| `property_configuration` | Table field used by operational and reporting workloads. | `bytea` | Yes | No | - | - | `N/A` |
| `initial_amount` | Numeric field used for identifiers, counters, or coded values. | `NUMERIC(0,0)` | No | No | - | - | `99.95` |
| `ref_type` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `ref_globalid` | Text field containing descriptive or reference information. | `VARCHAR(40)` | Yes | No | - | - | `Sample value` |
| `ref_center` | Center part of the reference to related ref data. | `int4` | Yes | No | - | - | `101` |
| `ref_id` | Identifier of the related ref record. | `int4` | Yes | No | - | - | `1001` |
| `ref_program_type_id` | Identifier of the related ref program type record. | `int4` | Yes | No | - | - | `1001` |
| `available_on_web` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |

# Relations
- Commonly used with: [installment_plans](installment_plans.md) (5 query files), [account_receivables](account_receivables.md) (4 query files), [person_ext_attrs](person_ext_attrs.md) (4 query files), [persons](persons.md) (4 query files), [products](products.md) (4 query files), [ar_trans](ar_trans.md) (3 query files).
- FK-linked tables: outgoing FK to [masterproductregister](masterproductregister.md); incoming FK from [installment_plans](installment_plans.md), [mpr_ipc](mpr_ipc.md).
- Second-level FK neighborhood includes: [add_on_product_definition](add_on_product_definition.md), [ar_trans](ar_trans.md), [cashregistertransactions](cashregistertransactions.md), [credit_note_lines_mt](credit_note_lines_mt.md), [employees](employees.md), [frequent_products_item](frequent_products_item.md), [invoice_lines_mt](invoice_lines_mt.md), [master_prod_and_prod_grp_link](master_prod_and_prod_grp_link.md), [masterproductgroups](masterproductgroups.md), [persons](persons.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

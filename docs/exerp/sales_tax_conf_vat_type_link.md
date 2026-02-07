# sales_tax_conf_vat_type_link
Bridge table that links related entities for sales tax conf vat type link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `sales_tax_configuration_id` | Identifier of the related sales tax configuration record used by this row. | `int4` | No | No | [sales_tax_configuration](sales_tax_configuration.md) via (`sales_tax_configuration_id` -> `id`) | - |
| `master_vat_type_global_id` | Type code defining the business category used for workflow and reporting logic. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [sales_tax_configuration](sales_tax_configuration.md).

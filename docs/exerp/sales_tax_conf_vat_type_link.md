# sales_tax_conf_vat_type_link
Bridge table that links related entities for sales tax conf vat type link relationships.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - |
| `sales_tax_configuration_id` | Foreign key field linking this record to `sales_tax_configuration`. | `int4` | No | No | [sales_tax_configuration](sales_tax_configuration.md) via (`sales_tax_configuration_id` -> `id`) | - |
| `master_vat_type_global_id` | Identifier of the related master vat type global record. | `text(2147483647)` | No | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [sales_tax_configuration](sales_tax_configuration.md).

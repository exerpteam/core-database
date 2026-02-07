# custom_journal_document_types
Operational table for custom journal document types records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK | Example value |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `int4` | No | Yes | - | - | `1001` |
| `definition_key` | Numeric field used for identifiers, counters, or coded values. | `int4` | Yes | No | - | - | `42` |
| `scope_type` | Text field containing descriptive or reference information. | `VARCHAR(1)` | No | No | - | - | `Sample value` |
| `scope_id` | Identifier of the related scope record. | `int4` | No | No | - | - | `1001` |
| `STATE` | State code representing the current processing state. | `VARCHAR(10)` | Yes | No | - | - | `1` |
| `name` | Text field containing descriptive or reference information. | `VARCHAR(50)` | Yes | No | - | - | `Example Name` |
| `override_name` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `external_id` | External/business identifier used in integrations and exports. | `VARCHAR(200)` | Yes | No | - | - | `EXT-1001` |
| `override_external_id` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `EXT-1001` |
| `validity_period` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `validity_period_start` | Text field containing descriptive or reference information. | `VARCHAR(20)` | Yes | No | - | - | `Sample value` |
| `validity_period_overr_role_key` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`validity_period_overr_role_key` -> `id`) | - | `42` |
| `override_validity_period` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `mandatory_attachment` | Boolean flag used in business rules and filtering logic. | `bool` | Yes | No | - | - | `true` |
| `override_mandatory_attachment` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `required_role_key` | Foreign key field linking this record to `roles`. | `int4` | Yes | No | [roles](roles.md) via (`required_role_key` -> `id`) | - | `42` |
| `override_required_role_key` | Boolean flag used in business rules and filtering logic. | `bool` | No | No | - | - | `true` |
| `availability` | Text field containing descriptive or reference information. | `VARCHAR(2000)` | Yes | No | - | - | `Sample value` |
| `expiration_date` | Date for expiration. | `DATE` | Yes | No | - | - | `2025-01-31` |

# Relations
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [documentation_settings](documentation_settings.md), [employeesroles](employeesroles.md), [EXTRACT](EXTRACT.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

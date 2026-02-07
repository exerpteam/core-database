# custom_journal_document_types
Operational table for custom journal document types records in the Exerp schema. It is typically used where lifecycle state codes are present; it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `definition_key` | Operational field `definition_key` used in query filtering and reporting transformations. | `int4` | Yes | No | - | - |
| `scope_type` | Classification code describing the scope type category (for example: AREA, CENTER, GLOBAL, System). | `VARCHAR(1)` | No | No | - | - |
| `scope_id` | Identifier of the scoped entity selected by `scope_type`. | `int4` | No | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(10)` | Yes | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `VARCHAR(50)` | Yes | No | - | - |
| `override_name` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `external_id` | External business identifier used for integration and cross-system matching. | `VARCHAR(200)` | Yes | No | - | - |
| `override_external_id` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `validity_period` | Business attribute `validity_period` used by custom journal document types workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `validity_period_start` | Business attribute `validity_period_start` used by custom journal document types workflows and reporting. | `VARCHAR(20)` | Yes | No | - | - |
| `validity_period_overr_role_key` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`validity_period_overr_role_key` -> `id`) | - |
| `override_validity_period` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `mandatory_attachment` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `override_mandatory_attachment` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `required_role_key` | Identifier of the related roles record used by this row. | `int4` | Yes | No | [roles](roles.md) via (`required_role_key` -> `id`) | - |
| `override_required_role_key` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `availability` | Operational field `availability` used in query filtering and reporting transformations. | `VARCHAR(2000)` | Yes | No | - | - |
| `expiration_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |

# Relations
- FK-linked tables: outgoing FK to [roles](roles.md); incoming FK from [dc_st_to_cust_jrnl_dc_tp_links](dc_st_to_cust_jrnl_dc_tp_links.md).
- Second-level FK neighborhood includes: [companyagreements](companyagreements.md), [documentation_settings](documentation_settings.md), [employeesroles](employeesroles.md), [extract](extract.md), [extract_group_and_role_link](extract_group_and_role_link.md), [impliedemployeeroles](impliedemployeeroles.md), [journalentry_and_role_link](journalentry_and_role_link.md), [kpi_group_and_role_link](kpi_group_and_role_link.md), [masterproductgroups](masterproductgroups.md), [products](products.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

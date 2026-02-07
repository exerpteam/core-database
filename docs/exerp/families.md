# families
Operational table for families records in the Exerp schema. It is typically used where rows are center-scoped; lifecycle state codes are present; it appears in approximately 7 query files; common companions include [centers](centers.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Operational field `center` used in query filtering and reporting transformations. | `int4` | No | No | - | [centers](centers.md) via (`center` -> `id`) |
| `family_name` | Business attribute `family_name` used by families workflows and reporting. | `VARCHAR(50)` | Yes | No | - | - |
| `status` | Lifecycle state code used for process filtering and reporting (for example: 1_ACTIVE, 2_TEMPORARYINACTIVE, 3_INACTIVE, 4_LEAD). | `VARCHAR(20)` | No | No | - | - |
| `id` | Primary key identifier for this record. | `serial` | No | Yes | - | - |

# Relations
- Commonly used with: [centers](centers.md) (6 query files), [persons](persons.md) (6 query files), [relatives](relatives.md) (6 query files), [extract](extract.md) (5 query files), [booking_resources](booking_resources.md) (4 query files), [person_ext_attrs](person_ext_attrs.md) (3 query files).
- FK-linked tables: incoming FK from [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [recurring_participations](recurring_participations.md), [startup_campaign](startup_campaign.md), [subscription_addon](subscription_addon.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts; `status`/`state` fields are typically used for active/inactive lifecycle filtering.

# subscription_retention_campaigns
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `serial` | No | Yes | - | - |
| `subscription_center` | Center component of the composite reference to the related subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Identifier component of the composite reference to the related subscription record. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `campaign_id` | Identifier of the related startup campaign record used by this row. | `int4` | No | No | [startup_campaign](startup_campaign.md) via (`campaign_id` -> `id`) | - |
| `privilege_start_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `campaign_code_id` | Identifier of the related campaign codes record used by this row. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [startup_campaign](startup_campaign.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [campaign_code_usages](campaign_code_usages.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [privilege_usages](privilege_usages.md), [products](products.md), [recurring_participations](recurring_participations.md).

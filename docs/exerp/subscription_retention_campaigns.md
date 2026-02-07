# subscription_retention_campaigns
Stores subscription-related data, including lifecycle and financial context. It is typically used where it appears in approximately 1 query files.

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key component that uniquely identifies the record within the center scope. | `serial` | No | Yes | - | - |
| `subscription_center` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `subscription_id` | Foreign key field linking this record to `subscriptions`. | `int4` | No | No | [subscriptions](subscriptions.md) via (`subscription_center`, `subscription_id` -> `center`, `id`) | - |
| `campaign_id` | Foreign key field linking this record to `startup_campaign`. | `int4` | No | No | [startup_campaign](startup_campaign.md) via (`campaign_id` -> `id`) | - |
| `privilege_start_date` | Date for privilege start. | `DATE` | No | No | - | - |
| `campaign_code_id` | Foreign key field linking this record to `campaign_codes`. | `int4` | Yes | No | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) | - |

# Relations
- FK-linked tables: outgoing FK to [campaign_codes](campaign_codes.md), [startup_campaign](startup_campaign.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [campaign_code_usages](campaign_code_usages.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [privilege_usages](privilege_usages.md), [products](products.md), [recurring_participations](recurring_participations.md).

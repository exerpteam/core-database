# subscriptionperiodparts
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; it appears in approximately 317 query files; common companions include [subscriptions](subscriptions.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [subscriptions](subscriptions.md) via (`center`, `id` -> `center`, `id`) | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [subscriptions](subscriptions.md) via (`center`, `id` -> `center`, `id`) | - |
| `subid` | Primary key component used to uniquely identify this record. | `int4` | No | Yes | - | - |
| `spp_type` | Classification code describing the spp type category (for example: CONDITIONAL FREEZE, FREE DAYS, FREEZE, INITIAL PERIOD). | `int4` | No | No | - | - |
| `spp_state` | State indicator used to control lifecycle transitions and filtering. | `int4` | No | No | - | - |
| `period_number` | Business attribute `period_number` used by subscriptionperiodparts workflows and reporting. | `int4` | No | No | - | - |
| `from_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `to_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | No | No | - | - |
| `old_billed_until_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `subscription_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `addons_price` | Monetary value used in financial calculation, settlement, or reporting. | `NUMERIC(0,0)` | Yes | No | - | - |
| `entry_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | No | No | - | - |
| `cancellation_time` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `campaign_code_id` | Identifier for the related campaign code entity used by this record. | `int4` | Yes | No | - | [campaign_codes](campaign_codes.md) via (`campaign_code_id` -> `id`) |
| `had_hard_close_role` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `sync_date` | Business date used for scheduling, validity, or reporting cutoffs. | `DATE` | Yes | No | - | - |
| `prorata_sessions` | Business attribute `prorata_sessions` used by subscriptionperiodparts workflows and reporting. | `int4` | Yes | No | - | - |
| `prorata_sessions_total` | Business attribute `prorata_sessions_total` used by subscriptionperiodparts workflows and reporting. | `int4` | Yes | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (278 query files), [products](products.md) (253 query files), [persons](persons.md) (246 query files), [centers](centers.md) (222 query files), [subscriptiontypes](subscriptiontypes.md) (194 query files), [spp_invoicelines_link](spp_invoicelines_link.md) (189 query files).
- FK-linked tables: outgoing FK to [subscriptions](subscriptions.md); incoming FK from [spp_invoicelines_link](spp_invoicelines_link.md).
- Second-level FK neighborhood includes: [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [families](families.md), [installment_plans](installment_plans.md), [invoice_lines_mt](invoice_lines_mt.md), [persons](persons.md), [products](products.md), [recurring_participations](recurring_participations.md), [startup_campaign](startup_campaign.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.

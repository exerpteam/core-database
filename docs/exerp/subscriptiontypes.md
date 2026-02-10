# subscriptiontypes
Stores subscription-related data, including lifecycle and financial context. It is typically used where rows are center-scoped; it appears in approximately 1384 query files; common companions include [subscriptions](subscriptions.md), [persons](persons.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `center` | Primary key component that defines the center scope for this record. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `change_requiredrole` | Business attribute `change_requiredrole` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `reactivation_allowed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `id` | Primary key component that uniquely identifies the record within its center scope. | `int4` | No | Yes | [products](products.md) via (`center`, `id` -> `center`, `id`) | - |
| `st_type` | Classification code describing the st type category (for example: 3. Pro-rata (Add-ons), 3. Pro-rated dues (Add-on Services), 6. Cash Add-on Services, 6. Cash Add-ons). | `int4` | No | No | - | [subscriptiontypes_st_type](../master%20tables/subscriptiontypes_st_type.md) |
| `use_individual_price` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `productnew_center` | Center component of the composite reference to the related productnew record. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - |
| `productnew_id` | Identifier component of the composite reference to the related productnew record. | `int4` | Yes | No | [products](products.md) via (`productnew_center`, `productnew_id` -> `center`, `id`) | - |
| `floatingperiod` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `prorataperiodcount` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `extend_binding_by_prorata` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `initialperiodcount` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `extend_binding_by_initial` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `bindingperiodcount` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `periodunit` | Operational field `periodunit` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `periodcount` | Operational counter/limit used for processing control and performance monitoring. | `int4` | No | No | - | - |
| `age_restriction_type` | Classification code describing the age restriction type category (for example: BETWEEN, LESS THAN, LESS THEN, MORE THAN). | `int4` | No | No | - | [subscriptiontypes_age_restriction_type](../master%20tables/subscriptiontypes_age_restriction_type.md) |
| `age_restriction_value` | Business attribute `age_restriction_value` used by subscriptiontypes workflows and reporting. | `int4` | No | No | - | - |
| `sex_restriction` | Business attribute `sex_restriction` used by subscriptiontypes workflows and reporting. | `int4` | No | No | - | - |
| `freezelimit` | Binary payload storing structured runtime data for this record. | `bytea` | Yes | No | - | - |
| `freezeperiodproduct_center` | Center component of the composite reference to the related freezeperiodproduct record. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - |
| `freezeperiodproduct_id` | Identifier component of the composite reference to the related freezeperiodproduct record. | `int4` | Yes | No | [products](products.md) via (`freezeperiodproduct_center`, `freezeperiodproduct_id` -> `center`, `id`) | - |
| `freezestartupproduct_center` | Center component of the composite reference to the related freezestartupproduct record. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - |
| `freezestartupproduct_id` | Identifier component of the composite reference to the related freezestartupproduct record. | `int4` | Yes | No | [products](products.md) via (`freezestartupproduct_center`, `freezestartupproduct_id` -> `center`, `id`) | - |
| `transferproduct_center` | Center component of the composite reference to the related transferproduct record. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - |
| `transferproduct_id` | Identifier component of the composite reference to the related transferproduct record. | `int4` | Yes | No | [products](products.md) via (`transferproduct_center`, `transferproduct_id` -> `center`, `id`) | - |
| `add_on_to_center` | Center component of the composite reference to the related add on to record. | `int4` | Yes | No | - | - |
| `add_on_to_id` | Identifier component of the composite reference to the related add on to record. | `int4` | Yes | No | - | - |
| `renew_window` | Business attribute `renew_window` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `rank` | Operational field `rank` used in query filtering and reporting transformations. | `int4` | No | No | - | - |
| `is_addon_subscription` | Boolean flag indicating whether `addon_subscription` applies to this record. | `bool` | No | No | - | - |
| `prorataproduct_center` | Center component of the composite reference to the related prorataproduct record. | `int4` | Yes | No | - | - |
| `prorataproduct_id` | Identifier component of the composite reference to the related prorataproduct record. | `int4` | Yes | No | - | - |
| `adminfeeproduct_center` | Center component of the composite reference to the related adminfeeproduct record. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - |
| `adminfeeproduct_id` | Identifier component of the composite reference to the related adminfeeproduct record. | `int4` | Yes | No | [products](products.md) via (`adminfeeproduct_center`, `adminfeeproduct_id` -> `center`, `id`) | - |
| `info_text` | Business attribute `info_text` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `clearing_house_restriction` | Business attribute `clearing_house_restriction` used by subscriptiontypes workflows and reporting. | `int4` | No | No | - | - |
| `is_price_update_excluded` | Boolean flag indicating whether `price_update_excluded` applies to this record. | `bool` | Yes | No | - | - |
| `start_date_limit_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `start_date_limit_unit` | Business attribute `start_date_limit_unit` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `start_date_restriction` | Business attribute `start_date_restriction` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `auto_stop_on_binding_end_date` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `roundup_end_unit` | Business attribute `roundup_end_unit` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `buyoutfeeproduct_center` | Center component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - |
| `buyoutfeeproduct_id` | Identifier component of the composite reference to the related buyoutfeeproduct record. | `int4` | Yes | No | [products](products.md) via (`buyoutfeeproduct_center`, `buyoutfeeproduct_id` -> `center`, `id`) | - |
| `rec_clipcard_product_center` | Center component of the composite reference to the related rec clipcard product record. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - |
| `rec_clipcard_product_id` | Identifier component of the composite reference to the related rec clipcard product record. | `int4` | Yes | No | [products](products.md) via (`rec_clipcard_product_center`, `rec_clipcard_product_id` -> `center`, `id`) | - |
| `rec_clipcard_product_clips` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `sale_startup_clipcard` | Boolean flag controlling related business behavior for this record. | `bool` | Yes | No | - | - |
| `autorenew_binding_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `autorenew_binding_unit` | Business attribute `autorenew_binding_unit` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `autorenew_binding_notice_count` | Operational counter/limit used for processing control and performance monitoring. | `int4` | Yes | No | - | - |
| `autorenew_binding_notice_unit` | Business attribute `autorenew_binding_notice_unit` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `unrestricted_freeze_allowed` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `buyout_fee_percentage` | Monetary value used in financial calculation, settlement, or reporting. | `int4` | Yes | No | - | - |
| `can_be_reassigned` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `reassign_product_center` | Center component of the composite reference to the related reassign product record. | `int4` | Yes | No | - | - |
| `reassign_product_id` | Identifier component of the composite reference to the related reassign product record. | `int4` | Yes | No | - | - |
| `reassign_template` | Business attribute `reassign_template` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `rec_clipcard_pack_size` | Business attribute `rec_clipcard_pack_size` used by subscriptiontypes workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `age_restriction_min_value` | Business attribute `age_restriction_min_value` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `age_restriction_max_value` | Business attribute `age_restriction_max_value` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `documentation_setting_id` | Identifier for the related documentation setting entity used by this record. | `int4` | Yes | No | - | [documentation_settings](documentation_settings.md) via (`documentation_setting_id` -> `id`) |
| `reassign_restrict_quantity` | Business attribute `reassign_restrict_quantity` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `reassign_restrict_span_unit` | Business attribute `reassign_restrict_span_unit` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `reassign_restrict_span_value` | Business attribute `reassign_restrict_span_value` used by subscriptiontypes workflows and reporting. | `int4` | Yes | No | - | - |
| `reassign_restrict_type_id` | Type code defining the business category used for workflow and reporting logic. | `int4` | Yes | No | - | - |
| `family_membership_type` | Type code defining the business category used for workflow and reporting logic. | `VARCHAR(20)` | Yes | No | - | - |
| `renewal_requires_privilege` | Boolean flag controlling related business behavior for this record. | `bool` | No | No | - | - |
| `is_member_operations_restricted_around_deduction_date` | Boolean flag indicating whether `member_operations_restricted_around_deduction_date` applies to this record. | `bool` | No | No | - | - |
| `member_operations_restricted_days_before_deduction_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int4` | No | No | - | - |
| `member_operations_restricted_days_after_deduction_date` | Business date used for scheduling, validity, or reporting cutoffs. | `int4` | No | No | - | - |

# Relations
- Commonly used with: [subscriptions](subscriptions.md) (1321 query files), [persons](persons.md) (1156 query files), [products](products.md) (1105 query files), [centers](centers.md) (927 query files), [person_ext_attrs](person_ext_attrs.md) (526 query files), [subscription_price](subscription_price.md) (515 query files).
- FK-linked tables: outgoing FK to [products](products.md); incoming FK from [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md).
- Second-level FK neighborhood includes: [accounts](accounts.md), [campaign_codes](campaign_codes.md), [centers](centers.md), [clipcards](clipcards.md), [clipcardtypes](clipcardtypes.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery_lines_mt](delivery_lines_mt.md), [employees](employees.md), [families](families.md), [gift_cards](gift_cards.md).
- Interesting data points: `center` + `id` is the stable composite key pattern used across many extracts.

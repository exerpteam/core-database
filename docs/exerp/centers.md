# centers
Operational table for centers records in the Exerp schema. It is typically used where lifecycle state codes are present; change-tracking timestamps are available; it appears in approximately 3999 query files; common companions include [persons](persons.md), [products](products.md).

# Structure
A table with the following structure:

| Column Name | Description | Data Type | Nullable | is PK | Physical FK | Logical FK |
| --- | --- | --- | --- | --- | --- | --- |
| `id` | Primary key identifier for this record. | `int4` | No | Yes | - | - |
| `shortname` | Operational field `shortname` used in query filtering and reporting transformations. | `text(2147483647)` | No | No | - | - |
| `name` | Human-readable value used to identify this record in user interfaces and reports. | `text(2147483647)` | No | No | - | - |
| `startupdate` | Operational field `startupdate` used in query filtering and reporting transformations. | `DATE` | Yes | No | - | - |
| `phone_number` | Operational field `phone_number` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `fax_number` | Business attribute `fax_number` used by centers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `email` | Operational field `email` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `org_code` | Business attribute `org_code` used by centers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `address1` | Operational field `address1` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `address2` | Operational field `address2` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `address3` | Operational field `address3` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `country` | Identifier of the related countries record used by this row. | `text(2147483647)` | Yes | No | [countries](countries.md) via (`country` -> `id`)<br>[zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `zipcode` | Identifier of the related zipcodes record used by this row. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `latitude` | Operational field `latitude` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | Yes | No | - | - |
| `longitude` | Operational field `longitude` used in query filtering and reporting transformations. | `NUMERIC(0,0)` | Yes | No | - | - |
| `center_type` | Type code defining the business category used for workflow and reporting logic. | `int4` | No | No | - | [centers_center_type](../master%20tables/centers_center_type.md) |
| `external_id` | External business identifier used for integration and cross-system matching. | `text(2147483647)` | Yes | No | - | - |
| `city` | Identifier of the related zipcodes record used by this row. | `text(2147483647)` | Yes | No | [zipcodes](zipcodes.md) via (`country`, `zipcode`, `city` -> `country`, `zipcode`, `city`) | - |
| `org_code2` | Operational field `org_code2` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `web_name` | Operational field `web_name` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `website_url` | Business attribute `website_url` used by centers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `manager_center` | Center component of the composite reference to the related manager record. | `int4` | Yes | No | - | - |
| `manager_id` | Identifier component of the composite reference to the related manager record. | `int4` | Yes | No | - | - |
| `asst_manager_center` | Center component of the composite reference to the related asst manager record. | `int4` | Yes | No | - | - |
| `asst_manager_id` | Identifier component of the composite reference to the related asst manager record. | `int4` | Yes | No | - | - |
| `last_modified` | Timestamp value (epoch milliseconds) used for event ordering and incremental extraction. | `int8` | Yes | No | - | - |
| `time_zone` | Operational field `time_zone` used in query filtering and reporting transformations. | `text(2147483647)` | Yes | No | - | - |
| `facility_url` | Business attribute `facility_url` used by centers workflows and reporting. | `text(2147483647)` | Yes | No | - | - |
| `STATE` | Lifecycle state code used for process filtering and reporting (for example: ACTIVE, AGREEMENT CONFIRMED, AKTIV, AWAITING_ACTIVATION). | `VARCHAR(60)` | Yes | No | - | - |

# Relations
- Commonly used with: [persons](persons.md) (3073 query files), [products](products.md) (1880 query files), [subscriptions](subscriptions.md) (1599 query files), [person_ext_attrs](person_ext_attrs.md) (1210 query files), [account_receivables](account_receivables.md) (1024 query files), [subscriptiontypes](subscriptiontypes.md) (927 query files).
- FK-linked tables: outgoing FK to [countries](countries.md), [zipcodes](zipcodes.md); incoming FK from [accountingperiods](accountingperiods.md), [aggregated_transactions](aggregated_transactions.md), [area_centers](area_centers.md), [bookings](bookings.md), [cashregisters](cashregisters.md), [center_change_logs](center_change_logs.md), [center_ext_attrs](center_ext_attrs.md), [clearinghouse_creditors](clearinghouse_creditors.md), [credit_note_lines_mt](credit_note_lines_mt.md), [delivery](delivery.md), [delivery_lines_mt](delivery_lines_mt.md), [inventory](inventory.md), [invoice_lines_mt](invoice_lines_mt.md), [kpi_data](kpi_data.md), [licenses](licenses.md), [persons](persons.md), [products](products.md), [subscription_sales](subscription_sales.md), [subscriptions](subscriptions.md), [vending_machine](vending_machine.md).
- Second-level FK neighborhood includes: [account_receivables](account_receivables.md), [account_trans](account_trans.md), [accounts](accounts.md), [activity](activity.md), [areas](areas.md), [attends](attends.md), [booking_change](booking_change.md), [booking_program_person_skills](booking_program_person_skills.md), [booking_program_standby](booking_program_standby.md), [booking_programs](booking_programs.md).
- Interesting data points: `external_id` is commonly used as an integration-facing identifier; `status`/`state` fields are typically used for active/inactive lifecycle filtering; change timestamps support incremental extraction and reconciliation.

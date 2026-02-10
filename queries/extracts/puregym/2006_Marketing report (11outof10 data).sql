-- The extract is extracted from Exerp on 2026-02-08
-- Extract of imported marketing data from 11outof10. Data will not change.
select
        C.ID,
        C.NAME,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYMMEMBER'
                and TXTVALUE = 'false'
        ) as PRIOR_GYMMEMBER_NO,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYMMEMBER'
                and TXTVALUE = 'true'
        ) as PRIOR_GYMMEMBER_YES,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'LA Fitness'
        ) as PRIOR_LA_Fitness,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Bannatynes'
        ) as PRIOR_Bannatynes,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Living Well'
        ) as PRIOR_Living_Well,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Exercise 4 Less'
        ) as PRIOR_Exercise_4_Less,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'The Village'
        ) as PRIOR_The_Village,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'The Gym Group'
        ) as PRIOR_The_Gym_Group,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Total Fitness'
        ) as PRIOR_Total_Fitness,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Xercise4less'
        ) as PRIOR_Xercise4less,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'DW Fitness'
        ) as PRIOR_DW_Fitness,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'David Lloyd'
        ) as PRIOR_David_Lloyd,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Virgin Active'
        ) as PRIOR_Virgin_Active,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Fitness First'
        ) as PRIOR_Fitness_First,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Fit4Less'
        ) as PRIOR_Fit4Less,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'Other'
        ) as PRIOR_Other,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'PRIOR_GYM_CHOICE'
                and TXTVALUE = 'none'
        ) as PRIOR_none,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'WILL_USE_PERSONAL_TRAINER'
                and TXTVALUE = 'true'
        ) as WILL_USE_PERSONAL_TRAINER_YES,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'WILL_USE_PERSONAL_TRAINER'
                and TXTVALUE = 'false'
        ) as WILL_USE_PERSONAL_TRAINER_NO,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'On Foot'
        ) as TRANSPORT_ON_FOOT,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'Bus'
        ) as TRANSPORT_Bus,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'Tube/Tram'
        ) as TRANSPORT_Tube_Tram,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'Train'
        ) as TRANSPORT_Train,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'Car'
        ) as TRANSPORT_Car,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'USER_TRANSPORT'
                and TXTVALUE = 'Bicycle'
        ) as TRANSPORT_Bicycle,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Friend/Colleague'
        ) as MARKETING_Friend_Colleague,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Promotional stand'
        ) as MARKETING_Promotional_stand,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Freshers Fair'
        ) as MARKETING_Freshers_Fair,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Ex member'
        ) as MARKETING_Ex_member,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Leaflets'
        ) as MARKETING_Leaflets,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'leaflet through door'
        ) as MARKETING_leaflet_through_door,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Email'
        ) as MARKETING_Email,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Leaflet - on street'
        ) as MARKETING_Leaflet_on_street,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'At work'
        ) as MARKETING_At_work,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Van Advert'
        ) as MARKETING_Van_Advert,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Manchester Confidential'
        ) as MARKETING_Manchester_Confiden,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Magazine'
        ) as MARKETING_Magazine,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Oyster Card Holder'
        ) as MARKETING_Oyster_Card_Holder,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Oyster Card Wallets'
        ) as MARKETING_Oyster_Card_Wallets,
(
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Banner on Escalator'
        ) as MARKETING_Banner_on_Escalator,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Roadside Banner'
        ) as MARKETING_Roadside_Banner,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Billboard'
        ) as MARKETING_Billboard,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'leaflet on street'
        ) as MARKETING_leaflet_on_street,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Newspaper and  Radio'
        ) as MARKETING_Newspaper_and_Radio,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Hotel'
        ) as MARKETING_Hotel,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Passing by'
        ) as MARKETING_Passing_by,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Other'
        ) as MARKETING_Other,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Tube station adverts'
        ) as MARKETING_Tube_station_adverts,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Kingfisher Shopping Centre'
        ) as MARKETING_Kingfisher_Shop_Cen,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Ad-van'
        ) as MARKETING_Ad_van,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Sticker in Nightclub'
        ) as MARKETING_Sticker_in_Nightclub,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Metro station'
        ) as MARKETING_Metro_station,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Pure Spa'
        ) as MARKETING_Pure_Spa,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Car Showroom'
        ) as MARKETING_Car_Showroom,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Radio'
        ) as MARKETING_Radio,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Bike Advert'
        ) as MARKETING_Bike_Advert,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Estate Agent'
        ) as MARKETING_Estate_Agent,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Search Engine'
        ) as MARKETING_Search_Engine,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Facebook/Twitter'
        ) as MARKETING_Facebook_Twitter,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Leaflet'
        ) as MARKETING_Leaflet,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Leaflet - through door'
        ) as MARKETING_Leaflet_through_door,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Newspaper/Magazine'
        ) as MARKETING_Newspaper_Magazine,
        (
                select count(*)
                from PERSON_EXT_ATTRS
                where PERSONCENTER = C.ID
                and NAME = 'MARKETING_SOURCE'
                and TXTVALUE = 'Restaurant'
        ) as MARKETING_Restaurant
from CENTERS C
order by C.ID
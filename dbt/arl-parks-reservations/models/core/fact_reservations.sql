{{
    config(
        materialized='table',
        partition_by={
            "field": "transactiondtm",
            "data_type": "datetime",
            "granularity": "day"
        },
        
    )
}}

with reservations as (
    select * 
    from {{ ref('stg_arl_parks_data') }}
    where reservationstatuscode != 'Cancelled'
),
dim_facility_types as (
    select *
    from {{ ref('dim_facility_types') }}
)
select 
    reservations.parkfacilityreservationkey, 
    reservations.locationname, 
    reservations.facilityname,
    reservations.transactiondtm, 
    reservations.facilitylocationcode, 
    reservations.facilityspacecode,
    reservations.reservationfacilitytypecode,
    facility_types.reservation_facility_type, 
    reservations.combokeycode, 
    reservations.reservationtypename,
--     reservations.customername, 
--     reservations.householdnbr, 
--     reservations.headcnt, 
    reservations.reservationbegindtm, 
    reservations.reservationenddtm, 
    reservations.reservationstatuscode, 
from reservations
inner join dim_facility_types as facility_types
on reservations.reservationfacilitytypecode = facility_types.reservation_facility_type_code
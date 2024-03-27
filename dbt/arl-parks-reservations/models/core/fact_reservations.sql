{{
    config(
        materialized='table',
        partition_by={
            "field": "transaction_dtm",
            "data_type": "datetime",
            "granularity": "day"
        }
    )
}}

with reservations as (
    select * 
    from {{ ref('stg_arl_parks_data') }}
    where reservation_status_code != 'Cancelled'
),
dim_facility_types as (
    select *
    from {{ ref('dim_facility_types') }}
)
select 
    reservations.park_facility_reservation_key, 
    reservations.location_name, 
    reservations.facility_name,
    reservations.transaction_dtm, 
    reservations.facility_location_code, 
    reservations.facility_space_code,
    reservations.reservation_facility_type_code,
    facility_types.reservation_facility_type, 
    reservations.combo_key_code, 
    reservations.reservation_type_name,
    reservations.reservation_begin_dtm, 
    reservations.reservation_end_dtm, 
    reservations.reservation_status_code, 
from reservations
inner join dim_facility_types as facility_types
on reservations.reservation_facility_type_code = facility_types.reservation_facility_type_code
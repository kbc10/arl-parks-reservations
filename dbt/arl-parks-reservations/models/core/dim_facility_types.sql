{{ config(materialized='table') }}

select 
    reservation_facility_type_code,
    reservation_facility_type
from {{ ref('reservation_facility_types') }}
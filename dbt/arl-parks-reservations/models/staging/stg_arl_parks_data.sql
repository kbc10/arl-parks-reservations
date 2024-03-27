{{
    config(
        materialized='view'
    )
}}

with 

source as (

    select * from {{ source('staging', 'arl_parks_data') }}

),

renamed as (

    select
        {{ dbt.safe_cast("park_facility_reservation_key", api.Column.translate_type("integer")) }} as park_facility_reservation_key,
        cast(location_name as string) as location_name,
        cast(facility_name as string) as facility_name,
        cast(transaction_dtm as timestamp) as transaction_dtm,
        cast(facility_location_code as string) as facility_location_code,
        cast(facility_space_code as string) as facility_space_code,
        cast(reservation_facility_type_code as string) as reservation_facility_type_code,
        cast(combo_key_code as string) as combo_key_code,
        cast(reservation_type_name as string) as reservation_type_name,
        cast(reservation_begin_dtm as timestamp) as reservation_begin_dtm,
        cast(reservation_end_dtm as timestamp) as reservation_end_dtm,
        cast(reservation_status_code as string) as reservation_status_code,
    from source

)

select * from renamed

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
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
        {{ dbt.safe_cast("parkfacilityreservationkey", api.Column.translate_type("integer")) }} as parkfacilityreservationkey,
        cast(locationname as string) as locationname,
        cast(facilityname as string) as facilityname,
        cast(transactiondtm as timestamp) as transactiondtm,
        cast(facilitylocationcode as string) as facilitylocationcode,
        cast(facilityspacecode as string) as facilityspacecode,
        cast(reservationfacilitytypecode as string) as reservationfacilitytypecode,
        cast(combokeycode as string) as combokeycode,
        cast(reservationtypename as string) as reservationtypename,
        cast(customername as string) as customername,
        cast(householdnbr as string) as householdnbr,
        {{ dbt.safe_cast("headcnt", api.Column.translate_type("integer")) }} as headcnt,
        cast(reservationbegindtm as timestamp) as reservationbegindtm,
        cast(reservationenddtm as timestamp) as reservationenddtm,
        cast(reservationstatuscode as string) as reservationstatuscode,
    from source

)

select * from renamed

-- dbt build --select <model_name> --vars '{'is_test_run': 'false'}'
{% if var('is_test_run', default=true) %}

  limit 100

{% endif %}
with source as (
    select * from {{ source('raw', 'calendar') }}
),

renamed as (
    select
        listing_id,
        date as calendar_date,
        available,
        cast(
            replace(replace(price, '$', ''), ',', '')
            as decimal(10,2)
        ) as price_usd,
        cast(
            replace(replace(adjusted_price, '$', ''), ',', '')
            as decimal(10,2)
        ) as adjusted_price_usd,
        minimum_nights,
        maximum_nights
    from source
    where listing_id is not null
)

select * from renamed
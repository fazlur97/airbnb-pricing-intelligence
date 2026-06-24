with source as (

    select * from {{ source('raw', 'listings') }}

),

renamed as (

    select
        -- identifiers
        id                                              as listing_id,
        name                                            as listing_name,
        listing_url,

        -- location
        neighbourhood_cleansed                          as neighbourhood,
        latitude,
        longitude,

        -- property details
        property_type,
        room_type,
        accommodates,
        bedrooms,
        beds,
        bathrooms,

        -- host details
        host_id,
        host_name,
        host_since,
        host_is_superhost,
        host_identity_verified,

        -- pricing (strip £ sign and cast to numeric)
        cast(
            replace(replace(price, '$', ''), ',', '')
            as decimal(10,2)
        )                                               as price_usd,
        minimum_nights,

        -- availability
        availability_30,
        availability_60,
        availability_365,

        -- review scores
        review_scores_rating,
        number_of_reviews,
        reviews_per_month,

        -- estimated performance
        estimated_occupancy_l365d                       as estimated_occupancy_days,
        estimated_revenue_l365d                         as estimated_revenue_gbp,

        -- metadata
        last_scraped

    from source

    where id is not null

)

select * from renamed
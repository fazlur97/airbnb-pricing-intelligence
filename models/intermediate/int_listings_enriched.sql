with listings as (

    select * from {{ ref('stg_listings') }}

),

calendar as (

    select * from {{ ref('stg_calendar') }}

),

reviews as (

    select * from {{ ref('stg_reviews') }}

),

-- calculate occupancy and availability per listing from calendar
calendar_stats as (

    select
        listing_id,
        count(*)                                                as total_days,
        sum(case when available = false then 1 else 0 end)     as booked_days,
        round(
            sum(case when available = false then 1 else 0 end)
            * 100.0 / count(*), 1
        )                                                       as occupancy_rate_pct

    from calendar
    group by listing_id

),

-- count reviews per listing
review_stats as (

    select
        listing_id,
        count(*)                                                as total_reviews,
        min(review_date)                                        as first_review_date,
        max(review_date)                                        as most_recent_review_date

    from reviews
    group by listing_id

),

-- join everything together
final as (

    select
        -- listing details
        l.listing_id,
        l.listing_name,
        l.neighbourhood,
        l.latitude,
        l.longitude,
        l.property_type,
        l.room_type,
        l.accommodates,
        l.bedrooms,
        l.beds,

        -- host details
        l.host_id,
        l.host_name,
        l.host_since,
        l.host_is_superhost,

        -- pricing
        l.price_usd,
        l.minimum_nights,

        -- availability
        l.availability_365,
        c.total_days,
        c.booked_days,
        c.occupancy_rate_pct,

        -- reviews
        l.review_scores_rating,
        l.number_of_reviews,
        l.reviews_per_month,
        r.total_reviews,
        r.first_review_date,
        r.most_recent_review_date,

        -- estimated performance
        l.estimated_occupancy_days,
        l.estimated_revenue_gbp,

        -- metadata
        l.last_scraped

    from listings l
    left join calendar_stats c on l.listing_id = c.listing_id
    left join review_stats r on l.listing_id = r.listing_id

    where l.price_usd is not null

)

select * from final
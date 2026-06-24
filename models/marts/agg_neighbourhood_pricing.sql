with listings as (

    select * from {{ ref('fct_listing_performance') }}

),

final as (

    select
        -- dimension
        neighbourhood,

        -- listing counts
        count(listing_id)                                   as total_listings,
        count(case when host_is_superhost then 1 end)       as superhost_listings,
        round(
            count(case when host_is_superhost then 1 end)
            * 100.0 / count(listing_id), 1
        )                                                   as superhost_pct,

        -- pricing
        round(avg(price_usd), 2)                            as avg_nightly_price,
        round(min(price_usd), 2)                            as min_nightly_price,
        round(max(price_usd), 2)                            as max_nightly_price,
        round(percentile_cont(0.5)
            within group (order by price_usd), 2)           as median_nightly_price,

        -- occupancy
        round(avg(occupancy_rate_pct), 1)                   as avg_occupancy_rate,

        -- quality
        round(avg(review_scores_rating), 2)                 as avg_review_score,
        sum(total_reviews)                                  as total_reviews,

        -- revenue
        round(avg(estimated_revenue_gbp), 2)                as avg_estimated_revenue,

        -- most common room type
        mode() within group (order by room_type)            as dominant_room_type

    from listings
    group by neighbourhood

)

select * from final
order by avg_nightly_price desc
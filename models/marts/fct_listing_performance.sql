with enriched as (

    select * from {{ ref('int_listings_enriched') }}

),

final as (

    select
        -- identifiers
        listing_id,
        listing_name,
        neighbourhood,
        room_type,
        property_type,

        -- host
        host_id,
        host_name,
        host_is_superhost,

        -- pricing
        price_usd,
        minimum_nights,

        -- performance metrics
        occupancy_rate_pct,
        total_reviews,
        review_scores_rating,
        reviews_per_month,

        -- estimated revenue
        estimated_revenue_gbp,
        estimated_occupancy_days,

        -- performance tier based on occupancy
        case
            when occupancy_rate_pct >= 80 then 'High'
            when occupancy_rate_pct >= 50 then 'Medium'
            when occupancy_rate_pct >= 20 then 'Low'
            else 'Very Low'
        end                                         as occupancy_tier,


        round(
            (coalesce(review_scores_rating, 0) * 20)
            + (coalesce(occupancy_rate_pct, 0) * 0.5)
            - (case when price_usd > 200 then 10 else 0 end)
        , 1) as performance_score,

        -- metadata
        last_scraped

    from enriched

)

select * from final
order by performance_score desc
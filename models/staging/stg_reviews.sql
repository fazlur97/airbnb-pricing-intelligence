with source as (

    select * from {{ source('raw', 'reviews') }}

),

renamed as (
    select
        
        id as review_id,
        listing_id,
        reviewer_id,
        reviewer_name,
        date as review_date,
        comments
        
    from source
    where id is not null and listing_id is not null
)

select * from renamed
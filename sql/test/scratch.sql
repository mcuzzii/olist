SELECT
    review_id,
    COUNT(*) AS occurrences
FROM staging.order_reviews
GROUP BY review_id
HAVING COUNT(*) > 1
ORDER BY occurrences DESC;
SELECT
    AVG(total_sales) as avg_sales
FROM sales_analysis
;
SELECT
    customer_name,
    CASE 
        WHEN AVG(total_sales) > 251 THEN 'Above Average'
        WHEN AVG(total_sales) = 251 THEN 'Average'
        WHEN AVG(total_sales) < 251 THEN 'Below Average'
        ELSE 'Warning'
    END as segment
FROM sales_analysis
GROUP BY customer_name
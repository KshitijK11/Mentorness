SELECT * FROM mentorness.`order_details`;
SELECT * FROM mentorness.`orders`;
SELECT * FROM mentorness.`pizzas`;
SELECT * FROM mentorness.`pizza_types`;

SELECT COUNT(order_id)
FROM orders;

SELECT SUM(p.price * od.quantity) AS total_revenue
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id;

SELECT pt.name,p.price
FROM pizzas p
JOIN pizza_types pt 
ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

SELECT p.size, SUM(od.quantity) AS total_quantity
FROM pizzas p
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY p.size
ORDER BY total_quantity DESC
LIMIT 1;

SELECT distinct pizza_id,COUNT(pizza_id) AS quantity
FROM order_details
group by pizza_id 
order by quantity desc
limit 5;

SELECT pt.category, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.category;

SELECT HOUR(STR_TO_DATE(time, '%H:%i:%s')) AS hour_of_day, COUNT(*) AS order_count
FROM orders
GROUP BY hour_of_day
ORDER BY hour_of_day;

select category,count(category) from pizza_types
group by category;

SELECT 
    AVG(daily_pizzas.total_pizzas) AS average_pizzas_per_day
FROM (
    SELECT 
        STR_TO_DATE(o.date, '%Y-%m-%d') AS order_date,
        SUM(od.quantity) AS total_pizzas
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    GROUP BY 
        order_date
) AS daily_pizzas;

SELECT pt.pizza_type_id, pt.category, SUM(p.price * od.quantity) AS total_revenue
FROM pizzas p
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN order_details od ON p.pizza_id = od.pizza_id
GROUP BY pt.pizza_type_id, pt.category
ORDER BY total_revenue DESC
LIMIT 3;


SELECT 
    pt.pizza_type_id,
    pt.category,
    SUM(p.price * od.quantity) AS total_revenue,
    (SUM(p.price * od.quantity) / total_revenue_all.total_revenue * 100) AS percentage_contribution
FROM 
    pizzas p
JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
JOIN 
    order_details od ON p.pizza_id = od.pizza_id
JOIN (
    SELECT 
        SUM(p.price * od.quantity) AS total_revenue
    FROM 
        pizzas p
    JOIN 
        order_details od ON p.pizza_id = od.pizza_id
) AS total_revenue_all
GROUP BY 
    pt.pizza_type_id, pt.category, total_revenue_all.total_revenue
ORDER BY 
    total_revenue DESC;

SELECT 
    order_date,
    daily_revenue,
    SUM(daily_revenue) OVER (ORDER BY order_date) AS cumulative_revenue
FROM (
    SELECT 
        STR_TO_DATE(o.date, '%Y-%m-%d') AS order_date,
        SUM(od.quantity * p.price) AS daily_revenue
    FROM 
        orders o
    JOIN 
        order_details od ON o.order_id = od.order_id
    JOIN 
        pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY 
        order_date
) AS daily_revenues
ORDER BY 
    order_date;
    
WITH RevenueRank AS (
    SELECT
        pt.category,
        p.pizza_id,
        SUM(p.price * od.quantity) AS total_revenue,
        ROW_NUMBER() OVER (PARTITION BY pt.category ORDER BY SUM(p.price * od.quantity) DESC) AS rn
    FROM
        pizzas p
    JOIN
        pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    JOIN
        order_details od ON p.pizza_id = od.pizza_id
    GROUP BY
        pt.category, p.pizza_id
)
SELECT
    category,
    pizza_id,
    total_revenue
FROM
    RevenueRank
WHERE
    rn <= 3;

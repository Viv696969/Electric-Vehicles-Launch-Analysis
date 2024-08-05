-- 1.
with cte as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2023 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold desc
limit 3
),
cte1 as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2024 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold desc
limit 3
)
select * from cte
union
select * from cte1;


-- 1
with cte as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2023 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold 
limit 3
),
cte1 as (
select d.fiscal_year,maker,
sum(electric_vehicles_sold) as ev_sold
from electric_vehicle_sales_by_makers ev join dim_date d
using(`date`)
where d.fiscal_year=2024 and ev.vehicle_category='2-Wheelers'
group by maker
order by ev_sold 
limit 3
)
select * from cte
union
select * from cte1;

-- 2
with cte_2_wheeler as (
select ev.vehicle_category , state , 
sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev 
join dim_date d using (`date`)
where d.fiscal_year=2024 and vehicle_category='2-Wheelers'
group by ev.vehicle_category , state
order by `penetration rate` desc
limit 5
),
cte_4_wheeler as (
select ev.vehicle_category , state , 
sum(electric_vehicles_sold)*100/sum(total_vehicles_sold) as `penetration rate`
from electric_vehicle_sales_by_state ev 
join dim_date d using (`date`)
where d.fiscal_year=2024 and vehicle_category='4-Wheelers'
group by ev.vehicle_category , state
order by `penetration rate` desc
limit 5
)
select * from cte_2_wheeler
union
select * from cte_4_wheeler;




-- 1. How many unique post types are found in the 'fact_content' table?

select * from fact_content;

select DISTINCT(post_type) as unique_post_types from fact_content;

-- 2. What are the highest and lowest recorded impressions for each post type?

select * from fact_content;

select post_type,min(impressions) as min_impression,
max(impressions) as max_impression
from fact_content
group by post_type;

-- 3. Filter all the posts that were published on a weekend in the month of March and April 
-- and export them to a separate csv file.

select * from fact_content;

select * from fact_content
where monthname(date) in ("March","April")
and dayname(date) in ("Sunday","Saturday");

-- Alternate
select * from fact_content as c
join dim_dates as d
on c.date = d.date
where month_name in ("March","April") 
AND weekday_or_weekend = "Weekend";

-- 4. Create a report to get the statistics for the account. The final output includes the following fields:
-- • month_name
-- • total_profile_visits
-- • total_new_followers

select month_name,
sum(a.profile_visits) as total_profile_visits,
sum(a.new_followers) as total_new_followers
 from fact_account as a
join dim_dates as d
on a.date = d.date
GROUP BY month_name;


-- 5. Write a CTE that calculates the total number of 'likes’ for each 
-- 'post_category' during the month of 'July' and subsequently, arrange the 'post_category' values in descending order 
-- according to their total likes.


with cte1 as
(
select c.date,c.post_category,c.likes from fact_content as c
join dim_dates as d
on c.date = d.date
where month_name = "July"
)
select post_category,sum(likes) as total_likes from cte1
GROUP BY post_category
order by total_likes desc;

-- Alternate Solution

select post_category,sum(likes) as total_likes
 from fact_content
where monthname(date) = "July"
group by post_category
order by total_likes DESC;

-- 6. Create a report that displays the unique post_category names alongside their respective counts for each month.
-- The output should have three columns:
-- • month_name
-- • post_category_names
-- • post_category_count

with cte1 as
(
select *,monthname(date) as month_name from fact_content
)
select month_name,post_category,
 count(*) as post_category_count 
 from cte1
group by month_name,post_category;
 
-- Real

with cte1 as
(
select *,monthname(date) as month_name from fact_content
)
select month_name,
group_concat(DISTINCT post_category) as post_category_names,
count(DISTINCT post_category)
from cte1
group by month_name;

-- Alternate

with cte1 as
(
select *,
monthname(date) as month_name
from fact_content
),
cte2 as
(
select month_name,
GROUP_CONCAT(DISTINCT post_category) as post_category_names
from cte1
group by month_name
)
select *,
length(post_category_names) - length(replace(post_category_names,',','')) + 1 as post_category_count
from cte2;


-- 7.What is the percentage breakdown of total reach by post type? The final output includes the following fields:
-- •post_type
-- •total_reach
-- •reach_percentage

select * from fact_content;

select post_type,sum(reach) as total_reach,
round((sum(reach)/(select sum(reach) from fact_content)) *100,2) as reach_percentage
from fact_content
group by post_type
order by reach_percentage desc;

-- Alternate

with cte1 as
(
	select post_type,sum(reach) as total_reach from fact_content
    group by post_type
)
select *,
round((total_reach/(select sum(reach) from fact_content)) * 100 ,2) as reach_percentage
from cte1
order by reach_percentage desc; 

-- 8.Create a report that includes the quarter, total comments, and
--  total saves recorded for each post category. Assign the following quarter groupings:
-- (January, February, March) → “Q1”
-- (April, May, June) → “Q2”
-- (July, August, September) → “Q3”

-- The final output columns should consist of:
-- •post_category
-- •quarter
-- •total_comments
-- •total_saves

with cte1 as
(
select *,
case
	when month(date) in (1,2,3) then "Q1"
    when month(date) in (4,5,6) then "Q2"
    when month(date) in (7,8,9) then "Q3"
    else "Q4"
end as Quarter
 from fact_content
)
select post_category,Quarter,sum(comments) as total_comments,
sum(saves) as total_saves from cte1
group by post_category,Quarter;

select * from dim_dates;

-- 9.List the top three dates in each month with the highest number of new followers.
-- The final output should include the following columns:
-- •month
-- •date
-- •new_followers

select * from fact_account;


with cte1 as
(
select a.date,d.month_name ,a.new_followers,
month(a.date)  as month_num
from 
fact_account as a
join dim_dates d
on a.date = d.date
),
cte2 as
(
select month_num,month_name,date,
rank() over(PARTITION BY month_name order by new_followers desc) as rk,
new_followers
from cte1
),
cte3 as
(
select * from cte2
where rk < 4
)
select month_name,date,new_followers
from cte3
order by month_num;

-- 10. Create a stored procedure that takes the 'Week_no' as input and generates a report 
-- displaying the total shares for each 'Post_type'. The output of the procedure should consist of two columns:
-- •post_type
-- •total_shares


select c.post_type,sum(c.shares) as total_shares
from fact_content c
join dim_dates d
on c.date = d.date
where d.week_no = "W10"
group by c.post_type
order by total_shares desc;


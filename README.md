# Sales-data-analysis-SQL
**SQL** analysis of a relational sales dataset using Joins,CTEs, window functions, aggregations, and data cleaning.

## Project Overview
This project uses **SQL** 
to clean an analyze a relational dataset consisting of three tables namely:
-**Orders** - 25,000 rows
-**Customers** - 8,000 rows
-**Product summary** - 170 rows
The analysis explores sales performance,customer behavior, product performance  and business trends while demonstrating practical SQL techniques.

## Tools & Skills

-MySQL
-Data Cleaning
-INNER Join
-CTEs
-Window Functions
-CASE Statements
-Aggregate Functions
-GROUP BY & ORDER BY
-Date Conversion
-Exploratory Data Analysis

## Analysis Performed

##Sales Analysis
-Total Revenue
-Total orders
-Average order value
-Return Rate
-Yearly and Monthly order trends
-Rolling order totals

## Customer Analysis
-Customer distribution by country
-Gender distribution
-Age-group analysis
-Top customer by spending
-Memebership tier performance
-Preferred devices
-Acquisition channels
-Preferred Categories

## Product Analysis
-Top-performing products
-Products with longer delivery time
-category performance

## Customer Engagement
-Average session duration by category
-Comparison of session duration, orders, and revenue across categories.

## Key SQL Techniques
The project demonstrates how to:
-Join related tables using customer IDs.
-Create staging tables for analysis.
-Identify duplicates records using `ROW_NUMBER()`
-Clean and convert date columns using `STR-TO-DATE()`
-Handle missing customer retings using `NULLIF()`
-Create age groups using `CASE`
-Use CTEs for intermediate calculations
-Calculate rolling totals using wondow functions

## Key Insights
-Electronics generated the highest revenue and had the highest number of orders.
-Travel and luggage had the average session duration at **18.88 minutes**
-The analysis identified customer, product,membership tier, acquisition, and purchase behavior trends across the dataset.

## Project Goal
The objective of this project was to reinforce practical SQL skills while using a relational dataset to answer real-lie business questions and generate actional actions.



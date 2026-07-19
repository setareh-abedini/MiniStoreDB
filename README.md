# MiniStoreDB

Normalized retail SQL Server database simulating a real-world sales system, 
built as a personal portfolio project to practice data modeling and analytical SQL.

## Overview
- 4 related tables: Customers, Products, Orders, OrderItems
- 100 customers, 20 products, 1,000 orders, 3,000 order item rows
- Designed with IDENTITY columns, foreign keys, and proper normalization

## What's inside
- `01_schema.sql` — table creation scripts with constraints and relationships
- `02_seed_data.sql` — sample data generation for all tables
- `03_business_queries.sql` — 14 analytical queries answering real business questions

## Key SQL concepts demonstrated
- CTEs (Common Table Expressions)
- Window functions (RANK, DENSE_RANK, ROW_NUMBER)
- Set operators (UNION, EXCEPT)
- Subqueries

## Example business questions answered
- Who are the top-spending customers in each city?
- What is the monthly revenue trend?
- How do products rank by revenue within each category?
- Which products are slow-moving / stagnant?

## Tech
SQL Server (T-SQL)

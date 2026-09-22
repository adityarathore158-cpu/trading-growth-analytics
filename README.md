# Trading Growth Analytics — Power BI & SQL

##  Project Overview

Trading Growth Analytics is an end-to-end data analytics project built using MySQL and Microsoft Power BI.

The project analyzes customer trading activity, order performance, stock/sector performance, payment behavior, risk profiles and trading trends.

The objective is to transform raw trading data into meaningful business insights through SQL analysis and an interactive Power BI dashboard.

---

##  Tools & Technologies

- MySQL
- SQL
- Microsoft Power BI
- DAX
- Power Query
- Data Modeling
- Excel/CSV Data

---

##  Database Structure

The project contains five main tables:

### Dimension Tables

- dim_customers
- dim_stocks
- dim_date

### Fact Tables

- fact_orders
- fact_payments

---

## 🔗 Data Model

The database follows a dimensional/star-schema style structure.

Main relationships:

- dim_customers → fact_orders
- dim_stocks → fact_orders
- dim_date → fact_orders
- fact_orders → fact_payments
- dim_customers → fact_payments

---

##  Power BI Dashboard

The dashboard contains five pages:

### 1. Executive Overview

<img width="908" height="538" alt="Screenshot 2026-09-22 150401" src="https://github.com/user-attachments/assets/408bea38-6884-447e-95f6-fce82fcd6696" />

Key metrics:

- Total Trading Value
- Total Orders
- Completed Orders
- Total Customers
- Total Quantity Traded
- MoM Trading Growth

### 2. Customer Analytics

<img width="1048" height="584" alt="Screenshot 2026-09-22 153353" src="https://github.com/user-attachments/assets/7bb75138-f7c0-4184-a554-8d0226b723bd" />

Key metrics:

- Active Customers
- Average Trading Value per Customer
- Top Customer Trading Value
- Average Orders per Customer
- Top Customer Contribution

### 3. Order & Sector Performance


<img width="909" height="539" alt="Screenshot 2026-09-22 153459" src="https://github.com/user-attachments/assets/99b15d97-4df8-4bbf-8cef-9995177dfdf5" />

Key metrics:

- Total Orders
- Completed Orders
- Cancelled Orders
- Completion Rate
- Average Order Value

### 4. Risk & Payment Analytics

<img width="911" height="538" alt="Screenshot 2026-09-22 153543" src="https://github.com/user-attachments/assets/f74718c3-030b-4d9b-a2dc-0990edf6857b" />

Key metrics:

- Total Payments
- Successful Payments
- Failed Payments
- Payment Success Rate
- Average Payment Value

### 5. Detailed Insights

<img width="914" height="546" alt="Screenshot 2026-09-22 153629" src="https://github.com/user-attachments/assets/b4f2d9dd-677e-4b09-9d69-c06fcb48206a" />

Interactive analysis using:

- Date
- Sector
- Exchange
- Order Status
- Order Type
- Risk Profile

---

##  SQL Concepts Used

The project demonstrates:

- SELECT
- WHERE
- GROUP BY
- HAVING
- ORDER BY
- JOINS
- LEFT JOIN
- CROSS JOIN
- Subqueries
- CTEs
- Window Functions
- RANK()
- LAG()
- Running totals
- Month-over-Month Growth
- Views
- Stored Procedures
- Foreign Keys
- NULL handling
- COALESCE()

---

##  Key Business Insights

The dashboard provides insights into:

- Overall trading performance
- Customer contribution
- Top customers
- Sector-wise trading activity
- Exchange-wise trading value
- Order status distribution
- BUY vs SELL activity
- Payment success and failure
- Risk-profile trading behavior
- Monthly trading trends


##  Project Structure

Trading-Growth-Analytics/

 SQL/

 PowerBI/

 Dashboard_Screenshots/

 Documentation/

 README.md



##  Author

Aditya Rathore

Power BI | SQL | Data Analytics | Business Intelligence

# Olist E-Commerce Data Project

Data used is from kaggle's Brazilian E-Commerce Public Dataset by Olist
https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce/data

---

## Project Overview
This project consists of a data pipeline from raw CSV files to a PostgreSQL database inside of a docker container. This transformed database, using the Medallion Architecture, is then analysed with Tableau and used for machine learning to predict what could be the reason of delivery delays.

---

## Architecture
* **Environment Management:** uv
* **Data Engineering:**  Python (Pandas, SQLAlchemy, pyscopg2), PostgreSQL, and Docker
* **Data Analytics:** Tableau Public
* **Machine Learning:** Python (Scikit-Learn)

---

## Project Phases

### 1. Data Engineering (ELT Pipeline)
In this phase, Docker is used for having the local PostgreSQL database as well as pgAdmin 4 for its GUI. Raw data from kaggle is downloaded to CSV file format and then ingested to the database using Pandas, SQLAlchemy, and pysopg2. Transformation is done in PostgreSQL following the Medallion architecture, turning the raw, bronze tables to optimised, silver materialized view.

### 2. Data Analytics & Visualisation
The ready-to-use silver materialized views are combined into a gold table which then analysed using Tableau Public to figure out metrics like what is the total revenue, where do most orders come from, which product category are is bought the most, etc. These metrics are then visualised and put together into a clean and interactive dashboard.

**Live Dashboard:** https://public.tableau.com/shared/99RKRZMN5?:display_count=n&:origin=viz_share_link

![Live Dashboard Screenshot](Asset/Live%20Dashboard.png)

### 3. Machine Learning (Prediction Model)
The goal of this model is to find out which variable has the biggest impact to delivery delays. Another gold table is created and is accessed straight using Pandas's dataframe. The Haversine formula was used to find the distance between customers and sellers based on latitude and longitude position for one of the variable. These variables are then trained with Scikit's RandomForestClassifier and the result is plotted using seaborn's barplot.

![Feature Importance Bar Chart](Asset/Feature%20Importance.png)
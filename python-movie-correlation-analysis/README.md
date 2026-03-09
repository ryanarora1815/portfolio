# Movie Correlation Analysis (Python)

## Overview

This project explores correlations between variables in a movie dataset to identify factors that influence box office revenue. Using Python and data analysis libraries, the dataset was cleaned, processed, and analysed to uncover relationships between budget, gross revenue, ratings, votes, and other movie attributes.

The goal of the project was to practise exploratory data analysis, data cleaning, and correlation analysis using Python.

## Dataset

The dataset contains information about movies including:

* Title
* Genre
* Release year
* Budget
* Gross revenue
* Rating
* Votes
* Director
* Production company
* Runtime

It was sourced from Kaggle: https://www.kaggle.com/datasets/danielgrijalvas/movies

## Tools & Libraries

The analysis was performed using Python and the following libraries:

* pandas
* numpy
* matplotlib
* seaborn

## Project Steps

1. Loaded and inspected the dataset
2. Checked and handled missing values
3. Converted columns to appropriate data types
4. Extracted the correct year from release date data
5. Performed exploratory data analysis and visualisation
6. Calculated correlation matrices between variables
7. Visualised correlations using heatmaps
8. Identified strong correlations between variables

## Key Findings

* Movie **budget and gross revenue show a strong positive correlation**.
* Movies with **higher budgets generally generate higher box office revenue**.
* **Votes also show a moderate correlation with gross revenue**, suggesting popularity may influence financial success.
* **Ratings have a weaker correlation with gross revenue**, indicating critical reception does not necessarily translate to higher earnings.

## Repository Contents

* `movie_correlation_analysis.ipynb` – Jupyter Notebook containing the full analysis and visualisations.

## Purpose

This project was completed as part of building a data analysis portfolio while studying Computer Science. It demonstrates practical experience with data cleaning, exploratory analysis, and statistical relationships in datasets.


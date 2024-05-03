# SQL E-Shop with Oracle Database

This repository contains SQL scripts for an E-Shop application utilizing an Oracle Database. The database schema includes tables for managing accounts, products, orders, and other essential entities for an online shopping platform.

## Tables

- **ACCOUNT**: Stores information about user accounts, including usernames, passwords, names, emails, and phone numbers.
- **ITEM**: Contains details about products available in the E-Shop, such as names, descriptions, prices, images, and stock quantities.
- **CART**: Manages the shopping carts of users, allowing them to add items for purchase.
- **CATEGORY**: Defines categories for organizing products.
- **CLIENT**: Stores additional details about clients, such as addresses and firm information.
- **EMPLOYEE**: Contains data about employees, including their positions.
- **ORDERTABLE**: Tracks orders placed by customers, including order details and statuses.

## Procedures and Triggers

- **ADD_ITEM_N_TIMES**: A procedure to add multiple instances of an item to a user's shopping cart.
- **DELETE_ITEM_N_TIMES**: A procedure to remove multiple instances of an item from a user's shopping cart.
- **FIND_CART**: A procedure to find or create a shopping cart for a user.
- **PRICE_ADJUSTMENT_TRIGGER**: A trigger to apply a 5% discount to orders with a total price over 400.
- **UPDATE_QUANTITY**: A trigger to decrease the stock quantity of items when an order is placed.

## Sample Queries

- Retrieve the user with the highest total order price.
- Find all users from a specific city.
- Identify employees who dispatched orders.
- Group employees by position and count the number of employees in each position.
- Group items by category and count the number of items in each category.
- Select items that belong to a specific category.
- Select users with orders above a certain price threshold.

## Indexes and Performance

- Created an index on the `PRICE` column of the `ORDERTABLE` table for faster retrieval of order information.
- Utilized explain plan to analyze the execution plan for a query retrieving the user with the highest total order price.

These scripts provide a foundation for building and managing an E-Shop application using Oracle Database.

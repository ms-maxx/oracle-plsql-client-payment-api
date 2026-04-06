# PL/SQL API for Client and Payment

A pet project focused on building a secure PL/SQL API for **Client** and **Payment** entities in Oracle Database.

The project demonstrates how business logic can be encapsulated inside PL/SQL packages while protecting base tables from direct DML operations.  
All data changes are intended to go through the API layer, with additional control enforced by triggers and database-level checks.

## Overview

This project implements a database-driven API for working with:

- clients;
- client attributes;
- payments;
- payment attributes.

The main idea is to model not only CRUD-like operations, but also a controlled API layer with validation, status management, access restrictions, and test scenarios.

## Implemented Functionality

### Client
- create a client;
- add and update client attributes;
- block and unblock a client;
- deactivate a client;
- restrict direct data modifications outside the API;
- restrict direct deletion from the base table;
- cover positive and negative scenarios with test scripts.

### Payment
- create a payment;
- add and update payment details;
- process payment status transitions;
- cancel a payment;
- mark a payment as failed;
- complete a payment successfully;
- restrict direct data modifications outside the API;
- restrict direct deletion from the base table;
- cover positive and negative scenarios with test scripts.

## Technical Highlights

- PL/SQL packages;
- procedures and functions;
- database triggers;
- user-defined types and collections;
- centralized exception and error handling;
- sequences;
- row-level locking with `FOR UPDATE NOWAIT`;
- `MERGE` for attribute synchronization;
- test scripts for positive and negative cases.

## Project Goals

The purpose of this project is to demonstrate an approach to building an API layer directly inside Oracle Database, including:

- moving business logic into PL/SQL packages;
- protecting tables from direct modification;
- controlling entity states and data consistency;
- working with additional attributes through separate tables;
- building a foundation for further extension of the domain model.

## Notes

This project is educational and portfolio-oriented.  
It is intended to show database design and PL/SQL development practices such as API encapsulation, trigger-based protection, status-driven logic, and structured error handling.

Course: Oracle Master PLSQL
Instructor: Denis Kivilyov, tg: @denis_dbd

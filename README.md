![Logo Università](https://www.unibg.it/themes/custom/unibg/logo.svg) 
# COVID-19 Clinical Studies Database Project

## Overview

This project was developed for the **Database 2** course at the **University of Bergamo**, Academic Year 2024/2025. The course focuses on **active databases, Event/Condition/Action (ECA) rules**, and the integration of **XML data** with relational databases. The project revolves around analyzing a COVID-19 clinical studies dataset from [Kaggle](https://www.kaggle.com/datasets/parulpandey/covid19-clinical-trials-dataset/data?select=COVID-19+CLinical+trials+studies), which contains over 5000 XML files. Each file represents a study, with details such as title, sponsor/collaborators, status, start and completion dates, and other metadata.

The goal of this project is to design and implement a database system that leverages SQL Server, XML storage, and advanced querying techniques such as **XQuery** to automate data extraction, maintenance, and updates. This aligns with the concepts learned in the course, specifically focusing on **triggers**, **active rules**, and **XML data processing** in relational databases.

## Project Connection to Course

The Database 2 course covers a variety of topics relevant to this project, such as:

- **Active Databases**: Implementing ECA (Event/Condition/Action) rules for automation of actions based on certain conditions.
- **Trigger Mechanisms**: Using triggers to ensure that the database is updated automatically when specific events occur.
- **XML Databases**: Working with XML as a standard for data exchange and integrating it into relational database systems using **XPath** and **XQuery**.

In this project, these concepts are practically applied through the use of a real-world dataset, creating an automated and flexible system to manage clinical study data.

## Objectives

The main objectives of the project are:

1. **Import XML Dataset into SQL Server**:
   - Load over 5000 XML files into a SQL Server database, storing them in an XML column within a table called `ClinicalStudies`.

2. **Relational Database Design**:
   - Design relational tables to store key information about each study, including tables for `Study`, `Sponsors`, `Conditions`, and `Locations`.
   - Use **XQuery** to extract and insert relevant data from the XML into the relational tables.

3. **Implementation of Triggers**:
   - Create triggers to automatically update or maintain study information, such as sending notifications on study status updates or completion dates.
   - Ensure data consistency and automation through active rules in the database.

4. **Use of XQuery for Data Manipulation**:
   - Extract specific data from the XML files using XQuery to filter studies based on conditions such as status or start date.
   - Manipulate and update XML data directly in the database to ensure data accuracy and consistency.

5. **Automation and Reporting**:
   - Create a system that updates the clinical study information automatically and allows flexible querying for specific study details, statuses, or results.

## Project Structure

The repository is organized as follows:

- **`/data/`**: Contains the original XML files representing the clinical studies.
- **`/scripts/`**: Includes SQL scripts used to create tables, load XML data into SQL Server, and implement triggers.
- **`/queries/`**: Contains XQuery scripts for extracting and manipulating XML data within SQL Server.
- **`/docs/`**: Documentation on the project setup, including installation instructions and database schema.

## Installation

To run the project:

1. Ensure **SQL Server Management Studio (SSMS)** is installed and running.
2. Clone the repository to your local machine.
3. Run the SQL scripts in the `/scripts/` folder to set up the database and tables.
4. Place the XML dataset in the appropriate directory.
5. Execute the queries in `/queries/` to interact with the database and automate data manipulation.

## Technologies Used

- **SQL Server**: Relational database management system used for data storage and manipulation.
- **XQuery**: Query language used to extract and manipulate XML data.
- **Triggers**: Used to automate actions based on events within the database.

## Future Enhancements

- Integration with external systems for real-time updates on clinical study progress.
- Expanded querying capabilities, including advanced reporting and analytics on study data.
- Implementation of more advanced **ECA** rules for complex automation.




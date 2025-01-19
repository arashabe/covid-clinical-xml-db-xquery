# COVID-19 Clinical Studies Database Project

## Overview

This project was developed for the [**Database 2**](https://unibg.coursecatalogue.cineca.it/insegnamenti/2024/8244_43613_12905/2021/8244/89?coorte=2023&schemaid=77316) course at the **University of Bergamo**, Academic Year 2024/2025. The project focuses on **active databases, Event/Condition/Action (ECA) rules**, and the integration of **XML data** with relational databases. The project revolves around analyzing a COVID-19 clinical studies dataset from [Kaggle](https://www.kaggle.com/datasets/parulpandey/covid19-clinical-trials-dataset/data?select=COVID-19+CLinical+trials+studies), which contains over 5000 XML files. Each file represents a study, with details such as title, sponsor/collaborators, status, start and completion dates, and other metadata.

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
   - Design relational tables to store key information about each study, including tables for `Studies`, `Sponsors`, `Conditions`, and `Locations`.

3. **Implementation of Triggers**:
   - Create triggers to automatically record changes (inserts, updates, and deletes) made to the ClinicalStudies and Studies tables. This mechanism ensures that all modifications are logged for audit purposes, maintaining data integrity and a comprehensive history of all actions performed on these records.
   - Utilize triggers to enforce data consistency and automate the management of study information.

4. **Implementation of Stored Procedures**:

   - Develop stored procedures to efficiently insert and update clinical study data from multiple XML files into the relational database.
   - The stored procedures are designed to periodically check a designated folder on the server for new XML files.
   - Upon identifying new XML files that are not already present in the database, the stored procedures automatically import the data into the existing tables.
   - The stored procedures are optimized to handle large volumes of data, minimizing manual intervention and reducing the risk of errors.

5. **Use of XQuery for Data Manipulation**:
   - Extract specific data from the XML files using XQuery to filter studies based on conditions such as status or start date.
   - Manipulate and update XML data directly in the database to ensure data accuracy and consistency.




## Project Structure

The repository is organized as follows:

- **/Doc/**: Contains documentation on the project.
- **/Sample_XML_Documents/**: Includes sample XML files used for testing and demonstrating the project's XML handling capabilities.
- **/SQL_XPath_Scripts/**: Contains SQL scripts for creating tables, loading XML data into SQL Server, implementing triggers, stored procedures and using XPath.
- **/XQuery_Scripts/**: Houses XQuery scripts for extracting and manipulating XML data.


## Installation

To run the project:

1. **SQL Server Management Studio (SSMS)** and **BaseX** should be installed to proceed with script execution.
2. Before executing the scripts in the **SQL_XPath_Scripts** folder and **XQuery_Scripts**, please **read the relevant documentation** located in the Doc folder.

## Technologies Used

- **SQL Server**: Relational database management system used for data storage and manipulation.
- **BaseX**: Native XML database for efficient storage, querying, and processing of XML data.
- **XQuery**: Query language used to extract and manipulate XML data.
- **Triggers**: Used to automate actions based on events within the database.
- **Stored Procedures**: Precompiled SQL code that can be executed on demand for performing complex database operations.

## Documentation Indices
- [**SQL Scripts**](https://github.com/arashabe/covid-clinical-xml-db-xquery/blob/main/Doc/Problem_and_Solution_SQL_XPath_Data_Workflow.md)
- [**XQuery Scripts**](https://github.com/arashabe/covid-clinical-xml-db-xquery/blob/main/Doc/Problems_and_Solutions_XQuery_Data_Workflow.md)

## Acknowledgments 
I would like to express my sincere gratitude to [Professor Paraboschi](https://unibg.unifind.cineca.it/individual?uri=http://irises.unibg.it/resource/person/2997) for the invaluable support and guidance provided throughout the Database 2 course and the duration of this project. 



# Changelog

All notable changes to this module will be documented in this file.

## 1.2.0 - 2022-10-14

- version update

## 1.2.0-beta - 2022-09-13

- the referenceId of the eChallan object is mapped to consumerCode of billing-service and collection-service
- If referenceId is not passed in the request, it will get set to same as the challanNo
- Decouple challan search SQL queries from billing service. (Support PSPCL event)

## 1.1.2 - 2022-02-02

- Dashboard Screen enhancements
- Expense screen enhancement validations

## 1.1.1 - 2021-11-25

- Fixes to the lastmoth summary and expense dashboard service

## 1.1.0 - 2021-09-23

- Added new service to get last month summary

## 1.0.3 - 2021-07-26

- Added _count API

## 1.0.2-SNAPSHOT - 2021-06-17

- Added suport for search based on multiple status.

## 1.0.1-SNAPSHOT - 2021-05-11

- Fixed security issue of untrusted data pass as user input.

## 1.0.0-SNAPSHOT - 2020-06-23

- Base version

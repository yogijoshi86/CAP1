# PoC: Data product consumption in CAP app

## Prerequisites

### Entitlements

Entitle the subaccount to hana, `hdi-shared` CF memory (3 units), and HANA Cloud tooling.

### Delta share

This simulates a data product producer publishing a delta share.

Create an x.509 certificate and private key for HDL Files access.
In principle, the producer would use one identity and the consumer would use another.
Provision an HDL Files instance and create a delta share within it using the `deploy_env.sh` and `upload_data.sh` scripts from [frontrunner-zero](https://github.tools.sap/hda-data-platform/frontrunner-zero/tree/dp-gateway-poc/delta-share).

## Application development

### Preparation

Create a CF space for app development and provision a HANA instance in it.
In the HANA Cloud Tools, map the instance to the CF space. (This should not be necessary but was for me.)

### Remote source configuration

This simulates the steps that would be done by formation setup and connection API calls.

Create a PSE representing the consumer identity:

```
CREATE PSE _SAP_DB_ACCESS_PSE_SUBACCOUNT_IDENTITY;
ALTER PSE _SAP_DB_ACCESS_PSE_SUBACCOUNT_IDENTITY SET OWN CERTIFICATE '<private key>
<public certificate>`
```

Create a remote source pointing to the HDL Files instance prepared earlier.

```
CREATE REMOTE SOURCE foosource ADAPTER "file" CONFIGURATION 'provider=hdlf;endpoint=a38c95c3-969c-4dd6-ac7d-c1600e3ed798.files.hdl.demo-hc-3-hdl-hc-dev.dev-aws.hanacloud.ondemand.com;' WITH CREDENTIAL TYPE 'X509' PSE _SAP_DB_ACCESS_PSE_SUBACCOUNT_IDENTITY;
```

### HDI grantor

Create a role with permission to create virtual tables using the remote source you created.
Using the connection API, this would already need to exist and be passed as the `grantToUser` field in the API request.

```
create user HDI_GRANTOR PASSWORD Password1 no FORCE_FIRST_PASSWORD_CHANGE VALID UNTIL FOREVER SET USERGROUP DEFAULT;
create role HDI_MAIN_ROLE;
grant create virtual table on remote source FOOSOURCE to HDI_MAIN_ROLE;
grant  HDI_MAIN_ROLE to HDI_GRANTOR with admin option;
```

Create a user-provided service in the CF space containing the credentials of the HDI grantor:

```
{
    "password": "Password1",
    "tags": [
        "hana"
    ],
    "user": "HDI_GRANTOR"
}
```

Bind the deployer application to the user-provided service in `mta.yaml`:

Add under `resources`:

```
  - name: hdi_grantor
    type: org.cloudfoundry.existing-service
```

And under `requires` for the `dp-consumer-db-deployer` module:

```
      - name: hdi_grantor
```

## Application development

### Init

```
cds init dp-consumer
cd dp-consumer
cds add hana --for production
cds add xsuaa --for production
cds add mta
cds add approuter
npm update --package-lock-only
```

### Create entity for delta table

Retrieve data product CSN (I just extracted it from FR0 repository).

Use that as the basis for `db/schema.cds`
```file=db/schema.cds
namespace sap.hc.dpconsumer;

@DeltaSharing.entity : 'schema'
context time_attendance_reporting_schema {
  @readonly
  @cds.persistence.exists
  entity time_attendance_reporting {
    @EndUserText.label : 'Employee ID'
    key EmployeeID : String(10);
    @EndUserText.label : 'Home/Host'
    HomeHost : String(40);
    @EndUserText.label : 'Father''s Name'
    FatherName : String(40);
    @EndUserText.label : 'Spouse''s Name'
    SpouseName : String(40);
    @EndUserText.label : 'Gender'
    Gender : String(1);
    @Semantics.date : true
    @EndUserText.label : 'Hire Date'
    HireDate : String(10);
    @EndUserText.label : 'Location'
    Location : String(40);
    @EndUserText.label : 'Campus ID'
    CampusID : String(20);
    @EndUserText.label : 'Day 1'
    Day1 : String(20);
    @EndUserText.label : 'Day 2'
    Day2 : String(20);
    @EndUserText.label : 'Day 3'
    Day3 : String(20);
    @EndUserText.label : 'Day 4'
    Day4 : String(20);
    @EndUserText.label : 'Day 5'
    Day5 : String(20);
    @EndUserText.label : 'Day 6'
    Day6 : String(20);
    @EndUserText.label : 'Day 7'
    Day7 : String(20);
    @EndUserText.label : 'Day 8'
    Day8 : String(20);
    @EndUserText.label : 'Day 9'
    Day9 : String(20);
    @EndUserText.label : 'Day 10'
    Day10 : String(20);
    @EndUserText.label : 'Day 11'
    Day11 : String(20);
    @EndUserText.label : 'Day 12'
    Day12 : String(20);
    @EndUserText.label : 'Day 13'
    Day13 : String(20);
    @EndUserText.label : 'Day 14'
    Day14 : String(20);
    @EndUserText.label : 'Day 15'
    Day15 : String(20);
    @EndUserText.label : 'Day 16'
    Day16 : String(20);
    @EndUserText.label : 'Day 17'
    Day17 : String(20);
    @EndUserText.label : 'Day 18'
    Day18 : String(20);
    @EndUserText.label : 'Day 19'
    Day19 : String(20);
    @EndUserText.label : 'Day 20'
    Day20 : String(20);
    @EndUserText.label : 'Day 21'
    Day21 : String(20);
    @EndUserText.label : 'Day 22'
    Day22 : String(20);
    @EndUserText.label : 'Day 23'
    Day23 : String(20);
    @EndUserText.label : 'Day 24'
    Day24 : String(20);
    @EndUserText.label : 'Day 25'
    Day25 : String(20);
    @EndUserText.label : 'Day 26'
    Day26 : String(20);
    @EndUserText.label : 'Day 27'
    Day27 : String(20);
    @EndUserText.label : 'Day 28'
    Day28 : String(20);
    @EndUserText.label : 'Day 29'
    Day29 : String(20);
    @EndUserText.label : 'Day 30'
    Day30 : String(20);
    @EndUserText.label : 'Day 31'
    Day31 : String(20);
    @EndUserText.label : 'Number of Days Time Off'
    DaysTimeOff : Integer;
    @EndUserText.label : 'Number of Days on Leave'
    DaysLoA : Integer;
  };
};
```

### Create service exposing the entity

``` file=srv/time.cds
using { sap.hc.dpconsumer as my } from '../db/schema.cds';

service time {
  @readonly
  @cds.persistence.exists
  entity time_attendance_reporting as select from my.time_attendance_reporting_schema.time_attendance_reporting {
    *
  };
}
```

### Create HDI artifacts to create the virtual table during deployment

``` file=db/src/HDI_VT.hdbgrants
{
  "hdi_grantor": {
    "object_owner": {
      "global_roles": [
        {
          "roles": ["HDI_MAIN_ROLE"]
        }
      ]
    },
    "application_user": {
      "global_roles": [
        {
          "roles": ["HDI_MAIN_ROLE"]
        }
      ]
    }
  }
}
```

``` file=db/src/sap.hc.dpconsumer.time_attendance_reporting_schema.time_attendance_reporting.hdbvirtualtable
VIRTUAL TABLE "sap.hc.dpconsumer.time_attendance_reporting_schema.time_attendance_reporting"
AT REMOTE.TIME_ATTENDANCE_REPORTING
```

``` file=db/src/sap.hc.dpconsumer.time_attendance_reporting_schema.time_attendance_reporting.hdbvirtualtableconfig
{
  "sap.hc.dpconsumer.time_attendance_reporting_schema.time_attendance_reporting" : {
    "target" : {
      "remote": "FOOSOURCE",
      "database": "sap_sf_time.time_attendance_reporting",
      "schema": "time_attendance_reporting_schema",
      "object": "time_attendance_reporting"
    }
  }
}
```

Using the APIs, the `database`, `schema`, and `object` fields would be obtained from a combination of the delta share name given by the Discovery API and the delta schema and delta table names given by the CSN endpoint.

### Create HDI artifact massaging delta table column names into uppercase

``` file=db/src/time.time_attendance_reporting.hdbview
VIEW "time.time_attendance_reporting" AS SELECT
  "time_attendance_reporting_0"."EmployeeID" AS EMPLOYEEID,
  "time_attendance_reporting_0"."HomeHost" AS HOMEHOST,
  "time_attendance_reporting_0"."FatherName" AS FATHERNAME,
  "time_attendance_reporting_0"."SpouseName" AS SPOUSENAME,
  "time_attendance_reporting_0"."Gender" AS GENDER,
  "time_attendance_reporting_0"."HireDate" AS HIREDATE,
  "time_attendance_reporting_0"."Location" AS LOCATION,
  "time_attendance_reporting_0"."CampusID" AS CAMPUSID,
  "time_attendance_reporting_0"."Day1" AS DAY1,
  "time_attendance_reporting_0"."Day2" AS DAY2,
  "time_attendance_reporting_0"."Day3" AS DAY3,
  "time_attendance_reporting_0"."Day4" AS DAY4,
  "time_attendance_reporting_0"."Day5" AS DAY5,
  "time_attendance_reporting_0"."Day6" AS DAY6,
  "time_attendance_reporting_0"."Day7" AS DAY7,
  "time_attendance_reporting_0"."Day8" AS DAY8,
  "time_attendance_reporting_0"."Day9" AS DAY9,
  "time_attendance_reporting_0"."Day10" AS DAY10,
  "time_attendance_reporting_0"."Day11" AS DAY11,
  "time_attendance_reporting_0"."Day12" AS DAY12,
  "time_attendance_reporting_0"."Day13" AS DAY13,
  "time_attendance_reporting_0"."Day14" AS DAY14,
  "time_attendance_reporting_0"."Day15" AS DAY15,
  "time_attendance_reporting_0"."Day16" AS DAY16,
  "time_attendance_reporting_0"."Day17" AS DAY17,
  "time_attendance_reporting_0"."Day18" AS DAY18,
  "time_attendance_reporting_0"."Day19" AS DAY19,
  "time_attendance_reporting_0"."Day20" AS DAY20,
  "time_attendance_reporting_0"."Day21" AS DAY21,
  "time_attendance_reporting_0"."Day22" AS DAY22,
  "time_attendance_reporting_0"."Day23" AS DAY23,
  "time_attendance_reporting_0"."Day24" AS DAY24,
  "time_attendance_reporting_0"."Day25" AS DAY25,
  "time_attendance_reporting_0"."Day26" AS DAY26,
  "time_attendance_reporting_0"."Day27" AS DAY27,
  "time_attendance_reporting_0"."Day28" AS DAY28,
  "time_attendance_reporting_0"."Day29" AS DAY29,
  "time_attendance_reporting_0"."Day30" AS DAY30,
  "time_attendance_reporting_0"."Day31" AS DAY31,
  "time_attendance_reporting_0"."DaysTimeOff" AS DAYSTIMEOFF,
  "time_attendance_reporting_0"."DaysLoA" AS DAYSLOA
FROM "sap.hc.dpconsumer.time_attendance_reporting_schema.time_attendance_reporting" AS "time_attendance_reporting_0"
```

### Enable quoted database names rather than plain names

In `package.json`, add the following configuration under the `"cds"` field:

```
"cdcs": { "sqlMapping": "quoted" }
```

_Note: this is not actually required.
If not set, then the virtual table HDI artifacts should use the plain naming convention, i.e., `SAP_HC_DPCONSUMER_TIME_ATTENDANCE_REPORTING_SCHEMA_TIME_ATTENDANCE_REPORTING`.
However, the view must still use `time.time_attendance_reporting`_

### Build and deploy

```
cf login --sso -a <api>
cds build --production
mbt build -t gen --mtar mta.tar
cf deploy gen/mta.tar
```

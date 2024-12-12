using { sap.hc.dpconsumer as my } from '../db/schema.cds';

service time {
  @readonly
  @cds.persistence.exists
  entity time_attendance_reporting as select from my.time_attendance_reporting_schema.time_attendance_reporting {
    *
  };
}

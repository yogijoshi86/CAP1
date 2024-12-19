using { dataproduct.model as my } from '../db/schema.cds';

service time {
  @readonly
  @cds.persistence.exists
  entity time_attendance_reporting as select from my.schema1.dp {
    *
  };
}

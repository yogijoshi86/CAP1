namespace sap.hc.dpconsumer;

@DeltaSharing.entity : 'schema'
context time_attendance_reporting_schema {
  @readonly
  @cds.persistence.exists
  @cds.dp.dpID : 'sap:sf:dataProduct:time_attendance_reporting:v1'
  entity time_attendance_reporting {
    @EndUserText.label : 'Day 1'
    key _c0 : String(5000);
    @EndUserText.label : 'Day 2'
    _c1 : String(5000);
    @EndUserText.label : 'Day 3'
    _c2 : String(5000);
    @EndUserText.label : 'Day 4'
    _c3 : String(5000);
  };
};
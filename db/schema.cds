namespace dataproduct.model;

@DeltaSharing.entity : 'schema'
context schema1 {
  @readonly
  @cds.persistence.exists
  entity dp {
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
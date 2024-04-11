namespace app.tpcds;

entity SupplierView as select from SUPPLIERDP;

@cds.persistence.exists
entity SUPPLIERDP {
  S_SUPPKEY : Integer;
  S_NAME  : String;
  S_ADDRESS  : String;
  S_NATIONKEY : Integer;
  S_PHONE: String;
  S_ACCTBAL: Double;
  S_COMMENT: String;
}
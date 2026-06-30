@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PARTNER BILLTO'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_PARTNER_BT_DIS
  as select distinct from ZI_PARTNER_BT
  // composition of target_data_source_name as _association_name
{
  key  BillingDocument,
  key  AddressID,
       StreetPrefixName1,
       CareOfName,
       HouseNumber,
       StreetName,
       StreetSuffixName1,
       StreetSuffixName2,
       CityName,
       DistrictName,
//       RegionName,
       PostalCode
       //  _association_name // Make association public
}

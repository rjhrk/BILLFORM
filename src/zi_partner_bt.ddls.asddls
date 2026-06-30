@AbapCatalog.sqlViewName: 'ZPARTNERBILLTO'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BilltoPartner'
@Metadata.ignorePropagatedAnnotations: true
define root view ZI_PARTNER_BT
  as select distinct from I_BillingDocumentPartner as _Billto
    left outer join       I_Address_2              as _BilltoAddr on _Billto.AddressID = _BilltoAddr.AddressID
    left outer join       I_Customer               as _Cust       on _Billto.Customer = _Cust.Customer
  //    left outer join       I_RegionText             as _Billtoregion on  _Billtoregion.Country  = 'IN'
  //                                                                    and _BilltoAddr.Region     = _BilltoAddr.Region
  //                                                                    and _Billtoregion.Language = 'E'
{
  key _Billto.BillingDocument,
      _Billto.AddressID,
      _BilltoAddr.StreetPrefixName1,
      _BilltoAddr.CareOfName,
      _BilltoAddr.HouseNumber,
      _BilltoAddr.StreetName,
      _BilltoAddr.StreetSuffixName1,
      _BilltoAddr.StreetSuffixName2,
      _BilltoAddr.CityName,
      _BilltoAddr.DistrictName,
      _BilltoAddr.Region,
      //      _Billtoregion.RegionName,
      _BilltoAddr.PostalCode,
      _Cust.TaxNumber3,
      _Cust.TelephoneNumber1

}
where
  PartnerFunction = 'AG'

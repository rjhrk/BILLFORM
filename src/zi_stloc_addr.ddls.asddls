@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Storage Location Address'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_STLOC_ADDR
  as select from    I_StorageLocationAddress as _Stor
    left outer join I_Address_2              as _StorAddr   on _StorAddr.AddressID = _Stor.AddressID
    left outer join I_RegionText             as _Storregion on  _Storregion.Country  = 'IN'
                                                            and _StorAddr.Region     = _Storregion.Region
                                                            and _Storregion.Language = 'E'
  //composition of target_data_source_name as _association_name
{
  key _Stor.Plant,
  key _Stor.StorageLocation,
      _StorAddr.HouseNumber,
      _StorAddr.StreetName,
      _StorAddr.StreetSuffixName1,
      _StorAddr.StreetSuffixName2,
      _StorAddr.StreetPrefixName1,
      _StorAddr.StreetPrefixName2,
      _StorAddr.CityName,
      _StorAddr.DistrictName,
      _Storregion.RegionName,
      _StorAddr.PostalCode
      //  _association_name // Make association public
}


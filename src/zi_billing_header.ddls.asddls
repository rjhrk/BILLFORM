@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Billing Form'
@Metadata.ignorePropagatedAnnotations: true

@UI.presentationVariant: [
  {
    sortOrder: [
      {
        by: 'BillingDocument'
      }
    ],
    maxItems: 10000
  }
]
define root view entity ZI_Billing_Header
  //  with parameters
  //    Billingdocment : vbeln
  as select from    ZI_ITEM_BILLING_1           as _Billing
    left outer join I_BillingDocument           as _Bill         on _Billing.BillingDocument = _Bill.BillingDocument
    left outer join I_Plant                     as _plant        on _plant.Plant = _Billing.Plant
    left outer join I_OrganizationAddress       as _Org          on _Org.AddressID = _plant.AddressID
    left outer join I_RegionText                as _PlantRegion  on  _PlantRegion.Country  = 'IN'
                                                                 and _PlantRegion.Region   = _Org.Region
                                                                 and _PlantRegion.Language = 'E'
    left outer join I_IN_BusinessPlaceTaxDetail as _PlantGst     on _Billing.Plant = _PlantGst.BusinessPlace
    left outer join I_Address_2                 as _Addr         on _Addr.AddressID = _plant.AddressID
    left outer join I_BillingDocumentPartner    as _Partner      on  _Partner.BillingDocument = _Billing.BillingDocument
                                                                 and _Partner.PartnerFunction = 'WE'
    left outer join I_Address_2                 as _ShipAddr     on _Partner.AddressID = _ShipAddr.AddressID
    left outer join I_Customer                  as _ShipCust     on _Partner.Customer = _ShipCust.Customer
    left outer join I_RegionText                as _shipregion   on  _shipregion.Country  = 'IN'
                                                                 and _ShipAddr.Region     = _shipregion.Region
                                                                 and _shipregion.Language = 'E'
    left outer join ZI_STLOC_ADDR               as _Stor         on  _Stor.Plant           = _Billing.Plant
                                                                 and _Stor.StorageLocation = _Billing.StorageLocation
  //    left outer join I_Address_2                 as _StorAddr     on _StorAddr.AddressID = _Stor.AddressID
  //    left outer join I_RegionText                as _Storregion   on  _Storregion.Country  = 'IN'
  //                                                                 and _StorAddr.Region     = _Storregion.Region
  //                                                                 and _Storregion.Language = 'E'
    left outer join ZI_PARTNER_BT               as _Billto       on _Billto.BillingDocument = _Billing.BillingDocument
  //   and _Billto.PartnerFunction = 'AG'
  //    left outer join       I_Address_2                 as _BilltoAddr   on _Billto.AddressID = _BilltoAddr.AddressID
    left outer join I_RegionText                as _Billtoregion on  _Billtoregion.Country  = 'IN'
                                                                 and _Billto.Region         = _Billtoregion.Region
                                                                 and _Billtoregion.Language = 'E'
    left outer join ZI_JOCG2                    as _Jocg5        on  _Jocg5.BillingDocument    = _Billing.BillingDocument
                                                                 and _Jocg5.ConditionRateValue = 2.5
    left outer join ZI_JOIG2                    as _Joig5        on  _Joig5.BillingDocument    = _Billing.BillingDocument
                                                                 and _Joig5.ConditionRateValue = 5
    left outer join ZI_JOCG2                    as _Jocg12       on  _Jocg12.BillingDocument    = _Billing.BillingDocument
                                                                 and _Jocg12.ConditionRateValue = 6
    left outer join ZI_JOIG2                    as _Joig12       on  _Joig12.BillingDocument    = _Billing.BillingDocument
                                                                 and _Joig12.ConditionRateValue = 12

    left outer join ZI_JOCG2                    as _Jocg18       on  _Jocg18.BillingDocument    = _Billing.BillingDocument
                                                                 and _Jocg18.ConditionRateValue = 9
    left outer join ZI_JOIG2                    as _Joig18       on  _Joig18.BillingDocument    = _Billing.BillingDocument
                                                                 and _Joig18.ConditionRateValue = 18


    left outer join I_IN_ElectronicDocInvoice   as _Einv         on _Einv.ElectronicDocSourceKey = _Billing.BillingDocument
    left outer join I_SalesDocument             as _SDHeader     on _SDHeader.SalesDocument = _Billing.SalesDocument
    left outer join ZI_JOURNAL                  as _Acc          on _Bill.BillingDocument = _Acc.BillingDocument

  //composition [0..*] of ZI_SUMMARY      as _Item1
  composition [0..*] of ZI_ITEM_BILLING as _Item

//  composition [0..*] of ZI_SUMMARY      as _Item1
  //inner join            YY1_EMAILID           as _PlantEmail on _Billing.Plant = _PlantEmail.Plant
  //  composition of target_data_source_name as _association_name
{
  key _Billing.BillingDocument,
      _Bill.BillingDocumentDate,
      concat(_Org.AddresseeName2,_Org.AddresseeName3)                               as PlantName,

      concat_with_space(
          concat_with_space(
              concat_with_space(
                  concat_with_space(
                      concat_with_space(
                          concat_with_space(
                              concat_with_space(
                                  concat_with_space(
                                      concat_with_space(
                                          _Org.HouseNumber,
                                          _Org.StreetName,
                                          1
                                      ),
                                      _Org.StreetPrefixName1,
                                      1
                                  ),
                                  _Org.StreetPrefixName2,
                                  1
                              ),
                              _Org.StreetSuffixName1,
                              1
                          ),
                          _Org.StreetSuffixName2,
                          1
                      ),
                      _Org.DistrictName,
                      1
                  ),
                  _Org.CityName,
                  1
              ),
             concat(upper( _PlantRegion.RegionName), ' -'),
              1
          ),
          _Org.PostalCode,
          1
      )                                                                             as PlantAddress,


      _Org._EmailAddress.EmailAddress                                               as PlantEmail,
      _Org._PhoneNumber.PhoneAreaCodeSubscriberNumber                               as PlantPhoneNumber,
      _PlantGst.IN_GSTIdentificationNumber                                          as PlantGST,
      //_Addr.VillageName                    as PlantCIN,
      cast( 'U02520TZ1998PTC008691' as abap.char(50) )                              as PlantCIN,
      concat('State Code : ', substring(_PlantGst.IN_GSTIdentificationNumber,1,2) ) as PlantStCode,
      //         ( _Bill.BillingDocumentDate - 30 )                   as DueDate,
      //   dats_add_days( _Bill.BillingDocumentDate, -30, 'FAIL' )                       as DueDate1,
      _Acc.NetDueDate                                                               as DueDate1,
      _Billing.Plant,
      //
      concat(
      _ShipAddr.CareOfName,
      _ShipAddr.StreetPrefixName1)                                                  as Shiptoname,
      _ShipAddr.AddressID,
      concat_with_space(
        concat_with_space(
          concat_with_space(
            concat_with_space(
              concat_with_space(
                concat_with_space(
                  concat_with_space(
                    _ShipAddr.HouseNumber,
                    _ShipAddr.StreetName,
                    1
                  ),
                  _ShipAddr.StreetSuffixName1,
                  1
                ),
                _ShipAddr.StreetSuffixName2,
                1
              ),
              _ShipAddr.CityName,
              1
            ),
            _ShipAddr.DistrictName,
            1
          ),
                     concat(upper( _shipregion.RegionName), ' -'),
      //      _ShipAddr.Region,
          1
        ),
        _ShipAddr.PostalCode,
        1
      )                                                                             as Shiptoaddress,

      _ShipCust.TaxNumber3                                                          as ShipToGST,
      //      _ShipAddr.Region                                 as ShiptoRegion,
      substring(_ShipCust.TaxNumber3,1,2)                                           as ShiptoRegion,
      _shipregion.RegionName                                                        as ShipToPlaceofSupply,

      concat_with_space(
          concat_with_space(
              concat_with_space(
                  concat_with_space(
                      concat_with_space(
                          concat_with_space(
                              concat_with_space(
                                  concat_with_space(
                                      concat_with_space(
                                          _Stor.HouseNumber,
                                          _Stor.StreetName,
                                          1
                                      ),
                                      _Stor.StreetPrefixName1,
                                      1
                                  ),
                                  _Stor.StreetPrefixName2,
                                  1
                              ),
                              _Stor.StreetSuffixName1,
                              1
                          ),
                          _Stor.StreetSuffixName2,
                          1
                      ),
                      _Stor.DistrictName,
                      1
                  ),
                  _Stor.CityName,
                  1
              ),
             concat(upper( _Stor.RegionName), ' -'),
              1
          ),
          _Stor.PostalCode,
          1
      )                                                                             as Despatchaddress,
      //      concat(
      //      _Billto.CareOfName,
      //      _Billto.StreetPrefixName1)           as Billtoname,
      concat_with_space(
          _Billto.CareOfName,
          _Billto.StreetPrefixName1,
          1
      )                                                                             as Billtoname,

      concat_with_space(
      concat_with_space(
      concat_with_space(
      concat_with_space(
        concat_with_space(
          concat_with_space(
            concat_with_space(
              _Billto.HouseNumber,
              _Billto.StreetName,
              1
            ),
            _Billto.StreetSuffixName1,
            1
          ),
          _Billto.StreetSuffixName2,
          1
        ),
        _Billto.CityName,
        1
      ),
      _Billto.DistrictName,
      1
      ),
               concat(upper(_Billtoregion.RegionName), ' -'),
      //      _Billto.Region,
      1
      ),
      _Billto.PostalCode,
      1
      )                                                                             as Billtoaddress,
      _Billto.TaxNumber3                                                            as BilltoGST,
      _Billto.TelephoneNumber1                                                      as BillToPh,
      //      _Billto.Region                                   as BilltoRegion,
      substring( _Billto.TaxNumber3  ,1,2)                                          as BilltoRegion,
      _Einv.IN_ElectronicDocAcknNmbr                                                as AckNo,
      _Einv.IN_ElectronicDocAcknDate                                                as Ackdt,
      _Einv.IN_ElectronicDocInvcRefNmbr                                             as Irn,
      _Einv.IN_ElectronicDocQRCodeTxt                                               as QrCode,
      _Einv.IN_EDocEInvcVehicleNumber                                               as VehicleNumber,
      _SDHeader.PurchaseOrderByCustomer                                             as RefNo,
      _SDHeader.CustomerPurchaseOrderDate                                           as PoDt,
      _Jocg5.TransactionCurrency,

      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Jocg5.TotJOCAmount                                                           as Joc5CGST,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Joig5.TotJOIAmount                                                           as Joc5IGST,

      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Jocg12.TotJOCAmount                                                          as Joc12CGST,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Joig12.TotJOIAmount                                                          as Joc12IGST,

      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Jocg18.TotJOCAmount                                                          as Joc18CGST,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Joig18.TotJOIAmount                                                          as Joc18IGST,

      case
      when _Bill.BillingDocumentType = 'F2' then 'TAX INVOICE'
      when _Bill.BillingDocumentType = 'G2' or _Bill.BillingDocumentType = 'CBRE' then 'CREDIT NOTE'
      when _Bill.BillingDocumentType = 'L2' then 'DEBIT NOTE'
      else
      'TAX INVOICE'
      end                                                                           as Heading,
      /*Associations */
//      _Item1,
      _Item


}

//where
//  _Billing.BillingDocument = $parameters.Billingdocment

//group by
//  _Billing.BillingDocument,
//  _Billing.BillingDocumentItem,
//  _Bill.BillingDocumentDate,
//  _Org.AddresseeName2,
//
//  _Org.HouseNumber,
//  _Org.StreetName,
//  _Org.StreetPrefixName1,
//  _Org.StreetPrefixName2,
//  _Org.StreetSuffixName1,
//  _Org.StreetSuffixName2,
//  _Org.DistrictName,
//  _Org.CityName,
//  _Org.PostalCode,
//
//  _Org._EmailAddress.EmailAddress,
//  _PlantGst.IN_GSTIdentificationNumber,
//  _Addr.VillageName,
//
//  _ShipAddr.CareOfName,
//  _ShipAddr.StreetPrefixName1,
//  _ShipAddr.HouseNumber,
//  _ShipAddr.StreetName,
//  _ShipAddr.StreetSuffixName1,
//  _ShipAddr.StreetSuffixName2,
//  _ShipAddr.CityName,
//  _ShipAddr.DistrictName,
//  _shipregion.RegionName,
//  _ShipAddr.PostalCode,
//  _ShipAddr.AddressID,
//  _StorAddr.HouseNumber,
//  _StorAddr.StreetName,
//  _StorAddr.StreetSuffixName1,
//  _StorAddr.StreetSuffixName2,
//  _StorAddr.CityName,
//  _StorAddr.DistrictName,
//  _Storregion.RegionName,
//  _StorAddr.PostalCode,
//
//  _BilltoAddr.CareOfName,
//  _BilltoAddr.StreetPrefixName1,
//  _BilltoAddr.HouseNumber,
//  _BilltoAddr.StreetName,
//  _BilltoAddr.StreetSuffixName1,
//  _BilltoAddr.StreetSuffixName2,
//  _BilltoAddr.CityName,
//  _BilltoAddr.DistrictName,
//  _Billtoregion.RegionName,
//  _BilltoAddr.PostalCode

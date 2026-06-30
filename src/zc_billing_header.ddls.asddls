@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Billing Form'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

@UI.presentationVariant: [{
  visualizations: [ { type: #AS_LINEITEM } ]
}]
define root view entity ZC_BILLING_HEADER
  provider contract transactional_query
  as projection on ZI_Billing_Header
{
  key     BillingDocument,
          //          BillingDocumentItem,
          BillingDocumentDate,
          PlantName,
          PlantAddress,
          PlantEmail,
          PlantPhoneNumber,
          PlantGST,
          PlantCIN,
          PlantStCode,
          DueDate1,
          Plant,
          Shiptoname,
          AddressID,
          Shiptoaddress,
          ShipToGST,
          ShiptoRegion,
          ShipToPlaceofSupply,
          Despatchaddress,
          Billtoname,
          Billtoaddress,
          BilltoGST,
          BillToPh,
          BilltoRegion,
          AckNo,
          Ackdt,
          Irn,
          QrCode,
          VehicleNumber,
          RefNo,
          PoDt,
          TransactionCurrency,
          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc5CGST,
          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc5IGST,

          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc12CGST,
          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc12IGST,

          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc18CGST,
          @DefaultAggregation: #NONE
          @Semantics.amount.currencyCode: 'TransactionCurrency'
          Joc18IGST,

          Heading,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BILL_FORM'
  virtual FileName   : abap.char( 60 ),
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BILL_FORM'
          @Semantics.mimeType: true
  virtual MimeType   : abap.char( 60 ),
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BILL_FORM'
          @Semantics.largeObject:{
            mimeType: 'MimeType',
            fileName: 'FileName',
            contentDispositionPreference: #ATTACHMENT
          }
  virtual Attachment : abap.rawstring( 0 ),
//          _Item1 : redirected to composition child ZC_SUMMARY,
          _Item  : redirected to composition child ZC_BILLING_ITEM

}

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ITEM'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ITEM_BILLING_1
  //  with parameters
  //    Billingdocment : vbeln
  as select distinct from I_BillingDocumentItem
  //composition of target_data_source_name as _association_name
{
  key  BillingDocument,
       //  key  YY1_SNo1_BDI,
       //       BillingDocumentItem,
       //  key BillingDocExtReferenceDocItem,
       Plant,
       StorageLocation,
       SalesDocument

       //  _association_name // Make association public
}
where
  StorageLocation <> ''
//  BillingDocument = $parameters.Billingdocment
group by
  BillingDocument,
  SalesDocument,
  //  BillingDocumentItem,
  //  YY1_SNo1_BDI,
  Plant,
  StorageLocation

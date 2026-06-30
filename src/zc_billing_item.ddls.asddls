@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BILLING ITEM'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_BILLING_ITEM
  as projection on ZI_ITEM_BILLING
{
  key BillingDocument,
      BillingDocumentDate,
      BillingDocumentItem,
      BillingDocumentItemText,
      ConsumptionTaxCtrlCode,
      MRP,
      Uom,
      BillingQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      BillingQuantity,
      TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Rate,
      RatePair,
      ConditionUOM,
      //      UomRate,
      PairQty,
      TaxRate,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Total,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      Discount,

      _Header : redirected to parent ZC_BILLING_HEADER

}

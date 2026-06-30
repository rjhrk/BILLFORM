@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Summary'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_SUMMARY
 // provider contract transactional_query
  as projection on ZI_SUMMARY
{
  key BillingDocument,
      TaxRate,
      TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'

      CGST,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      SGST,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      IGST,
      /* Associations */
         _Header1 : redirected to parent ZC_BILLING_HEADER
}

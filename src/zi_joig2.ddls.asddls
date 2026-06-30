@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JOIG Condition Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JOIG2
  as select from I_BillingDocumentItemPrcgElmnt
  //composition of target_data_source_name as _association_name
{
  key BillingDocument,
      ConditionRateValue,
      TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum(ConditionAmount) as TotJOIAmount
      //  _association_name // Make association public
}
where
  ConditionType = 'JOIG'
group by
  BillingDocument,
  ConditionRateValue,
  TransactionCurrency

@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JOCG Condition Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JOCG2
  as select from I_BillingDocumentItemPrcgElmnt
  //composition of target_data_source_name as _association_name
{
  key BillingDocument,
      ConditionRateValue,
      TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum(ConditionAmount) as TotJOCAmount
      //  _association_name // Make association public
}
where
  ConditionType = 'JOCG'
group by
  BillingDocument,
  ConditionRateValue,
  TransactionCurrency

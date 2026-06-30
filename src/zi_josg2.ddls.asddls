@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'JOSG Condition Type'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JOSG2
  as select from I_BillingDocumentItemPrcgElmnt
{
  key BillingDocument,
      ConditionRateValue,
      TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      sum(ConditionAmount) as TotJOSAmount
}
where
  ConditionType = 'JOSG'
group by
  BillingDocument,
  ConditionRateValue,
  TransactionCurrency

@AbapCatalog.sqlViewName: 'ZSUMMARY'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Summary'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_SUMMARY
  as select from    I_BillingDocument as _Bill
    left outer join ZI_JOIG2          as _Joi on _Bill.BillingDocument = _Joi.BillingDocument
    left outer join ZI_JOCG2          as _Joc on _Bill.BillingDocument = _Joc.BillingDocument
    left outer join ZI_JOSG2          as _Jos on _Bill.BillingDocument = _Joc.BillingDocument
   association to parent ZI_Billing_Header as _Header1 on _Header1.BillingDocument = $projection.BillingDocument
{
  key _Bill.BillingDocument,
      _Joi.TransactionCurrency,
      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      case when _Joi.ConditionRateValue > 0 then  cast( _Joi.ConditionRateValue as abap.dec(15,2) )
      when _Joc.ConditionRateValue > 0 then cast( _Joc.ConditionRateValue * 2 as abap.dec(15,2) ) end as TaxRate,
      _Joc.TotJOCAmount                                                                               as CGST,
      _Jos.TotJOSAmount                                                                               as SGST,
      _Joi.TotJOIAmount                                                                               as IGST,
      /* Associations */
        _Header1
}

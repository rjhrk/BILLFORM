@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'ZPRO CONDITION TYPE'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ZPRO_1
  as select from I_BillingDocumentItemPrcgElmnt as _Cond
    inner join   I_BillingDocumentItem          as _BillingItem on  _BillingItem.BillingDocument     = _Cond.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _Cond.BillingDocumentItem
  //  composition of target_data_source_name as _association_name
{
  key _Cond.BillingDocument,
  key _Cond.BillingDocumentItem,
      _Cond.ConditionType,
      _Cond.ConditionRateValue,
      _Cond.TransactionCurrency,

      @DefaultAggregation: #NONE
      @Semantics.amount.currencyCode: 'TransactionCurrency'
      _Cond.ConditionAmount,
      _Cond.ConditionQuantityUnit,
      cast( _Cond.ConditionRateValue as abap.dec(15,2)) as RatePAA,

      //      (cast(cast( _BillingItem.YY1_Pairqty4_BDI as abap.numc(10) ) as abap.fltp) / cast( _BillingItem.BillingQuantity as abap.fltp ))
      //                      *
      //                      cast( _Cond.ConditionRateValue as abap.fltp ) as RateCV

      cast(
            (
              cast(
                    cast( _BillingItem.YY1_Pairqty4_BDI as abap.numc(20) )
                    as abap.fltp
                  )
              /
              cast( _BillingItem.BillingQuantity as abap.fltp )
            )
            *
            cast( _Cond.ConditionRateValue as abap.fltp )
          as abap.dec(15,2)
      )                                                 as RateCV,
      
      _Cond.ConditionInactiveReason

      // _association_name // Make association public
}
where
      _Cond.ConditionType      = 'ZPRO'

  and _Cond.ConditionBaseValue > 0

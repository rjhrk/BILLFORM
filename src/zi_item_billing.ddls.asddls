@AbapCatalog.sqlViewName: 'ZITEM'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BILLING ITEM'
@Metadata.ignorePropagatedAnnotations: true
define view ZI_ITEM_BILLING
  as select from    I_BillingDocumentItem          as _BillingItem
    inner join      I_BillingDocument              as _Bill     on _BillingItem.BillingDocument = _Bill.BillingDocument
    inner join      I_UnitOfMeasureText            as _Uomname  on  _BillingItem.BillingQuantityUnit = _Uomname.UnitOfMeasure
                                                                and _Uomname.Language                = 'E'
    inner join      I_ProductPlantBasic            as _HSN      on  _HSN.Plant   = _BillingItem.Plant
                                                                and _HSN.Product = _BillingItem.Product
    inner join      I_Product                      as _Prod     on _Prod.Product = _BillingItem.Product

    left outer join ZI_PRODUCT                     as _Prod1    on _Prod1.Product = _BillingItem.Product
    inner join      ZI_ZPRO_1                      as _ZPRO     on  _BillingItem.BillingDocument     = _ZPRO.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _ZPRO.BillingDocumentItem
                                                                and _ZPRO.ConditionType              = 'ZPRO'

    inner join      I_SalesDocumentItem            as _SaleItem on  _SaleItem.SalesDocument     = _BillingItem.SalesDocument
                                                                and _SaleItem.SalesDocumentItem = _BillingItem.SalesDocumentItem

    left outer join I_BillingDocumentItemPrcgElmnt as _Jocg     on  _BillingItem.BillingDocument     = _Jocg.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _Jocg.BillingDocumentItem
                                                                and _Jocg.ConditionType              = 'JOCG'
    left outer join I_BillingDocumentItemPrcgElmnt as _Josg     on  _BillingItem.BillingDocument     = _Josg.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _Josg.BillingDocumentItem
                                                                and _Josg.ConditionType              = 'JOSG'
    left outer join I_BillingDocumentItemPrcgElmnt as _Joig     on  _BillingItem.BillingDocument     = _Joig.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _Joig.BillingDocumentItem
                                                                and _Joig.ConditionType              = 'JOIG'
    left outer join I_BillingDocumentItemPrcgElmnt as _ZHID     on  _BillingItem.BillingDocument     = _ZHID.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _ZHID.BillingDocumentItem
                                                                and _ZHID.ConditionType              = 'ZHID'
    left outer join I_BillingDocumentItemPrcgElmnt as _ZLID     on  _BillingItem.BillingDocument     = _ZLID.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _ZLID.BillingDocumentItem
                                                                and _ZLID.ConditionType              = 'ZLID'
    left outer join I_BillingDocumentItemPrcgElmnt as _ZDI1     on  _BillingItem.BillingDocument     = _ZDI1.BillingDocument
                                                                and _BillingItem.BillingDocumentItem = _ZDI1.BillingDocumentItem
                                                                and _ZDI1.ConditionType              = 'ZDI1'

  association to parent ZI_Billing_Header as _Header on _Header.BillingDocument = $projection.BillingDocument
  //                                                      and _Header.fiscalyear         = $projection.fiscalyear
  //                                                      and _Header.companycode        = $projection.companycode
{
  key _BillingItem.BillingDocument,
      _Bill.BillingDocumentDate,
      _BillingItem.BillingDocumentItem,
      _BillingItem.BillingDocumentItemText,
      _HSN.ConsumptionTaxCtrlCode,
      _Prod.YY1_MRPindicator_PRD                                                                             as MRP,
      _Uomname.UnitOfMeasureLongName                                                                         as Uom,
      _BillingItem.BillingQuantityUnit,
      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      _BillingItem.BillingQuantity,
      _ZPRO.TransactionCurrency,
      //      @DefaultAggregation: #NONE
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'

      //      case when _ZPRO.ConditionQuantityUnit = 'PAA' then _ZPRO.RatePAA
      //      when _ZPRO.ConditionQuantityUnit = 'CS' then _ZPRO.RateCV  end                                         as Rate,

      //      case when _BillingItem.BillingQuantityUnit = 'PAA' then _ZPRO.RatePAA
      //          when _BillingItem.BillingQuantityUnit = 'CS' then _ZPRO.RateCV  end                                as Rate,
      //
      //      @DefaultAggregation: #NONE
      //      @Semantics.amount.currencyCode: 'TransactionCurrency'
      //
      //      _ZPRO.ConditionRateValue                                                                               as RatePair,
      //

      case
      when _ZPRO.ConditionQuantityUnit  = 'PAA'
      and _Prod.ProductType      = 'ZMIH'
      then
      cast(
      cast( _Prod1.Pairs as abap.dec(10,2) ) *
      cast( _ZPRO.ConditionRateValue as abap.dec(15,2) )
      as abap.dec(15,2)
      )

      else
      cast( _ZPRO.ConditionRateValue as abap.dec(15,2) )

      end                                                                                                    as Rate,

      //      cast( _ZPRO.ConditionRateValue  as abap.dec( 13, 2 )) as PairPrice,

      case
        when _ZPRO.ConditionQuantityUnit  = 'CS'
         and _Prod.ProductType      = 'ZMIH'
      then
      cast( _ZPRO.ConditionRateValue as abap.fltp ) /  cast( _Prod1.Pairs             as abap.fltp )

        else
          cast( _ZPRO.ConditionRateValue as abap.fltp )

      end                                                                                                    as RatePair,

      _ZPRO.ConditionQuantityUnit                                                                            as ConditionUOM,

      _BillingItem.YY1_Pairqty4_BDI                                                                          as PairQty,

      case when _Joig.ConditionRateValue > 0 then  cast( _Joig.ConditionRateValue as abap.dec(15,2) )
           when _Jocg.ConditionRateValue > 0 then cast( _Jocg.ConditionRateValue * 2 as abap.dec(15,2) ) end as TaxRate,
      _ZPRO.ConditionAmount                                                                                  as Total,
      //_ZPRO.Conditionratevalue *
      //      (_ZHID.ConditionAmount + _ZLID.ConditionAmount + _ZDI1.ConditionAmount) * -1                           as Discount,
      cast(
      (
          coalesce( _ZHID.ConditionAmount, 0 )
        + coalesce( _ZLID.ConditionAmount, 0 )
        + coalesce( _ZDI1.ConditionAmount, 0 )
      ) * -1
      as abap.dec(23,2))                                                                                     as Discount,


      /* Associations */
      _Header
}
where
  _BillingItem.BillingQuantity > 0

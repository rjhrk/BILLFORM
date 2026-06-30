@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_JOURNAL
  as select distinct from I_JournalEntryItem
  //composition of target_data_source_name as _association_name
{
  key ReferenceDocument as BillingDocument,
      LedgerGLLineItem,
      NetDueDate
      //  _association_name // Make association public
}
where
      LedgerGLLineItem =  '000001'
  and NetDueDate       <> '00000000'

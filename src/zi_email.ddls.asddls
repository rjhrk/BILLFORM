@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Mail'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_EMAIL
  as select from I_Customer            as _Cust
    inner join   I_OrganizationAddress as _Org on _Cust.AddressID = _Org.AddressID
  //composition of target_data_source_name as _association_name
{
  key _Cust.Customer,
      _Org._EmailAddress.EmailAddress,
      _Org._EmailAddress.CommMediumSequenceNumber
      //  _association_name // Make association public
}

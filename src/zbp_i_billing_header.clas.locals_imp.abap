CLASS lhc_zi_billing_header DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR zi_billing_header RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR zi_billing_header RESULT result.

    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE zi_billing_header.

    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE zi_billing_header.

    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE zi_billing_header.

    METHODS read FOR READ
      IMPORTING keys FOR READ zi_billing_header RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK zi_billing_header.

    METHODS submit FOR MODIFY
      IMPORTING keys FOR ACTION zi_billing_header~submit.

ENDCLASS.

CLASS lhc_zi_billing_header IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD create.
  ENDMETHOD.

  METHOD update.
  ENDMETHOD.

  METHOD delete.

    TYPES: BEGIN OF ty_request,
             pdfbyte1               TYPE string,
             authorizedsignatory    TYPE string,
             signername             TYPE string,
             topleft                TYPE i,
             bottomleft             TYPE i,
             topright               TYPE i,
             bottomright            TYPE i,
             excludepageno          TYPE string,
             invoicenumber          TYPE string,
             pageno                 TYPE i,
             printdatetime          TYPE string,
             findauth               TYPE string,
             findauthlocation       TYPE i,
             fontsize               TYPE i,
             adjustcoordinates      TYPE i,
             signonlysearchtextpage TYPE i,
             keepprevious           TYPE i,
             copies                 TYPE i,
           END OF ty_request.

    DATA: ls_request TYPE ty_request.

    DATA: lv_pdf_xstring TYPE xstring,
          lv_base64      TYPE string.
    DATA: lv_payload TYPE string.
    READ ENTITIES OF zi_billing_header IN LOCAL MODE
     ENTITY zi_billing_header
       FIELDS ( billingdocument )
       WITH CORRESPONDING #( keys )
     RESULT DATA(lt_billing_docs)
     FAILED DATA(ls_failed).

    LOOP AT lt_billing_docs ASSIGNING FIELD-SYMBOL(<ls_doc>).
      lv_pdf_xstring = zcl_bill_form=>get_pdf( <ls_doc>-billingdocument ).



      lv_base64 = cl_web_http_utility=>encode_x_base64(
                   unencoded = lv_pdf_xstring ).
      IF sy-subrc IS INITIAL.
        DATA(lo_http_destination) =
            cl_http_destination_provider=>create_by_url( 'http://160.187.250.102:81/SignPDF_Base64String' ).

        DATA(lo_web_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .
        DATA(lo_web_http_request) = lo_web_http_client->get_http_request( ).
*        lo_web_http_request->set_header_fields( VALUE #(
*                     (  name = 'Authorization' value = 'Basic UnNjI0AxIWVSMDk0NDUkQHN2YjpzY0VSTDBAIUdAY3ZydGN4Ug==' )
*                    ) ).

        lo_web_http_request->set_header_fields( VALUE #(
                      (  name = 'Authorization' value = 'Basic UnNjI0AxIWVSMDk0NDUkQHN2YjpzY0VSTDBAIUdAY3ZydGN4Ug==' )
                        (  name = 'Content-Type' value = 'application/json' ) ) ).
**Payload
        ls_request-pdfbyte1            = lv_base64.
        ls_request-authorizedsignatory = 'Webtel'.
        ls_request-signername          = 'Manoj Kumar'.
        ls_request-topleft             = 100.
        ls_request-bottomleft          = 290.
        ls_request-topright            = 190.
        ls_request-bottomright         = 3400.
        ls_request-excludepageno       = ''.
        ls_request-invoicenumber       = <ls_doc>-billingdocument.
        ls_request-pageno              = -1.
        ls_request-printdatetime       = ''.
        ls_request-findauth            = 'Authorised signatory'.
        ls_request-findauthlocation    = 0.
        ls_request-fontsize            = 24.
        ls_request-adjustcoordinates   = 0.
        ls_request-signonlysearchtextpage = 1.
        ls_request-keepprevious        = 0.
        ls_request-copies              = 0.

        /ui2/cl_json=>serialize(
          EXPORTING
            data        = ls_request
            pretty_name = /ui2/cl_json=>pretty_mode-camel_case
          RECEIVING
            r_json      = lv_payload ).

        lo_web_http_client = cl_web_http_client_manager=>create_by_http_destination( lo_http_destination ) .

        lo_web_http_request = lo_web_http_client->get_http_request( ).

        lo_web_http_request->set_text(
                                 EXPORTING
                                 i_text   = lv_payload  ).
        DATA(lo_web_http_response_post) = lo_web_http_client->execute( if_web_http_client=>post ).

        DATA(lv_response_post) = lo_web_http_response_post->get_text( ).

        DATA(lv_response_status) = lo_web_http_response_post->get_status( ).

        DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).
        DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
        REPLACE ALL OCCURRENCES OF 's4hana' IN lv_host WITH 'mail.s4hana' .
        lo_mail->set_sender( iv_address = |do.not.reply@{ lv_host }| ).

        lo_mail->add_recipient( iv_address = 'hariramakrishnan.t@altrockstech.com' ).
        lo_mail->set_subject( |Invoice No: { <ls_doc>-billingdocument }| ).

        lo_mail->set_main(
          cl_bcs_mail_textpart=>create_instance(
            iv_content      = |<html><body>|          &&
                              |<p>Dear Customer,</p>| &&
                              |<p>Invoice <b>{ <ls_doc>-billingdocument }</b> is attached.</p>| &&
*                                |<p>Testing Invoice <b>{ lv_billing_doc }</b> is attached.</p>| &&
                               |{ lv_payload }|    &&
                              |<p>Thank You.</p>|     &&
                              |</body></html>|
            iv_content_type = 'text/html'
          )
        ).
*        rv_response = lv_response_post.
*        lo_mail->send( ).

*        APPEND VALUE #(
*                 %tky = <ls_doc>-%tky
*                 %msg = new_message_with_text(
*                          severity = if_abap_behv_message=>severity-success
*                          text     = |Invoice { <ls_doc>-billingdocument } emailed successfully| )
*               ) TO reported-zi_billing_header.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

  METHOD read.
    IF keys IS NOT INITIAL.
      SELECT FROM zi_billing_header
        FIELDS billingdocument
        FOR ALL ENTRIES IN @keys
        WHERE billingdocument = @keys-billingdocument
        INTO CORRESPONDING FIELDS OF TABLE @result.
    ENDIF.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD submit.
    DATA: lv_pdf_xstring TYPE xstring,
          lv_billing_doc TYPE string.
    READ ENTITIES OF zi_billing_header IN LOCAL MODE
        ENTITY zi_billing_header
          FIELDS ( billingdocument )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_billing_docs)
        FAILED DATA(ls_failed).
    DATA :lv_email TYPE c LENGTH 512.
    " Step 2: Loop over selected grid elements
    LOOP AT lt_billing_docs ASSIGNING FIELD-SYMBOL(<ls_doc>).
      TRY.
          lv_billing_doc = |{ <ls_doc>-billingdocument ALPHA = OUT }|.

          " Step 3: Generate PDF binary data stream
          lv_pdf_xstring = zcl_bill_form=>get_pdf( <ls_doc>-billingdocument ).

          IF lv_pdf_xstring IS INITIAL.
            APPEND VALUE #(
              %tky = <ls_doc>-%tky
              %msg = new_message_with_text(
                       severity = if_abap_behv_message=>severity-warning
                       text     = 'PDF generation returned an empty result' )
            ) TO reported-zi_billing_header.
            CONTINUE.
          ENDIF.

          " Step 4: Construct email transmission object
          SELECT SINGLE * FROM i_billingdocument WHERE billingdocument = @<ls_doc>-billingdocument  INTO @DATA(ls_bill).
          SELECT * FROM zi_email  WHERE customer = @ls_bill-soldtoparty INTO TABLE @DATA(lt_email).
          DATA(lv_host) = cl_abap_context_info=>get_system_url( ).
          REPLACE ALL OCCURRENCES OF 's4hana' IN lv_host WITH 'mail.s4hana' .
          DATA(lo_mail) = cl_bcs_mail_message=>create_instance( ).

          lo_mail->set_sender( iv_address = |do.not.reply@{ lv_host }| ).

          READ TABLE lt_email INTO DATA(ls_email) WITH KEY commmediumsequencenumber = '001'.
          IF sy-subrc IS INITIAL.
            lv_email = ls_email-emailaddress.
            lo_mail->add_recipient( iv_address = lv_email ).
            DELETE lt_email WHERE commmediumsequencenumber = ls_email-commmediumsequencenumber.
          ENDIF.

          LOOP AT lt_email INTO ls_email.
            CLEAR:   lv_email.
            lv_email = ls_email-emailaddress.
            lo_mail->add_recipient( iv_address = lv_email
                                    iv_copy    = cl_bcs_mail_message=>cc ).
            CLEAR: ls_email.
          ENDLOOP.

          lo_mail->set_subject( |Invoice No: { lv_billing_doc }| ).
*          lo_mail->set_subject( |Testing Invoice No: { lv_billing_doc }| ).

          lo_mail->set_main(
            cl_bcs_mail_textpart=>create_instance(
              iv_content      = |<html><body>|          &&
                                |<p>Dear Customer,</p>| &&
                                |<p>Invoice <b>{ lv_billing_doc }</b> is attached.</p>| &&
*                                |<p>Testing Invoice <b>{ lv_billing_doc }</b> is attached.</p>| &&
                                |<p>Thank You.</p>|     &&
                                |</body></html>|
              iv_content_type = 'text/html'
            )
          ).

          " Step 5: Wrap and attach PDF binary payload data stream
          DATA(lo_attachment) = cl_bcs_mail_binarypart=>create_instance(
              iv_content      = lv_pdf_xstring
              iv_content_type = 'application/pdf'
              iv_filename     = |Invoice_ { lv_billing_doc }.pdf|
          ).
          lo_mail->add_attachment( lo_attachment ).

          " Step 6: Dispatch email
          lo_mail->send( ).

          APPEND VALUE #(
            %tky = <ls_doc>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-success
                     text     = |Invoice { lv_billing_doc } emailed successfully| )
          ) TO reported-zi_billing_header.
        CATCH cx_fp_fdp_error
       cx_fp_form_reader
       cx_fp_ads_util INTO DATA(lx_pdf).
          APPEND VALUE #( %tky = <ls_doc>-%tky ) TO failed-zi_billing_header.
          APPEND VALUE #(
            %tky = <ls_doc>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |PDF Engine Error: { lx_pdf->get_text( ) }| )
          ) TO reported-zi_billing_header.

        CATCH cx_bcs_mail INTO DATA(lx_mail).
          APPEND VALUE #( %tky = <ls_doc>-%tky ) TO failed-zi_billing_header.
          APPEND VALUE #(
            %tky = <ls_doc>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |Mail Engine Error: { lx_mail->get_text( ) }| )
          ) TO reported-zi_billing_header.

        CATCH cx_root INTO DATA(lx_root).
          APPEND VALUE #( %tky = <ls_doc>-%tky ) TO failed-zi_billing_header.
          APPEND VALUE #(
            %tky = <ls_doc>-%tky
            %msg = new_message_with_text(
                     severity = if_abap_behv_message=>severity-error
                     text     = |Unexpected System Error: { lx_root->get_text( ) }| )
          ) TO reported-zi_billing_header.
      ENDTRY.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_zi_billing_header DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_zi_billing_header IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.

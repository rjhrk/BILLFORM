CLASS zcl_bill_form DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_sadl_exit_calc_element_read.
    CLASS-METHODS:
      get_pdf
        IMPORTING
                  im_bank         TYPE zc_billing_header-billingdocument
*                  im_cc           TYPE zc_header-companycode
*                  im_fis          TYPE zc_header-fiscalyear
        RETURNING VALUE(rt_v_pdf) TYPE xstring
        RAISING
                  cx_fp_fdp_error
                  cx_fp_form_reader
                  cx_fp_ads_util.
    CLASS-DATA: mc_duplicate_call TYPE abap_boolean.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZCL_BILL_FORM IMPLEMENTATION.


  METHOD if_sadl_exit_calc_element_read~calculate.
    DATA:
      lt_fi_header TYPE STANDARD TABLE OF zc_billing_header INITIAL SIZE 0,
      ls_fi_header TYPE zc_billing_header.
    lt_fi_header = CORRESPONDING #( it_original_data ).

    LOOP AT lt_fi_header ASSIGNING FIELD-SYMBOL(<fs_s_header>).

      "Is attachment required
      IF line_exists( it_requested_calc_elements[ table_line = 'ATTACHMENT' ] ) AND
          mc_duplicate_call IS INITIAL.
        TRY.

            <fs_s_header>-attachment = get_pdf(
                                         im_bank =   <fs_s_header>-billingdocument ).

          CATCH cx_fp_fdp_error cx_fp_form_reader cx_fp_ads_util INTO DATA(lx_data).
            DATA(lv_message) = lx_data->get_text( ).

            "handle exception
        ENDTRY.
      ENDIF.

      <fs_s_header>-filename = |{ <fs_s_header>-billingdocument ALPHA = OUT }_output.pdf|.
      <fs_s_header>-mimetype = 'application/pdf'.

    ENDLOOP.

    ct_calculated_data = CORRESPONDING #( lt_fi_header ).

  ENDMETHOD.


  METHOD if_sadl_exit_calc_element_read~get_calculation_info.
    APPEND to_upper( 'BILLINGDOCUMENT' ) TO et_requested_orig_elements.
  ENDMETHOD.


  METHOD get_pdf.

    mc_duplicate_call = abap_true.

    DATA(lo_fdp_api) = cl_fp_fdp_services=>get_instance(
       iv_max_depth          = 1
       iv_service_definition = 'ZBILLING_FORM_SRV' ).

    DATA(lt_keys)    = lo_fdp_api->get_keys( ).

    lt_keys[ name = 'BILLINGDOCUMENT' ]-value = im_bank.

    DATA lv_data TYPE xstring.
    lv_data = lo_fdp_api->read_to_xml_v2(
      it_select = lt_keys
    ).

*    DATA: lv_pdf_compressed TYPE xstring.
*
*    cl_abap_gzip=>compress_binary(
*      EXPORTING
*        raw_in   = rt_v_pdf
*      IMPORTING
*        gzip_out = lv_pdf_compressed
*    ).


    DATA(lv_string) = cl_abap_conv_codepage=>create_in( )->convert( lv_data ).

    DATA(lv_xml) = lo_fdp_api->get_xsd_v2( ).

    DATA(lv_string2) = cl_abap_conv_codepage=>create_in( )->convert( lv_xml ).

    DATA(lo_reader) = cl_fp_form_reader=>create_form_reader( 'ZBILL_FORM_OBJECT' ).

    DATA(ls_layout) = lo_reader->get_layout( ).


    cl_fp_ads_util=>render_pdf( EXPORTING iv_xml_data   = lv_data
                                      iv_xdp_layout = ls_layout
                                      iv_locale     = 'en_US'
                            IMPORTING ev_pdf        = rt_v_pdf
                                     ).
    mc_duplicate_call = abap_false.



  ENDMETHOD.
ENDCLASS.

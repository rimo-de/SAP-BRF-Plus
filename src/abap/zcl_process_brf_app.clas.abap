CLASS zcl_process_brf_app DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        VALUE(iv_func_id) TYPE if_fdt_types=>id.

    CLASS-METHODS get_instance
      IMPORTING
        VALUE(iv_func_id) TYPE if_fdt_types=>id
          DEFAULT 'DD80909B95BA1FE0A2A90543E4A18A7B'
      RETURNING
        VALUE(ro_instance) TYPE REF TO zcl_process_brf_app.

    METHODS process
      IMPORTING
        !iv_total_revenue TYPE zfi_de_amount
        !iv_total_expense TYPE zfi_de_amount
      RETURNING
        VALUE(rs_result) TYPE zfi_s_function_result.

  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA mo_instance TYPE REF TO zcl_process_brf_app.
    DATA mo_factory   TYPE REF TO if_fdt_factory.
    DATA mo_function  TYPE REF TO if_fdt_function.
    DATA mo_result    TYPE REF TO if_fdt_result.
    DATA mv_func_id   TYPE if_fdt_types=>id.
ENDCLASS.


CLASS zcl_process_brf_app IMPLEMENTATION.

  METHOD constructor.
    TRY.
        mo_factory  = cl_fdt_factory=>get_instance( ).
        mo_function = mo_factory->get_function( iv_func_id ).
        mv_func_id  = iv_func_id.
      CATCH cx_fdt_input.
        " Handle gracefully in a real app
    ENDTRY.
  ENDMETHOD.


  METHOD get_instance.
    IF mo_instance IS NOT BOUND.
      mo_instance = NEW #( iv_func_id = iv_func_id ).
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.


  METHOD process.
    DATA: lt_name_value          TYPE abap_parmbind_tab,
          ls_name_value          TYPE abap_parmbind,
          lv_timestamp           TYPE timestamp,
          lr_zfi_function_input  TYPE REF TO data,
          lr_zfi_function_result TYPE REF TO data.

    GET TIME STAMP FIELD lv_timestamp.
    ls_name_value-name = 'ZFI_FUNCTION_INPUT'.

    CREATE DATA lr_zfi_function_input TYPE zfi_s_function_input.
    ASSIGN lr_zfi_function_input->* TO FIELD-SYMBOL(<fs_zfi_function_input>).

    ASSIGN COMPONENT 'ZFI_TOTAL_REVENUE' OF STRUCTURE <fs_zfi_function_input>
      TO FIELD-SYMBOL(<fs_total_revenue>).
    ASSIGN COMPONENT 'ZFI_TOTAL_EXPENSE' OF STRUCTURE <fs_zfi_function_input>
      TO FIELD-SYMBOL(<fs_total_expense>).

    <fs_total_revenue> = iv_total_revenue.
    <fs_total_expense> = iv_total_expense.
    ls_name_value-value = lr_zfi_function_input.

    cl_fdt_function_process=>move_data_to_data_object(
      EXPORTING
        ir_data        = lr_zfi_function_input
        iv_function_id = mv_func_id
        iv_timestamp   = lv_timestamp
        iv_data_object = 'DD80909B95BA1FE0A1FF809F07A1CA7B' " ZFI_FUNCTION_INPUT (data object ID)
      IMPORTING
        er_data        = ls_name_value-value ).

    INSERT ls_name_value INTO TABLE lt_name_value.
    CLEAR ls_name_value.

    cl_fdt_function_process=>get_data_object_reference(
      EXPORTING
        iv_function_id     = mv_func_id
        iv_data_object     = '_V_RESULT'
        iv_timestamp       = lv_timestamp
        iv_trace_generation = abap_false
      IMPORTING
        er_data            = lr_zfi_function_result ).

    READ TABLE lt_name_value ASSIGNING FIELD-SYMBOL(<ls_name_value>)
         WITH KEY name = '_V_E_METH_PARAM_RESULT_ED'.
    CHECK <ls_name_value> IS ASSIGNED.

    ASSIGN <ls_name_value>-value->* TO FIELD-SYMBOL(<fs_result_structure>).

    DATA(lo_structdescr) =
      CAST cl_abap_structdescr(
        cl_abap_structdescr=>describe_by_data( EXPORTING p_data = <fs_result_structure> ) ).
    DATA(lt_components) = lo_structdescr->get_components( ).

    LOOP AT lt_components ASSIGNING FIELD-SYMBOL(<fs_components>).
      ASSIGN COMPONENT |{ <fs_components>-name }|
             OF STRUCTURE <fs_result_structure> TO FIELD-SYMBOL(<fs_brf_value>).
      ASSIGN COMPONENT <fs_components>-name
             OF STRUCTURE rs_result            TO FIELD-SYMBOL(<fs_result_value>).
      <fs_result_value> = <fs_brf_value>.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS zcl_work_order_crud_validator DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS validate_create_order
      IMPORTING
        i_customer_id   TYPE string
        i_technician_id TYPE string
        i_priority      TYPE string
      RETURNING
        VALUE(rv_valid)  TYPE abap_bool.

    METHODS validate_update_order
      IMPORTING
        i_work_order_id TYPE string
        i_status        TYPE string
      RETURNING
        VALUE(rv_valid)  TYPE abap_bool.

    METHODS validate_delete_order
      IMPORTING
        i_work_order_id TYPE string
        i_status        TYPE string
      RETURNING
        VALUE(rv_valid)  TYPE abap_bool.

    METHODS validate_status_and_priority
      IMPORTING
        i_status       TYPE string
        i_priority     TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS check_customer_exists
      IMPORTING i_customer_id   TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_technician_exists
      IMPORTING i_technician_id TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_order_exists
      IMPORTING i_work_order_id TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_order_history
      IMPORTING i_work_order_id TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.
ENDCLASS.



CLASS zcl_work_order_crud_validator IMPLEMENTATION.
  METHOD check_customer_exists.

    SELECT SINGLE @abap_true
      FROM ztcustomer_jjrs
     WHERE customer_id = @i_customer_id
     INTO @rv_exists.
    IF sy-subrc <> 0.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD check_order_exists.

  ENDMETHOD.

  METHOD check_order_history.

  ENDMETHOD.

  METHOD check_technician_exists.

  ENDMETHOD.

  METHOD validate_create_order.

  if check_customer_exists( i_customer_id ) = abap_false.
  return.
  ENDIF.

  ENDMETHOD.

  METHOD validate_delete_order.

  ENDMETHOD.

  METHOD validate_status_and_priority.

  ENDMETHOD.

  METHOD validate_update_order.

  ENDMETHOD.

ENDCLASS.

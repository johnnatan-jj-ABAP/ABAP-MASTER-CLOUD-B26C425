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
        VALUE(rv_valid) TYPE abap_bool.

    METHODS validate_update_order
      IMPORTING
        i_work_order_id TYPE string
        i_status        TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS validate_delete_order
      IMPORTING
        i_work_order_id TYPE string
        i_status        TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS validate_status_and_priority
      IMPORTING
        i_status        TYPE string
        i_priority      TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS check_customer_exists
      IMPORTING i_customer_id    TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_technician_exists
      IMPORTING i_technician_id  TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_order_exists
      IMPORTING i_work_order_id  TYPE string
      RETURNING VALUE(rv_exists) TYPE abap_bool.

    METHODS check_order_history
      IMPORTING i_work_order_id  TYPE string
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

   SELECT SINGLE @abap_true
     FROM ztwork_order
    WHERE work_order_id = @i_work_order_id
     INTO @rv_exists.

    IF sy-subrc <> 0.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD check_order_history.

 SELECT SINGLE @abap_true
   FROM ztworkorder_hist
  WHERE work_order_id = @i_work_order_id
   INTO @rv_exists.

    IF sy-subrc <> 0.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD check_technician_exists.

  SELECT SINGLE @abap_true
    FROM zttechnician
   WHERE technician_id = @i_technician_id
    INTO @rv_exists.

    IF sy-subrc <> 0.
      rv_exists = abap_false.
    ENDIF.

  ENDMETHOD.

  METHOD validate_create_order.

    rv_valid = abap_false.

    IF check_customer_exists( i_customer_id ) = abap_false.
       rv_valid = abap_false.
    ENDIF.

     IF check_technician_exists( i_technician_id ) = abap_false.
      rv_valid = abap_false.
    ENDIF.

    " 3. Verificar si la prioridad es válida ('A' o 'B')
    IF i_priority <> 'A' AND i_priority <> 'B'.
      rv_valid = abap_false.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_delete_order.

   rv_valid = abap_false.

    IF check_order_exists( i_work_order_id ) = abap_false.
      RETURN.
    ENDIF.

    IF i_status <> 'PE'.
      RETURN.
    ENDIF.

    IF check_order_history( i_work_order_id ) = abap_true.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

  METHOD validate_status_and_priority.

  rv_valid = abap_false.

    IF ( i_status = 'PE' OR i_status = 'CO' ) AND ( i_priority = 'A' OR i_priority = 'B' ).
      rv_valid = abap_true.
    ENDIF.

  ENDMETHOD.

  METHOD validate_update_order.

   rv_valid = abap_false.


    IF check_order_exists( i_work_order_id ) = abap_false.
      RETURN.
    ENDIF.


    IF i_status <> 'PE' AND i_status <> 'CO'.
      RETURN.
    ENDIF.

    SELECT SINGLE history_id
      FROM ztworkorder_hist
      WHERE work_order_id = @i_work_order_id
      INTO @DATA(lv_exists_hist).

    IF sy-subrc = 0.
      RETURN.
    ENDIF.

    rv_valid = abap_true.

  ENDMETHOD.

ENDCLASS.

CLASS zcl_work_order_crud_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    TYPES ty_work_order TYPE ztwork_order.

    METHODS constructor.

    METHODS create_work_order
      IMPORTING
        i_work_order TYPE ty_work_order
      EXPORTING
        e_success    TYPE abap_boolean
        e_message    TYPE string.

    METHODS read_work_order
      IMPORTING
        i_order_id   TYPE ty_work_order-work_order_id
      EXPORTING
        e_work_order TYPE ty_work_order
        e_success    TYPE abap_boolean
        e_message    TYPE string.

    METHODS update_work_order
      IMPORTING
        i_work_order TYPE ty_work_order
      EXPORTING
        e_success    TYPE abap_boolean
        e_message    TYPE string.

    METHODS delete_work_order
      IMPORTING
        i_order_id TYPE ty_work_order-work_order_id
        i_status   TYPE string
      EXPORTING
        e_success  TYPE abap_boolean
        e_message  TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA mo_validator TYPE REF TO zcl_work_order_crud_validator.
ENDCLASS.



CLASS zcl_work_order_crud_handler IMPLEMENTATION.
  METHOD create_work_order.

    e_success = abap_false.

    " Integración de validaciones antes de insertar
    DATA(lv_is_valid) = mo_validator->validate_create_order(
      i_customer_id   = CONV string( i_work_order-customer_id  )
      i_technician_id = CONV string( i_work_order-technician_id )
      i_priority      = CONV string( i_work_order-priority )
    ).

    IF lv_is_valid = abap_false.
      e_message = 'Validación denegada: Cliente/Técnico inválido o prioridad incorrecta.'.
      RETURN.
    ENDIF.

    INSERT ztwork_order FROM @i_work_order.
    IF sy-subrc = 0.
      e_success = abap_true.
      e_message = 'Orden insertada.'.
    ELSE.
      e_message = 'Error'.
    ENDIF.

  ENDMETHOD.

  METHOD delete_work_order.

    e_success = abap_false.

    " Integración de validaciones antes de eliminar
    DATA(lv_is_valid) = mo_validator->validate_delete_order(
      i_work_order_id = CONV string( i_order_id )
      i_status        = i_status
    ).

    IF lv_is_valid = abap_false.
      e_message = 'Validación denegada: No cumple requisitos para borrado'.
      RETURN.
    ENDIF.

    DELETE FROM ztwork_order WHERE work_order_id = @i_order_id.
    IF sy-subrc = 0.
      e_success = abap_true.
      e_message = 'Orden de trabajo eliminada de la base de datos.'.
    ELSE.
      e_message = 'Error al intentar suprimir el registro.'.
    ENDIF.

  ENDMETHOD.

  METHOD read_work_order.

    CLEAR: e_work_order, e_success, e_message.

    SELECT SINGLE *
      FROM ztwork_order
      WHERE work_order_id = @i_order_id
      INTO @e_work_order.

    IF sy-subrc = 0.
      e_success = abap_true.
      e_message = 'leído con éxito.'.
    ELSE.
      e_success = abap_false.
      e_message = 'La orden no existe.'.
    ENDIF.

  ENDMETHOD.

  METHOD update_work_order.

    e_success = abap_false.

    "validaciones antes de actualizar

    DATA(lv_is_valid) = mo_validator->validate_update_order(
      i_work_order_id = CONV string( i_work_order-work_order_id )
      i_status        = CONV string( i_work_order-status )
    ).

    IF lv_is_valid = abap_false.
      e_message = 'Validación denegada'.
      RETURN.
    ENDIF.

    " Respaldamos el estado actual de la orden antes de modificarla
    SELECT SINGLE *
      FROM ztwork_order
      WHERE work_order_id = @i_work_order-work_order_id
      INTO @DATA(ls_current_order).

    IF sy-subrc = 0.
      " Obtenemos de forma secuencial el siguiente ID para el historial
      DATA lv_next_hist_id TYPE ztworkorder_hist-history_id.

      SELECT MAX( history_id )
        FROM ztworkorder_hist
        INTO @lv_next_hist_id.

      lv_next_hist_id = lv_next_hist_id + 1.

      "" OBTENER LA FECHA ACTUAL
      TRY.
          DATA(lv_current_date) = cl_abap_context_info=>get_system_date( ).
        CATCH cx_abap_context_info_error.

      ENDTRY.

      " 3. Preparamos el registro del historial con los datos de la orden que se va a cambiar
      DATA(ls_history) = VALUE ztworkorder_hist(
        history_id         = lv_next_hist_id
        work_order_id      = ls_current_order-work_order_id
        modification_date  = lv_current_date
        change_description = |Modificación de estado: { ls_current_order-status } -> { i_work_order-status }|
      ).
    ENDIF.

    UPDATE ztwork_order FROM @i_work_order.
    IF sy-subrc = 0.
      e_success = abap_true.
      e_message = 'Orden de trabajo modificada correctamente.'.

      IF ls_history IS NOT INITIAL.
        INSERT ztworkorder_hist FROM @ls_history.
      ENDIF.
    ELSE.
      e_message = 'Error técnico al intentar actualizar el registro.'.
    ENDIF.

  ENDMETHOD.

  METHOD constructor.

    mo_validator = NEW zcl_work_order_crud_validator( ).

  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

    DATA ls_order TYPE ty_work_order.


    " Crear:

*    ls_order-work_order_id = '0000000006'.
*    ls_order-customer_id   = '00000002'.
*    ls_order-technician_id = 'TECH0001'.
*    ls_order-priority      = 'B'.
*    ls_order-status        = 'PE'.
*
*    me->create_work_order(
*       EXPORTING i_work_order = ls_order
*       IMPORTING e_success    = DATA(lv_ok_c)
*                 e_message    = DATA(lv_msg_c)
*     ).
*
*    out->write( |[Create] Éxito: { lv_ok_c } - Mensaje: { lv_msg_c }| ).


*    "Lectura:

*    me->read_work_order(
*      EXPORTING i_order_id   = '0000000001'
*      IMPORTING e_work_order = DATA(ls_read_res)
*                e_success    = DATA(lv_ok_r)
*                e_message    = DATA(lv_msg_r)
*    ).
*    out->write( |READ] Éxito: { lv_ok_r } - Mensaje: { lv_msg_r }| ).

*
*    "Actualización
*
    ls_order-work_order_id = '0000000001'.
    ls_order-status = 'CO'.
    me->update_work_order(
      EXPORTING i_work_order = ls_order
      IMPORTING e_success    = DATA(lv_ok_u)
                e_message    = DATA(lv_msg_u)
    ).
    out->write( |[UPDATE] Éxito: { lv_ok_u } - Mensaje: { lv_msg_u }| ).
*
*    "Eliminar
*

*    me->delete_work_order(
*      EXPORTING i_order_id = '0000000005'
*                i_status   = 'PE'
*      IMPORTING e_success    = DATA(lv_ok_d)
*                e_message    = DATA(lv_msg_d)
*    ).
*    out->write( |[DELETE] Éxito: { lv_ok_d } - Mensaje: { lv_msg_d }| ).
*
*    out->write( ' FIN DE LA EJECUCIÓN ' ).
  ENDMETHOD.

ENDCLASS.

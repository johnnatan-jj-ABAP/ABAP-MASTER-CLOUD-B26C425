CLASS zcl_fill_tables_jjrs DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

   INTERFACES if_oo_adt_classrun .

  CLASS-METHODS insert_customer
      IMPORTING
        is_customer     TYPE ztcustomer_jjrs
      RETURNING
        VALUE(rv_subrc) TYPE sysubrc.

    CLASS-METHODS insert_technician
      IMPORTING
        is_technician   TYPE zttechnician
      RETURNING
        VALUE(rv_subrc) TYPE sysubrc.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fill_tables_jjrs IMPLEMENTATION.

 METHOD if_oo_adt_classrun~main.


    out->write( '--- Iniciando proceso de inserción de datos ---' ).

    DATA(ls_cliente) = VALUE ztcustomer_jjrs(
      customer_id = '00000002'
      name        = 'Jose juan'
      address     = 'Av. Principal 1234'
      phone       = '555987654'
    ).

    IF me->insert_customer( ls_cliente ) = 0.
      out->write( 'Éxito: Registro guardado en la tabla' ).
    ELSE.
      out->write( 'Error: falló la inserción.' ).
    ENDIF.


    DATA(ls_tecnico) = VALUE zttechnician(
      technician_id = 'TECH0002'
      name          = 'Ing. Jorge Ramirez 2'
      specialty     = 'ventas'
    ).

    IF me->insert_technician( ls_tecnico ) = 0.
      out->write( 'Éxito: Registro guardado en la tabla zttechician.' ).
    ELSE.
      out->write( 'Error: El registro de técnico ya existe o falló la inserción.' ).
    ENDIF.

    out->write( '--- Proceso finalizado ---' ).
  ENDMETHOD.


  METHOD insert_customer.
    INSERT ztcustomer_jjrs FROM @is_customer. " Uso de @ para ABAP moderno (expresión de host)
    rv_subrc = sy-subrc.
  ENDMETHOD.


  METHOD insert_technician.
    INSERT zttechnician FROM @is_technician.
    rv_subrc = sy-subrc.
  ENDMETHOD.
ENDCLASS.

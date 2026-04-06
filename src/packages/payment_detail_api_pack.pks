create or replace package payment_detail_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
  */
  
  -- Сообщения ошибок
  c_error_msg_empty_field_id constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id constant varchar2(100 char) := 'ID объекта не может быть пустым';
  
  -- Коды ощибок
  c_error_invalid_input_prmtr constant number(10) := -20102;
  
  -- Объекты исключений
  c_invalid_input_parameter exception;
  pragma exception_init(c_invalid_input_parameter, -20102);
  
  

  --Добавление/обновление данных платежа
  procedure insrt_or_upd_payment_detail(p_payment_id     in payment.payment_id%type,
                                        p_payment_detail in t_payment_detail_array);

  procedure delete_payment_detail(p_payment_id            in payment.payment_id%type,
                                  p_delete_payment_detail in t_number_array);

end payment_detail_api_pack;
/
create or replace package payment_detail_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
  */

  -- Сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_manual_changes    constant varchar2(100 char) := 'Изменения должны выполняться только через API';
  
  -- Коды ощибок
  c_error_code_input_parameter constant number(10) := -20101;
  c_error_code_manual_changes constant number(10) := -20103;

  -- Объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter,
                        c_error_code_input_parameter);
  
  e_invalid_manual_changes exception;
  pragma exception_init(e_invalid_manual_changes,
                        c_error_code_manual_changes);
                        

  --Добавление/обновление данных платежа
  procedure insert_or_update_payment_detail(p_payment_id     in payment.payment_id%type,
                                            p_payment_detail in t_payment_detail_array);

  procedure delete_payment_detail(p_payment_id            in payment.payment_id%type,
                                  p_delete_payment_detail in t_number_array);
                                  
  --Проверка, вызываемая из триггера
  procedure payment_detail_changes_through_api;

end payment_detail_api_pack;
/
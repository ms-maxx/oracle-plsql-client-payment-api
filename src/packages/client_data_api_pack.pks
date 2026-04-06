create or replace package client_data_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Клиент” и “Клиентские данные”
  */
  
  -- Сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_manual_changes    constant varchar2(100 char) := 'Изменения должны выполняться только через API';
  
  -- Коды ошибок
  c_error_code_invalid_input_parameter constant number(10) := -20101;
  c_error_code_invalid_manual_changes   constant number(10) := -20103;
  
  -- Объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter, c_error_code_invalid_input_parameter);
  
  e_invalid_manual_changes exception;
  pragma exception_init(e_invalid_manual_changes, c_error_code_invalid_manual_changes);
  
  
  
  --  Добавление/Изменение клиентских данных
  procedure insert_or_update_client_data(p_client_id   in client.client_id%type,
                                         p_client_data in t_client_data_array);
                                         
  --  Удаление данных клиента
  procedure delete_client_data(p_client_id        in client.client_id%type,
                               p_delete_field_ids in t_number_array);
  
  --Проверка, вызоваемая из триггера                             
  procedure client_data_changes_through_api;

end client_data_api_pack;
/
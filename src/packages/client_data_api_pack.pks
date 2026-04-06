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
  
  -- Коды ошибок
  c_error_invalid_input_prmtr constant number(10) := -20101;
  
  -- Объекты исключений
  e_invalid_input_parameter exception;
  pragma exception_init(e_invalid_input_parameter, -20101);
  
  
  
  --  Добавление/Изменение клиентских данных
  procedure insert_or_update_client_data(p_client_id   in client.client_id%type,
                                         p_client_data in t_client_data_array);
                                         
  --  Удаление данных клиента
  procedure delete_client_data(p_client_id        in client.client_id%type,
                               p_delete_field_ids in t_number_array);

end client_data_api_pack;
/

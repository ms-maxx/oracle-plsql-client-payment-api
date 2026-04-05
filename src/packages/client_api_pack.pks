create or replace package client_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Клиент” и “Клиентские данные”
  */

  -- Статусы активности клиента
  c_active   constant client.is_active%type := 1;
  c_inactive constant client.is_active%type := 0;
  -- Статусы блокировки клиента
  c_not_blocked constant client.is_blocked%type := 0;
  c_blocked     constant client.is_blocked%type := 1;

  -- Сообщения ошибок
  c_error_msg_empty_field_id    constant varchar2(100 char) := 'ID поля не может быть пустым';
  c_error_msg_empty_field_value constant varchar2(100 char) := 'Значение в поле не может быть пустым';
  c_error_msg_empty_collection  constant varchar2(100 char) := 'Коллекция не содержит данных';
  c_error_msg_empty_object_id   constant varchar2(100 char) := 'ID объекта не может быть пустым';
  c_error_msg_empty_reason      constant varchar2(100 char) := 'Причина не может быть пустой';
  
  --Создание клиента
  function create_client(p_client_data in t_client_data_array)
    return client.client_id%type;
  
  --Блокировка клиента
  procedure block_client(p_client_id in client.client_id%type,
                         p_reason    in client.blocked_reason%type);
                         
  --Разблокировка клиента
  procedure unblock_client(p_client_id in client.client_id%type);
  
  --Деактивация клиента
  procedure deactivate_client(p_client_id in client.client_id%type);

end client_api_pack;
/
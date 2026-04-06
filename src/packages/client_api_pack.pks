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

  
  -- API
  -- Создание клиента
  function create_client(p_client_data in t_client_data_array)
    return client.client_id%type;

  -- Блокировка клиента
  procedure block_client(p_client_id in client.client_id%type,
                         p_reason    in client.blocked_reason%type);

  -- Разблокировка клиента
  procedure unblock_client(p_client_id in client.client_id%type);

  -- Деактивация клиента
  procedure deactivate_client(p_client_id in client.client_id%type);
  
  -- Triggers
  
  -- Проверка, выполняются ли изменения через API
  procedure client_changes_through_api;
  
  -- Проверка на возможность удалять данные
  procedure check_client_delete_restriction;

end client_api_pack;
/
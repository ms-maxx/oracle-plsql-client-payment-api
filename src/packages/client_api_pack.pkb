create or replace package body client_api_pack is

  g_is_api boolean := false; -- принзак, выполняется ли изменение через API

  --Разрешение на изменение данных
  procedure allow_changes is
  begin
    g_is_api := true;
  end;

  --Запрет на изменение данных
  procedure disallow_changes is
  begin
    g_is_api := false;
  end;

  --Создание клиента
  function create_client(p_client_data in t_client_data_array)
    return client.client_id%type is
    v_client_id client.client_id%type;
  begin
  
    allow_changes();
  
    --Создание клиента
    insert into client
      (client_id, is_active, is_blocked, blocked_reason)
    values
      (client_seq.nextval, c_active, c_not_blocked, null)
    returning client_id into v_client_id;
  
    --Добавление клиентских данных
    client_data_api_pack.insert_or_update_client_data(p_client_id   => v_client_id,
                                                      p_client_data => p_client_data);
  
    disallow_changes();
  
    return v_client_id;
  
  exception
    when others then
      disallow_changes();
      raise;
  end create_client;

  --Блокировка клиента
  procedure block_client(p_client_id in client.client_id%type,
                         p_reason    in client.blocked_reason%type) is
  begin
  
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_reason);
    end if;
    
    try_lock_client(p_client_id => p_client_id); -- Пытаемся заблокировать клиента.
  
    allow_changes();
  
    --Обновление клиента
    update client c
       set c.is_blocked = c_blocked, c.blocked_reason = p_reason
     where c.client_id = p_client_id
       and c.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end block_client;

  --Разблокировка клиента
  procedure unblock_client(p_client_id in client.client_id%type) is
  begin
  
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
    
    try_lock_client(p_client_id => p_client_id); -- Пытаемся заблокировать клиента.
  
    allow_changes();
  
    --Обновление клиента
    update client c
       set c.is_blocked = c_not_blocked, c.blocked_reason = null
     where c.client_id = p_client_id
       and c.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end unblock_client;

  --Деактивация клиента
  procedure deactivate_client(p_client_id in client.client_id%type) is
  begin
  
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
    
    try_lock_client(p_client_id => p_client_id); -- Пытаемся заблокировать клиента.
  
    allow_changes();
  
    --Обновление клиента
    update client c
       set c.is_active = c_inactive
     where c.client_id = p_client_id
       and c.is_active = c_active;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end deactivate_client;

  -- Проверка вызова через API
  procedure client_changes_through_api is
  begin
    if not g_is_api and not common_pack.is_client_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_manual_changes,
                              common_pack.c_error_msg_manual_changes);
    end if;
  end client_changes_through_api;

  procedure check_client_delete_restriction is
  begin
    if not common_pack.is_client_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_delete_forbidden,
                              common_pack.c_error_msg_delete_forbidden);
    end if;
  end check_client_delete_restriction;
  
  -- Блокировка клиента для изменения
  procedure try_lock_client(p_client_id in client.client_id%type) is
    v_is_active client.is_active%type;
  begin
    
    select t.is_active
      into v_is_active
      from client t
     where t.client_id = p_client_id
       for update nowait;
  
    if v_is_active = c_inactive then
      raise_application_error(common_pack.c_error_code_inactive_object,
                              common_pack.c_error_msg_inactive_object);
    end if;
  
  exception
    when no_data_found then
      raise_application_error(common_pack.c_error_code_object_notfound,
                              common_pack.c_error_msg_object_notfound);
    when common_pack.e_row_locked then
      raise_application_error(common_pack.c_error_code_object_already_locked,
                              common_pack.c_error_msg_object_already_locked);
  end;

end client_api_pack;
/
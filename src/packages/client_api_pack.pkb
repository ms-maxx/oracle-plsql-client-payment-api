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
    v_message varchar2(200 char) := 'Клиент создан';
    v_current_dtime date := sysdate;
    v_client_id     client.client_id%type;
  begin
  
    if p_client_data is not empty then
    
      for i in p_client_data.first .. p_client_data.last loop
        if (p_client_data(i).field_id is null) then
          raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_id);
        end if;
      
        if (p_client_data(i).field_value is null) then
          raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_field_value);
        end if;
      
        dbms_output.put_line('Field_id: ' || p_client_data(i).field_id ||
                             '. Value: ' || p_client_data(i).field_value);
      end loop;
    else
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_collection);
    end if;
  
    dbms_output.put_line(v_message || '. Статус: ' || c_active ||
                         '. Блокировка: ' || c_not_blocked);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
    
    
    allow_changes();
    --Создание клиента
    insert into client
      (client_id, is_active, is_blocked, blocked_reason)
    values
      (client_seq.nextval, c_active, c_not_blocked, null)
    returning client_id into v_client_id;
  
    dbms_output.put_line('Client id of new client: ' || v_client_id);
  
    --Добавление клиентских данных
    client_data_api_pack.insert_or_update_client_data(p_client_id => v_client_id,
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
    v_message varchar2(200 char) := 'Клиент заблокирован';
    v_current_dtime timestamp := systimestamp;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
  
    if p_reason is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_reason);
    end if;
    
    allow_changes(); 
     
    dbms_output.put_line(v_message || '. Блокировка: ' || c_blocked ||
                         '. Причина: ' || p_reason || '. ID: ' ||
                         p_client_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));
  
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
    v_message varchar2(200 char) := 'Клиент разблокирован';
    v_current_dtime timestamp := systimestamp;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
    
    allow_changes();
  
    dbms_output.put_line(v_message || '. Блокировка: ' || c_not_blocked ||
                         '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));
  
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
    v_message varchar2(200 char) := 'Клиент деактивирован';
    v_current_dtime date := sysdate;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_code_invalid_input_parameter, c_error_msg_empty_object_id);
    end if;
    
    allow_changes();
  
    dbms_output.put_line(v_message || '. Статус активности: ' ||
                         c_inactive || '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
  
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
  procedure client_changes_through_api
  is
  begin
    if not g_is_api then
      raise_application_error(c_error_code_invalid_manual_changes,c_error_msg_manual_changes);
    end if;
  end client_changes_through_api;

end client_api_pack;
/
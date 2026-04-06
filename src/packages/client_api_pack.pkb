create or replace package body client_api_pack is

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
          raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_field_id);
        end if;
      
        if (p_client_data(i).field_value is null) then
          raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_field_value);
        end if;
      
        dbms_output.put_line('Field_id: ' || p_client_data(i).field_id ||
                             '. Value: ' || p_client_data(i).field_value);
      end loop;
    else
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_collection);
    end if;
  
    dbms_output.put_line(v_message || '. Статус: ' || c_active ||
                         '. Блокировка: ' || c_not_blocked);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
  
    --Создание клиента
    insert into client
      (client_id, is_active, is_blocked, blocked_reason)
    values
      (client_seq.nextval, c_active, c_not_blocked, null)
    returning client_id into v_client_id;
  
    dbms_output.put_line('Client id of new client: ' || v_client_id);
  
    --Добавление клиентских данных
    insert into client_data
      (client_id, field_id, field_value)
      Select v_client_id,value(t).field_id,value(t).field_value
        from table(p_client_data) t;
  
    return v_client_id;
  end create_client;

  --Блокировка клиента
  procedure block_client(p_client_id in client.client_id%type,
                         p_reason    in client.blocked_reason%type) is
    v_message varchar2(200 char) := 'Клиент заблокирован';
    v_current_dtime timestamp := systimestamp;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
  
    if p_reason is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_reason);
    end if;
  
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
  
  end block_client;

  --Разблокировка клиента
  procedure unblock_client(p_client_id in client.client_id%type) is
    v_message varchar2(200 char) := 'Клиент разблокирован';
    v_current_dtime timestamp := systimestamp;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
  
    dbms_output.put_line(v_message || '. Блокировка: ' || c_not_blocked ||
                         '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));
  
    --Обновление клиента
    update client c
       set c.is_blocked = c_not_blocked, c.blocked_reason = null
     where c.client_id = p_client_id
       and c.is_active = c_active;
  
  end unblock_client;

  --Деактивация клиента
  procedure deactivate_client(p_client_id in client.client_id%type) is
    v_message varchar2(200 char) := 'Клиент деактивирован';
    v_current_dtime date := sysdate;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
  
    dbms_output.put_line(v_message || '. Статус активности: ' ||
                         c_inactive || '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
  
    --Обновление клиента
    update client c
       set c.is_active = c_inactive
     where c.client_id = p_client_id
       and c.is_active = c_active;
  end deactivate_client;

end client_api_pack;
/
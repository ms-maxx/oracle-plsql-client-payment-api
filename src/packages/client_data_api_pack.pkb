create or replace package body client_data_api_pack is

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

  --Добавление/Изменение клиентских данных
  procedure insert_or_update_client_data(p_client_id   in client.client_id%type,
                                         p_client_data in t_client_data_array) is
  begin
  
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_client_data is not empty then
    
      for i in p_client_data.first .. p_client_data.last loop
        if (p_client_data(i).field_id is null) then
          raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                                  common_pack.c_error_msg_empty_field_id);
        end if;
      
        if (p_client_data(i).field_value is null) then
          raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                                  common_pack.c_error_msg_empty_field_value);
        end if;
      
      end loop;
    else
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_collection);
    end if;
    
    client_api_pack.try_lock_client(p_client_id => p_client_id); --Блокируем клиента.
  
    allow_changes();
  
    --вставка/обновление данных
    merge into client_data c
    using (Select p_client_id client_id,
                  value      (t).field_id       field_id,
                  value      (t).field_value       field_value
             from table(p_client_data) t) m
    on (c.client_id = m.client_id and c.field_id = m.field_id)
    when matched then
      update set c.field_value = m.field_value
    when not matched then
      insert
        (client_id, field_id, field_value)
      values
        (m.client_id, m.field_id, m.field_value);
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end insert_or_update_client_data;

  --Удаление клиентских данных
  procedure delete_client_data(p_client_id        in client.client_id%type,
                               p_delete_field_ids in t_number_array) is
  begin
  
    if p_client_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_delete_field_ids is empty then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_collection);
    end if;
    
    client_api_pack.try_lock_client(p_client_id => p_client_id); --Блокируем клиента.
  
    allow_changes();
  
    --Удаление данных клиента
    delete from client_data c
     where c.client_id = p_client_id
       and c.field_id in (select value(t) from table(p_delete_field_ids) t);
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end delete_client_data;

  -- Проверка вызова через API
  procedure client_data_changes_through_api is
  begin
    if not g_is_api and not common_pack.is_client_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_manual_changes,
                              common_pack.c_error_msg_manual_changes);
    end if;
  end client_data_changes_through_api;

end client_data_api_pack;
/
--Заготовка под Unit-tests for client

--Проверка "создания клиента"
declare
  v_client_data t_client_data_array := t_client_data_array(t_client_data(1, 'somepost1@mail'),
                                                           t_client_data(2, '+3809677722211'),
                                                           t_client_data(3, '0901200888'));
  v_client_id   client.client_id%type;
  v_create_dtime_tech client.create_dtime_tech%type;
  v_update_dtime_tech client.update_dtime_tech%type;
begin
  v_client_id := client_api_pack.create_client(p_client_data => v_client_data);
  dbms_output.put_line('Client_id: ' || v_client_id);
  
  select t.create_dtime_tech, t.update_dtime_tech
    into v_create_dtime_tech, v_update_dtime_tech
    from client t
   where t.client_id = v_client_id;
   
  if (v_create_dtime_tech != v_update_dtime_tech) then 
    raise_application_error(-20998, 'Технические даты разные!');
  end if;
end;
/

--Проверка "Блокировка клиента"
declare
  v_client_id client.client_id%type := 21;
  v_reason    client.blocked_reason%type := 'some reason block';
  v_create_dtime_tech client.create_dtime_tech%type;
  v_update_dtime_tech client.update_dtime_tech%type;
begin
  client_api_pack.block_client(p_client_id => v_client_id,
                               p_reason    => v_reason);
  
  select t.create_dtime_tech, t.update_dtime_tech
    into v_create_dtime_tech, v_update_dtime_tech
    from client t
   where t.client_id = v_client_id;
   
  if (v_create_dtime_tech = v_update_dtime_tech) then 
    raise_application_error(-20998, 'Технические даты равны!');
  end if;
end;
/

--Проверка "Разблокировка клиента"
declare
  v_client_id client.client_id%type := 21;
begin
  client_api_pack.unblock_client(p_client_id => v_client_id);
end;
/

--Проверка "Деактивация клиента"
declare
  v_client_id client.client_id%type := 21;
begin
  client_api_pack.deactivate_client(p_client_id => v_client_id);
end;
/

--Проверка "Добавление/Изменение клиентских данных"
declare
  v_client_id   client.client_id%type := 21;
  v_client_data t_client_data_array := t_client_data_array(t_client_data(2, '+38098222900'),
                                                           t_client_data(4, '23.03.2026'));
begin
  client_data_api_pack.insert_or_update_client_data(p_client_id   => v_client_id,
                                                    p_client_data => v_client_data);
end;
/

--Проверка "Удаление клиентских данных"
declare
  v_client_id        client.client_id%type := 21;
  v_delete_field_ids t_number_array := t_number_array(2, 3);
begin
  client_data_api_pack.delete_client_data(p_client_id        => v_client_id,
                                          p_delete_field_ids => v_delete_field_ids);
end;
/

--Проверка функционала по глобальному отключению проверок. Операция удаления клиента
declare
  v_client_id client.client_id%type := -1;
begin
  common_pack.enable_client_manual_changes();
  delete from client c where c.client_id = v_client_id;
  common_pack.disable_client_manual_changes();
exception
  when others then
    common_pack.disable_client_manual_changes();
    raise;
end;
/

--Проверка функционала по глобальному отключению проверок. Операция обновления клиента
declare
  v_client_id client.client_id%type := 21;
begin
  common_pack.enable_client_manual_changes();

  update client c
     set c.is_blocked = c.is_blocked
   where c.client_id = v_client_id;

  common_pack.disable_client_manual_changes();
exception
  when others then
    common_pack.disable_client_manual_changes();
    raise;
end;
/

--Проверка функционала по глобальному отключению проверок. Операция обновления данных клиента
declare
  v_client_id client.client_id%type := 21;
  v_field_id client_data.field_id%type := 1;
begin
  common_pack.enable_client_manual_changes();

  update client_data c
     set c.field_value = c.field_value
   where c.client_id = v_client_id
   and c.field_id = v_field_id;

  common_pack.disable_client_manual_changes();
exception
  when others then
    common_pack.disable_client_manual_changes();
    raise;
end;
/  
  
/*============================*/

-- Негативные Unit-tests

--Проверка "создания клиента"
declare
  v_client_data t_client_data_array;
  v_client_id   client.client_id%type;
begin
  v_client_id := client_api_pack.create_client(p_client_data => v_client_data);
  
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
 when common_pack.e_invalid_input_parameter then 
    dbms_output.put_line('Cоздания клиента. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/
 
--Проверка "Блокировка клиента"
declare
  v_client_id client.client_id%type := 2;
  v_reason    client.blocked_reason%type;
begin
  client_api_pack.block_client(p_client_id => v_client_id,
                               p_reason    => v_reason);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
    dbms_output.put_line('Блокировка клиента. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

--Проверка "Разблокировка клиента"
declare
  v_client_id client.client_id%type;
begin
  client_api_pack.unblock_client(p_client_id => v_client_id);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
     dbms_output.put_line('Разблокировка клиента. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

--Проверка "Деактивация клиента"
declare
  v_client_id client.client_id%type := null;
begin
  client_api_pack.deactivate_client(p_client_id => v_client_id);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
     dbms_output.put_line('Деактивация клиента. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/ 

--Проверка "Добавление/Изменение клиентских данных"
declare
  v_client_id   client.client_id%type := 30;
  v_client_data t_client_data_array := t_client_data_array(t_client_data(null, '+38098222900'),
                                                           t_client_data(4, '23.03.2026'));
begin
  client_data_api_pack.insert_or_update_client_data(p_client_id   => v_client_id,
                                                    p_client_data => v_client_data);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
     dbms_output.put_line('Добавление/Изменение клиентских данных. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

--Проверка "Удаление клиентских данных"
declare
  v_client_id        client.client_id%type;
  v_delete_field_ids t_number_array := t_number_array(2, 3);
begin
  client_data_api_pack.delete_client_data(p_client_id        => v_client_id,
                                          p_delete_field_ids => v_delete_field_ids);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
     dbms_output.put_line('Удаление клиентских данных. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

-- Негативные тесты (triggers) client and client_data

--Проверка запрета удаления клиента через delete
declare
  v_client_id        client.client_id%type := 41;
begin
  delete from client t where t.client_id = v_client_id;
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_delete_forbidden then 
     dbms_output.put_line('Удаление клиента. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

--Проверка запрета вставки в client не через API
declare
  v_client_id        client.client_id%type := 41;
begin
  insert into client (client_id,
                      is_active,
                      is_blocked,
                      blocked_reason)
  values (v_client_id, client_api_pack.c_active, client_api_pack.c_not_blocked, null);
  
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_manual_changes then 
     dbms_output.put_line('Вставка в таблицу client не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

--Проверка запрета обновления в client не через API
declare
  v_client_id client.client_id%type := 41;
begin
  update client c
     set c.is_blocked = client_api_pack.c_not_blocked
   where c.client_id = v_client_id;

  raise_application_error(-20999,
                          'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы client не через API. Исключение возбуждено успешно. Ошибка: ' ||
                         sqlerrm);
end;
/

-- Изменение не через API (добавление) - клиентских данных
declare
  v_client_id   client.client_id%type := 30;
begin
  
  insert into client_data (client_id, field_id, field_value)
  values (v_client_id, 1, '+++');
  
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_manual_changes then 
     dbms_output.put_line('Вставка в таблицу client_data не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

-- Изменение не через API (обновление) - клиентских данных
declare
  v_client_id   client.client_id%type := 30;
begin
  
  update client_data c 
  set c.field_value = c.field_value
  where c.client_id = v_client_id;
  
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_manual_changes then 
     dbms_output.put_line('Обновление таблицы client_data не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/

-- Удаление не через API - клиентских данных
declare
  v_client_id        client.client_id%type := 22;
begin
  delete client_data c
  where c.client_id = v_client_id;  
                                          
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_manual_changes then 
     dbms_output.put_line('Удаление из таблицы client_data не через API. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/    

-- Негативный тест на отсутствие клиента
declare
  v_client_id client.client_id%type := -1;
  v_reason client.blocked_reason%type := 'test block';
begin
  client_api_pack.block_client(p_client_id => v_client_id,
                               p_reason => v_reason);
                               
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_object_notfound then
    dbms_output.put_line('Объект не найден. Исключение возбуждено успешно. Ошибка: ' ||
                         sqlerrm);
end;
/

-- Негативный тест на работу с неактивным клиентом
declare
  v_client_id client.client_id%type := 23;
  v_reason client.blocked_reason%type := 'test block';
begin
  client_api_pack.block_client(p_client_id => v_client_id,
                               p_reason => v_reason);
                               
                               
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_inactive_object then
    dbms_output.put_line('Объект в конечном статусе. Исключение возбуждено успешно. Ошибка: ' ||
                         sqlerrm);
end;
/

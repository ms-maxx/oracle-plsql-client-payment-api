--Заготовка под Unit-tests for client

--Проверка "создания клиента"
declare
  v_client_data t_client_data_array := t_client_data_array(t_client_data(1, 'somepost1@mail'),
                                                           t_client_data(2, '+3809677722211'),
                                                           t_client_data(3, '0901200888'));
  v_client_id   client.client_id%type;
begin
  v_client_id := client_api_pack.create_client(p_client_data => v_client_data);

  dbms_output.put_line('Client_id: ' || v_client_id);
end;
/

--Проверка "Блокировка клиента"
declare
  v_client_id client.client_id%type := 2;
  v_reason    client.blocked_reason%type := 'some reason block';
begin
  client_api_pack.block_client(p_client_id => v_client_id,
                               p_reason    => v_reason);
end;
/

--Проверка "Разблокировка клиента"
declare
  v_client_id client.client_id%type := 2;
begin
  client_api_pack.unblock_client(p_client_id => v_client_id);
end;
/

--Проверка "Деактивация клиента"
declare
  v_client_id client.client_id%type := 2;
begin
  client_api_pack.deactivate_client(p_client_id => v_client_id);
end;
/

--Проверка "Добавление/Изменение клиентских данных"
declare
  v_client_id   client.client_id%type := 2;
  v_client_data t_client_data_array := t_client_data_array(t_client_data(2, '+38098222900'),
                                                           t_client_data(4, '23.03.2026'));
begin
  client_data_api_pack.insert_or_update_client_data(p_client_id   => v_client_id,
                                                    p_client_data => v_client_data);
end;
/

--Проверка "Удаление клиентских данных"
declare
  v_client_id        client.client_id%type := 2;
  v_delete_field_ids t_number_array := t_number_array(2, 3);
begin
  client_data_api_pack.delete_client_data(p_client_id        => v_client_id,
                                          p_delete_field_ids => v_delete_field_ids);
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
 when client_api_pack.e_invalid_input_parameter then 
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
  when client_api_pack.e_invalid_input_parameter then 
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
  when client_api_pack.e_invalid_input_parameter then 
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
  when client_api_pack.e_invalid_input_parameter then 
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
  when client_data_api_pack.e_invalid_input_parameter then 
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
  when client_data_api_pack.e_invalid_input_parameter then 
     dbms_output.put_line('Удаление клиентских данных. Исключение возбуждено успешно. Ошибка: '|| sqlerrm);
end;
/ 
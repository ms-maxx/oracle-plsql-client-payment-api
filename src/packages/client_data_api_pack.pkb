create or replace package body client_data_api_pack is

  --Добавление/Изменение клиентских данных
  procedure insert_or_update_client_data(p_client_id   in client.client_id%type,
                                         p_client_data in t_client_data_array) is
    v_message       varchar2(200 char) := 'Клиентские данные вставлены или обновлены по списку id_поля/значение'; 
    v_current_dtime date := sysdate;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
  
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
  
    dbms_output.put_line(v_message || '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
  
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
  
  end insert_or_update_client_data;

  --Удаление клиентских данных
  procedure delete_client_data(p_client_id        in client.client_id%type,
                               p_delete_field_ids in t_number_array) is
    v_message       varchar2(200 char) := 'Клиентские данные удалены по списку id_полей';
    v_current_dtime timestamp := systimestamp;
  begin
  
    if p_client_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
  
    if p_delete_field_ids is empty then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_collection);
    end if;
  
    dbms_output.put_line(v_message || '. ID: ' || p_client_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));
    dbms_output.put_line('Количество удаляемых полей: ' ||
                         p_delete_field_ids.count());
  
    --Удаление данных клиента
    delete from client_data c
     where c.client_id = p_client_id
       and c.field_id in (select value(t) from table(p_delete_field_ids) t);
  end delete_client_data;

end client_data_api_pack;
/
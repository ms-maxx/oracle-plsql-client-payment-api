create or replace package body payment_detail_api_pack is

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

  --Добавление/обновление данных платежа
  procedure insert_or_update_payment_detail(p_payment_id     in payment.payment_id%type,
                                            p_payment_detail in t_payment_detail_array) is
    v_massage       varchar2(150) := 'Данные платежа добавлены или обновлены по списку id_поля/значение';
    v_current_dtime date := sysdate;
  Begin
  
    if p_payment_id is null then
      raise_application_error(c_error_code_input_parameter,
                              c_error_msg_empty_object_id);
    end if;
  
    if p_payment_detail is not empty then
      for i in p_payment_detail.first .. p_payment_detail.last loop
      
        if (p_payment_detail(i).field_id is null) then
          raise_application_error(c_error_code_input_parameter,
                                  c_error_msg_empty_field_id);
        end if;
      
        if (p_payment_detail(i).field_value is null) then
          raise_application_error(c_error_code_input_parameter,
                                  c_error_msg_empty_field_value);
        end if;
      
        dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id ||
                             '. Value: ' || p_payment_detail(i).field_value);
      end loop;
    else
      raise_application_error(c_error_code_input_parameter,
                              c_error_msg_empty_collection);
    end if;
  
    allow_changes();
  
    dbms_output.put_line(v_massage || '. ID: ' || p_payment_id);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));
  
    --вставка/обновление данных платежа
    merge into payment_detail pd
    using (select p_payment_id payment_id,
                  value       (t).field_id        field_id,
                  value       (t).field_value        field_value
             from table(p_payment_detail) t) n
    on (pd.payment_id = n.payment_id and pd.field_id = n.field_id)
    when matched then
      update set pd.field_value = n.field_value
    when not matched then
      insert
        (payment_id, field_id, field_value)
      values
        (n.payment_id, n.field_id, n.field_value);
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end insert_or_update_payment_detail;

  --Удаление платежа
  procedure delete_payment_detail(p_payment_id            in payment.payment_id%type,
                                  p_delete_payment_detail in t_number_array) is
    v_massage       varchar2(100) := 'Детали платежа удалены по списку id_полей';
    v_current_dtime timestamp := systimestamp;
  Begin
  
    if p_payment_id is null then
      raise_application_error(c_error_code_input_parameter,
                              c_error_msg_empty_object_id);
    end if;
  
    if p_delete_payment_detail is empty then
      raise_application_error(c_error_code_input_parameter,
                              c_error_msg_empty_collection);
    end if;
  
    allow_changes();
  
    dbms_output.put_line(v_massage || '. ID: ' || p_payment_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));
    dbms_output.put_line('Количество удаляемых полей: ' ||
                         p_delete_payment_detail.count());
  
    --Удаление данных платежа
    delete from payment_detail pd
     where pd.payment_id = p_payment_id
       and pd.field_id in
           (select value(t) from table(p_delete_payment_detail) t);
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end delete_payment_detail;
  
  --Проверка, вызываемая из триггера
  procedure payment_detail_changes_through_api 
  is
  begin
    if not g_is_api then 
      raise_application_error(c_error_code_manual_changes, c_error_msg_manual_changes);
    end if;
  end;

end payment_detail_api_pack;
/
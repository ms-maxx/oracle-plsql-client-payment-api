-- Заготовка под Unit-tests for Payment
 
-- Проверка "Cоздания платежа"
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'iphone 14 pro'),
                                                                    t_payment_detail(2, '192.168.0.111'),
                                                                    t_payment_detail(3, 'test transaction'));
  v_summa          payment.summa%type := 1900;
  v_from_client_id payment.from_client_id%type := 21;
  v_to_client_id   payment.to_client_id%type := 22;
  v_currency_id    currency.currency_id%type := 840;
  v_payment_id     payment.payment_id%type;

  v_create_drtime_tech payment.create_dtime_tech%type;
  v_update_dtime_tech  payment.update_dtime_tech%type;
begin
  v_payment_id := payment_api_pack.create_payment(p_payment_detail => v_payment_detail,
                                                  p_summa          => v_summa,
                                                  p_from_client_id => v_from_client_id,
                                                  p_to_client_id   => v_to_client_id,
                                                  p_currency_id    => v_currency_id);
  dbms_output.put_line('Payment_id: ' || v_payment_id);

  select t.create_dtime_tech, t.update_dtime_tech
    into v_create_drtime_tech, v_update_dtime_tech
    from payment t
   where t.payment_id = v_payment_id;

  if (v_create_drtime_tech != v_update_dtime_tech) then
    raise_application_error(-20998, 'Технические даты разные!');
  end if;
end;
/

-- Проверка "Сброс платежа"
declare
  v_payment_id payment.payment_id%type := 45;
  v_reason     payment.status_change_reason%type := 'test reset payment';
  
  v_create_drtime_tech payment.create_dtime_tech%type;
  v_update_dtime_tech payment.update_dtime_tech%type;
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id,
                                p_reason     => v_reason);
                                
  select t.create_dtime_tech, t.update_dtime_tech
    into v_create_drtime_tech, v_update_dtime_tech
    from payment t
   where t.payment_id = v_payment_id;

  if (v_create_drtime_tech = v_update_dtime_tech) then
    raise_application_error(-20998, 'Технические даты равны!');
  end if;
end;
/

-- Проверка "Отмена платежа"
declare
  v_payment_id payment.payment_id%type := 2;
  v_reason     payment.status_change_reason%type := 'test cancel payment';
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id,
                                  p_reason     => v_reason);
end;
/

-- Проверка "Завершение платежа (успешно)"
declare
  v_payment_id payment.payment_id%type := 2;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
end;
/

-- Проверка "Добавление/обновление данных платежа"
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'nokia 2310'),
                                                                    t_payment_detail(2, '192.120.1.888'),
                                                                    t_payment_detail(4, 'NO!'));
  v_payment_id     payment.payment_id%type := 2;
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id,
                                                      p_payment_detail => v_payment_detail);
end;
/

-- Проверка "Удаление платежа"
declare
  v_payment_id            payment.payment_id%type := 2;
  v_delete_payment_detail t_number_array := t_number_array(2, 4);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id            => v_payment_id,
                                                p_delete_payment_detail => v_delete_payment_detail);
end;
/

--Проверка функционала по глобальному отключению проверок. Операция удаления платежа
declare
  v_payment_id payment.payment_id%type := -1;
begin
  common_pack.enable_payment_manual_changes;
  delete from payment t where t.payment_id = v_payment_id;
  common_pack.disable_payment_manual_changes;
exception
  when others then
    common_pack.disable_payment_manual_changes();
    raise;
end;
/

--Проверка функционала по глобальному отключению проверок. Операция обновления платежа
declare
  v_payment_id payment.payment_id%type := -1;
begin
  common_pack.enable_payment_manual_changes;
  update payment p
     set p.status = p.status
   where p.payment_id = v_payment_id;
  common_pack.disable_payment_manual_changes;
exception
  when others then
    common_pack.disable_payment_manual_changes();
    raise;
end;
/

--Проверка функционала по глобальному отключению проверок. Операция обновления данных платежа
declare
  v_payment_id payment.payment_id%type := -1;
  v_field_id   payment_detail.field_id%type := 1;
begin
  common_pack.enable_payment_manual_changes;
  update payment_detail p
     set p.field_value = p.field_value
   where p.payment_id = v_payment_id
     and p.field_id = v_field_id;
  common_pack.disable_payment_manual_changes;
exception
  when others then
    common_pack.disable_payment_manual_changes();
    raise;
end;
/

/*============================*/

-- Негативные Unit-tests

-- Проверка "Cоздания платежа"
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'iphone 14 pro'),
                                                                    t_payment_detail(2, '192.168.0.111'),
                                                                    t_payment_detail(null, 'test transaction'));
  v_summa          payment.summa%type := 1900;
  v_from_client_id payment.from_client_id%type := 21;
  v_to_client_id   payment.to_client_id%type := 22;
  v_currency_id    currency.currency_id%type := 840;
  v_payment_id     payment.payment_id%type;
begin
  v_payment_id := payment_api_pack.create_payment(p_payment_detail => v_payment_detail,
                                                  p_summa          => v_summa,
                                                  p_from_client_id => v_from_client_id,
                                                  p_to_client_id   => v_to_client_id,
                                                  p_currency_id    => v_currency_id);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception 
  when common_pack.e_invalid_input_parameter then 
    dbms_output.put_line('Cоздания платежа. Исключение возбуждено успешно. Ошибка:'||sqlerrm); 
end;
/ 

-- Проверка "Сброс платежа"
declare
  v_payment_id payment.payment_id%type := 2;
  v_reason     payment.status_change_reason%type := null;
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id,
                                p_reason     => v_reason);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Сброс платежа. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/
 
-- Проверка "Отмена платежа"
declare
  v_payment_id payment.payment_id%type := 2;
  v_reason     payment.status_change_reason%type;
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id,
                                  p_reason     => v_reason);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Отмена платежа. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Проверка "Завершение платежа (успешно)"
declare
  v_payment_id payment.payment_id%type;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Завершение платежа (успешно). Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Проверка "Добавление/обновление данных платежа"
declare
  v_payment_detail t_payment_detail_array;
  v_payment_id     payment.payment_id%type := 2;
begin
  payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id,
                                                          p_payment_detail => v_payment_detail);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Добавление/обновление данных платежа. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/
 
-- Проверка "Удаление платежа"
declare
  v_payment_id            payment.payment_id%type := 2;
  v_delete_payment_detail t_number_array := t_number_array();
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id            => v_payment_id,
                                                p_delete_payment_detail => v_delete_payment_detail);
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_invalid_input_parameter then
    dbms_output.put_line('Удаление платежа. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Негативные тесты (triggers) payment and payment_data 

-- Проверка запрета удаления платежа через delete
declare
  v_payment_id payment.payment_id%type := -1;
begin
  delete from payment t where t.payment_id = v_payment_id;
  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_delete_forbidden then
    dbms_output.put_line('Удаление платежа. Исключение возбуждено успешно. Ошибка: ' ||
                         sqlerrm);
end;
/

-- Проверка запрета вставки в payment не через API
declare 
   v_payment_id        payment.payment_id%type := -1;
   v_summa          payment.summa%type := 1900;
   v_from_client_id payment.from_client_id%type := 1;
   v_to_client_id   payment.to_client_id%type := 2;
   v_currency_id    currency.currency_id%type := 840;
begin
  
  insert into payment (payment_id, summa, currency_id, from_client_id, to_client_id, status)
  values (v_payment_id, v_summa, v_currency_id, v_from_client_id, v_to_client_id, payment_api_pack.c_status_create); 

  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment не через API. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/ 

-- Проверка запрета обновления таб. payment не через API
declare
  v_payment_id payment.payment_id%type := 45;
begin

  update payment t
     set t.status = payment_api_pack.c_status_error
   where t.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment не через API. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Изменение не через API (добавление) - данных платежа
declare
  v_payment_id payment.payment_id%type := 45;
begin

  insert into payment_detail (payment_id, field_id, field_value)
  values (v_payment_id, 1, '+++');

  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Вставка в таблицу payment_detail не через API. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Изменение не через API (обновление) - данных платежа
declare
  v_payment_id payment.payment_id%type := 45;
begin

    update payment_detail t
     set t.field_value = t.field_value
   where t.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Обновление таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/

-- Удаление не через API - данных платежа
declare
  v_payment_id payment.payment_id%type := 45;
begin

   delete payment_detail t
   where t.payment_id = v_payment_id;

  raise_application_error(-20999, 'Unit-test или API выполнены неверно');
exception
  when common_pack.e_manual_changes then
    dbms_output.put_line('Удаление из таблицы payment_detail не через API. Исключение возбуждено успешно. Ошибка:' ||
                         sqlerrm);
end;
/ 

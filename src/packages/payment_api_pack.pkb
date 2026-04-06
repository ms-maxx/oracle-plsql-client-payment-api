create or replace package body payment_api_pack is

  g_is_api boolean := false; -- принзак, выполняется ли изменение через API

  -- Разрешение на изменение данных
  procedure allow_changes is
  begin
    g_is_api := true;
  end;

  -- Запрет на изменение данных
  procedure disallow_changes is
  begin
    g_is_api := false;
  end;

  -- Создание платежа
  function create_payment(p_payment_detail in t_payment_detail_array,
                          p_summa          in payment.summa%type,
                          p_from_client_id in payment.from_client_id%type,
                          p_to_client_id   in payment.to_client_id%type,
                          p_currency_id    in currency.currency_id%type,
                          p_current_dtime  in date := sysdate)
    return payment.payment_id%type is
    v_payment_id payment.payment_id%type;
  Begin
  
    allow_changes();
  
    -- Создание платежа
    insert into payment
      (payment_id,
       create_dtime,
       summa,
       currency_id,
       from_client_id,
       to_client_id)
    values
      (payment_seq.nextval,
       p_current_dtime,
       p_summa,
       p_currency_id,
       p_from_client_id,
       p_to_client_id)
    returning payment_id into v_payment_id;
  
    -- Добавление данных платежа
    payment_detail_api_pack.insert_or_update_payment_detail(p_payment_id     => v_payment_id,
                                                            p_payment_detail => p_payment_detail);
  
    disallow_changes();
  
    return v_payment_id;
  
  exception
    when others then
      disallow_changes();
      raise;
  end create_payment;

  -- Сброс платежа
  procedure fail_payment(p_payment_id in payment.payment_id%type,
                         p_reason     in payment.status_change_reason%type) is
  Begin
  
    if p_payment_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_reason);
    end if;
    
    try_lock_payment(p_payment_id => p_payment_id);
  
    allow_changes();
  
    -- Обновление статуса платежа
    update payment p
       set p.status = c_status_error, p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_status_create;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end fail_payment;

  -- Отмена платежа
  procedure cancel_payment(p_payment_id in payment.payment_id%type,
                           p_reason     in payment.status_change_reason%type) is
  Begin
  
    if p_payment_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
  
    if p_reason is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_reason);
    end if;
    
    try_lock_payment(p_payment_id => p_payment_id);
  
    allow_changes();
  
    -- Обновление статуса платежа
    update payment p
       set p.status = c_status_cancel, p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_status_create;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end cancel_payment;

  -- Завершение платежа (успешно)
  procedure successful_finish_payment(p_payment_id in payment.payment_id%type) is
  Begin
  
    if p_payment_id is null then
      raise_application_error(common_pack.c_error_code_invalid_input_parameter,
                              common_pack.c_error_msg_empty_object_id);
    end if;
    
    try_lock_payment(p_payment_id => p_payment_id);
  
    allow_changes();
  
    -- Обновление статуса платежа
    update payment p
       set p.status = c_status_success
     where p.payment_id = p_payment_id
       and p.status = c_status_create;
  
    disallow_changes();
  
  exception
    when others then
      disallow_changes();
      raise;
  end successful_finish_payment;

  -- Проверка вызова через API
  procedure payment_changes_through_api is
  begin
    if not g_is_api and not common_pack.is_payment_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_manual_changes,
                              common_pack.c_error_msg_manual_changes);
    end if;
  end;

  procedure check_payment_delete_restriction is
  begin
    if not common_pack.is_payment_manual_changes_allowed() then
      raise_application_error(common_pack.c_error_code_delete_forbidden,
                              common_pack.c_error_msg_delete_forbidden);
    end if;
  end;
  
  -- Блокировка платежа для изменения
  procedure try_lock_payment(p_payment_id in payment.payment_id%type) is
    v_status payment.status%type;
  begin
  
    select t.status
      into v_status
      from payment t
     where t.payment_id = p_payment_id
       for update nowait;
  
    if v_status in (c_status_success, c_status_error, c_status_cancel) then
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

end payment_api_pack;
/
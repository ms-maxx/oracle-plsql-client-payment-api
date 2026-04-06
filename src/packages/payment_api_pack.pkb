create or replace package body payment_api_pack is

  --Создание платежа
  function create_payment(p_payment_detail in t_payment_detail_array,
                          p_summa          in payment.summa%type,
                          p_from_client_id in payment.from_client_id%type,
                          p_to_client_id   in payment.to_client_id%type,
                          p_currency_id    in currency.currency_id%type,
                          p_current_dtime in date := sysdate)
    return payment.payment_id%type is
    v_payment_id payment.payment_id%type;
    v_massage    varchar2(50) := 'Платеж создан';
  Begin

    if p_payment_detail is not empty then
      for i in p_payment_detail.first .. p_payment_detail.last loop

        if (p_payment_detail(i).field_id is null) then
          raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_field_id);
        end if;

        if (p_payment_detail(i).field_value is null) then
          raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_field_value);
        end if;

        dbms_output.put_line('Field_id: ' || p_payment_detail(i).field_id ||
                             '. Value: ' || p_payment_detail(i).field_value);
      end loop;
    else
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_collection);
    end if;

    dbms_output.put_line(v_massage || '. Статус: ' || c_status_create);
    dbms_output.put_line(to_char(p_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));

    --Создание платежа
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

    dbms_output.put_line('Payment id of new payment: ' || v_payment_id);

    --Добавление данных платежа
    insert into payment_detail
      (payment_id, field_id, field_value)
      Select v_payment_id,value(t).field_id,value(t).field_value
        from table(p_payment_detail) t;

    return v_payment_id;

  end create_payment;

  --Сброс платежа
  procedure fail_payment(p_payment_id in payment.payment_id%type,
                         p_reason     in payment.status_change_reason%type) is
    v_massage varchar2(100) := 'Сброс платежа в "ошибочный статус" с указанием причины';
    v_current_dtime timestamp := systimestamp;
  Begin

    if p_payment_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;

    if p_reason is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_reason);
    end if;

    dbms_output.put_line(v_massage || '. Статус: ' || c_status_error ||
                         '. Причина: ' || p_reason || '. ID: ' ||
                         p_payment_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));

    --Обновление статуса платежа
    update payment p
       set p.status = c_status_error, p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_status_create;

  end fail_payment;

  --Отмена платежа
  procedure cancel_payment(p_payment_id in payment.payment_id%type,
                           p_reason     in payment.status_change_reason%type) is
    v_massage varchar2(100) := 'Отмена платежа с указанием причины';
    v_current_dtime timestamp := systimestamp;
  Begin

    if p_payment_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;

    if p_reason is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_reason);
    end if;

    dbms_output.put_line(v_massage || '. Статус: ' || c_status_cancel ||
                         '. Причина: ' || p_reason || '. ID: ' ||
                         p_payment_id);
    dbms_output.put_line(to_char(v_current_dtime,
                                 'dd.mm.yyyy hh24:mi:ss.ff'));

    --Обновление статуса платежа
    update payment p
       set p.status = c_status_cancel, p.status_change_reason = p_reason
     where p.payment_id = p_payment_id
       and p.status = c_status_create;

  end cancel_payment;

  --Завершение платежа (успешно)
  procedure successful_finish_payment(p_payment_id in payment.payment_id%type) is
    v_massage varchar2(100) := 'Успешное завершение платежа';
    v_current_dtime date := sysdate;
  Begin

    if p_payment_id is null then
      raise_application_error(c_error_invalid_input_prmtr, c_error_msg_empty_object_id);
    end if;
    dbms_output.put_line(v_massage || '. Статус: ' || c_status_success ||
                         '. ID: ' || p_payment_id);
    dbms_output.put_line(to_char(v_current_dtime, 'dd.mm.yyyy hh24:mi:ss'));

    --Обновление статуса платежа
    update payment p
       set p.status = c_status_success, p.status_change_reason = v_massage
     where p.payment_id = p_payment_id
       and p.status = c_status_create;

  end successful_finish_payment;

end payment_api_pack;
/
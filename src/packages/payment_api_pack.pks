create or replace package payment_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
  */

  -- Статусы создания/завершения (успешно) платежа
  c_status_create  constant payment.status%type := 0;
  c_status_success constant payment.status%type := 1;
  -- Статусы сброса/отмены платежа
  c_status_error  constant payment.status%type := 2;
  c_status_cancel constant payment.status%type := 3;

  --Создание платежа
  function create_payment(p_payment_detail in t_payment_detail_array,
                          p_summa          in payment.summa%type,
                          p_from_client_id in payment.from_client_id%type,
                          p_to_client_id   in payment.to_client_id%type,
                          p_currency_id    in currency.currency_id%type,
                          p_current_dtime  in date := sysdate)
    return payment.payment_id%type;

  --Сброс платежа
  procedure fail_payment(p_payment_id in payment.payment_id%type,
                         p_reason     in payment.status_change_reason%type);

  --Отмена платежа
  procedure cancel_payment(p_payment_id in payment.payment_id%type,
                           p_reason     in payment.status_change_reason%type);

  --Завершение платежа (успешно)
  procedure successful_finish_payment(p_payment_id in payment.payment_id%type);
  
  -- Triggers
  
  -- Проверка, выполняются ли изменения через API
  procedure payment_changes_through_api;
  
  -- Проверка на возможность удалять данные
  procedure check_payment_delete_restriction;

end payment_api_pack;
/
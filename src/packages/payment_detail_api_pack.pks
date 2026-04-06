create or replace package payment_detail_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Платеж” и “Детали платежа”
  */

  --Добавление/обновление данных платежа
  procedure insert_or_update_payment_detail(p_payment_id     in payment.payment_id%type,
                                            p_payment_detail in t_payment_detail_array);

  procedure delete_payment_detail(p_payment_id            in payment.payment_id%type,
                                  p_delete_payment_detail in t_number_array);
                                  
  -- Triggers
  
  -- Проверка, выполняются ли изменения через API
  procedure payment_detail_changes_through_api;

end payment_detail_api_pack;
/
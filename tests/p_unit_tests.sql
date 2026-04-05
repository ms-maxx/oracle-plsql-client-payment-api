--Заготовка под Unit-tests for Payment

--Проверка "Cоздания платежа"
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'iphone 14 pro'),
                                                                    t_payment_detail(2, '192.168.0.111'),
                                                                    t_payment_detail(3, 'test transaction'));
  v_summa          payment.summa%type := 1900;
  v_from_client_id payment.from_client_id%type := 1;
  v_to_client_id   payment.to_client_id%type := 2;
  v_currency_id    currency.currency_id%type := 840;
  v_payment_id     payment.payment_id%type;
begin
  v_payment_id := payment_api_pack.create_payment(p_payment_detail => v_payment_detail,
                                                  p_summa          => v_summa,
                                                  p_from_client_id => v_from_client_id,
                                                  p_to_client_id   => v_to_client_id,
                                                  p_currency_id    => v_currency_id);
  dbms_output.put_line('Payment_id: ' || v_payment_id);
end;
/

--Проверка "Сброс платежа"
declare
  v_payment_id payment.payment_id%type := 2;
  v_reason     payment.status_change_reason%type := 'test reset payment';
begin
  payment_api_pack.fail_payment(p_payment_id => v_payment_id,
                                p_reason     => v_reason);
end;
/

--Проверка "Отмена платежа"
declare
  v_payment_id payment.payment_id%type := 2;
  v_reason     payment.status_change_reason%type := 'test cancel payment';
begin
  payment_api_pack.cancel_payment(p_payment_id => v_payment_id,
                                  p_reason     => v_reason);
end;
/

--Проверка "Завершение платежа (успешно)"
declare
  v_payment_id payment.payment_id%type := 2;
begin
  payment_api_pack.successful_finish_payment(p_payment_id => v_payment_id);
end;
/

--Проверка "Добавление/обновление данных платежа"
declare
  v_payment_detail t_payment_detail_array := t_payment_detail_array(t_payment_detail(1, 'nokia 2310'),
                                                                    t_payment_detail(2, '192.120.1.888'),
                                                                    t_payment_detail(4, 'NO!'));
  v_payment_id     payment.payment_id%type := 2;
begin
  payment_detail_api_pack.insrt_or_upd_payment_detail(p_payment_id     => v_payment_id,
                                                      p_payment_detail => v_payment_detail);
end;
/

--Проверка "Удаление платежа"
declare
  v_payment_id            payment.payment_id%type := 2;
  v_delete_payment_detail t_number_array := t_number_array(2, 4);
begin
  payment_detail_api_pack.delete_payment_detail(p_payment_id            => v_payment_id,
                                                p_delete_payment_detail => v_delete_payment_detail);
end;
/
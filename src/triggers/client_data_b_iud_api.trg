create or replace trigger client_data_b_iud_api
  before insert or update or delete on client_data
begin
  client_data_api_pack.client_data_changes_through_api(); -- ѕроверка на выполнение команды через API
end;
/
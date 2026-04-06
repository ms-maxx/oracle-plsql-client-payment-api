create or replace trigger client_b_iu_api
  before insert or update on client
begin
  client_api_pack.client_changes_through_api(); -- проверка на выполнение команды через API
end;
/
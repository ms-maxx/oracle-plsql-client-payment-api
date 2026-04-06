create or replace package client_data_api_pack is
  /*
  Автор: Verbitskiy M.S
  Описание скрипта: API для сущностей “Клиент” и “Клиентские данные”
  */
  
  --  Добавление/Изменение клиентских данных
  procedure insert_or_update_client_data(p_client_id   in client.client_id%type,
                                         p_client_data in t_client_data_array);
                                         
  --  Удаление данных клиента
  procedure delete_client_data(p_client_id        in client.client_id%type,
                               p_delete_field_ids in t_number_array);
  
  --Проверка, вызываемая из триггера                             
  procedure client_data_changes_through_api;

end client_data_api_pack;
/

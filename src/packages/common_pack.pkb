create or replace package body common_pack is

  g_enable_manual_changes boolean := false; -- Разрешены ли изменения объектов не через API

  procedure enable_client_manual_changes is
  begin
    g_enable_manual_changes := true;
  end;

  procedure disable_client_manual_changes is
  begin
    g_enable_manual_changes := false;
  end;

  function is_client_manual_changes_allowed return boolean is
  begin
    return g_enable_manual_changes;
  end is_client_manual_changes_allowed;

end common_pack;
/
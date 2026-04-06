create or replace package body common_pack is

  g_c_enable_manual_changes boolean := false; -- Разрешены ли изменения объектов не через API (Client)
  g_p_enable_manual_changes boolean := false; -- Разрешены ли изменения объектов не через API (Payment)
  
  --Client
  procedure enable_client_manual_changes is
  begin
    g_c_enable_manual_changes := true;
  end;

  procedure disable_client_manual_changes is
  begin
    g_c_enable_manual_changes := false;
  end;

  function is_client_manual_changes_allowed return boolean is
  begin
    return g_c_enable_manual_changes;
  end is_client_manual_changes_allowed;
  
  --Payment
  procedure enable_payment_manual_changes is
  begin
    g_p_enable_manual_changes := true;
  end;
  
  procedure disable_payment_manual_changes is
  begin
    g_p_enable_manual_changes := false;
  end;
  
  function is_payment_manual_changes_allowed return boolean is
  begin
    return g_p_enable_manual_changes;
  end is_payment_manual_changes_allowed;

end common_pack;
/
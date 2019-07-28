CAMI.CU_TOKEN = "CU"

hook.Add("CAMI.OnUsergroupRegistered", "CUCami_GroupRegistered", function(group, token)
  if token == CAMI.CU_TOKEN then return; end
  if cu.group.Exists(group.Name) then return; end //Don't add groups that already exist inside the admin mod.

  cu.group.Create(group.Name, group.Name, Color(255, 255, 255, 255), group.Inherits, cu.group.GetImmunity(group.Inherits), {})
end)

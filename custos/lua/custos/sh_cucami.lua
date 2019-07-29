CAMI.CU_TOKEN = "CU"

hook.Add("CAMI.OnUsergroupUnregistered", "CUCami_GroupUnregistered", function(group, token)
  if token == CAMI.CU_TOKEN then return; end
  if not cu.group.Exists(group.Name) then return; end

  cu.group.Remove(group.Name)
end)

hook.Add("CAMI.PlayerUsergroupChanged", "CUCami_PlyGroupChanged", function(ply, oldGroup, newGroup, token)
  if token == CAMI.CU_TOKEN then return; end
  if not cu.group.Exists(group.Name) then return; end

  cu.user.Add(ply, newGroup)
end)

local function onGroupRegistered(group, token)
  if token == CAMI.CU_TOKEN then return; end
  if cu.group.Exists(group.Name) then return; end //Don't add groups that already exist inside the admin mod.

  //cu.group.Create(group.Name, group.Name, Color(255, 255, 255, 255), group.Inherits, cu.group.GetImmunity(group.Inherits), {})
  cu.group.Create(group.Name, {
    display = group.Name,
    color = Color(255,255,255,255),
    parent = group.Inherits,
    immunity = cu.group.GetImmunity(group.Inherits),
    perm = {}
  })
end
hook.Add("CAMI.OnUsergroupRegistered", "CUCami_GroupRegistered", onGroupRegistered)

local function onPrivRegistered(priv)
  if cu.perm.Check(priv.Name:lower()) then return; end

  cu.perm.Register(priv.Name)
  cu.group.AddPerm(priv.MinAccess, priv.Name:lower(), true)
end
hook.Add("CAMI.OnPrivilegeRegistered", "CUCami_PrivRegistered", onPrivRegistered)

function cu.LoadCAMI()
  for _,camiGroup in pairs(CAMI.GetUsergroups()) do
    onGroupRegistered(camiGroup)
  end

  for _,camiPriv in pairs(CAMI.GetPrivileges()) do
    onPrivRegistered(camiPriv)
  end

  for k,v in pairs(cu.group.GetAll()) do
    if k != "superadmin" or k != "admin" or k != "user" then
      CAMI.RegisterUsergroup({
        Name = k,
        Inherits = (parent or "user")
      }, CAMI.CU_TOKEN)
    end
  end
end

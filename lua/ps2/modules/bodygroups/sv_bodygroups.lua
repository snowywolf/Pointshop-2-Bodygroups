util.AddNetworkString("Bodygroups_Init")
util.AddNetworkString("Bodygroups_Set")

local BodygroupsModel = Pointshop2.BodygroupsModel

function LoadBodygroups( user )
  if !user:IsValid() then return end

  BodygroupsModel.findByOwnerId( user.kPlayerId )
  :Then( function( Data )

    if Data == nil then

        user.BodygroupsData = BodygroupsModel:new( )
        user.BodygroupsData.ownerId = user.kPlayerId

        return
    end

    user.BodygroupsData = Data

    net.Start( "Bodygroups_Init" )
        net.WriteUInt( Data.modelId, 16 )
        net.WriteUInt( Data.skin, 5 )
        net.WriteString( Data.groups )
    net.Send( user )

  end )

end
hook.Add( "PS2_PlayerFullyLoaded", "BG_LoadBodygroups", LoadBodygroups )

function SetBodyGroups( user )
    timer.Simple(0, function()

      if !user:IsValid() or user:PS2_GetItemInSlot( "Model" ) == nil then return end

      if user.BodygroupsData and user.BodygroupsData.modelId == user:PS2_GetItemInSlot( "Model" ).id then

        user:SetBodyGroups(user.BodygroupsData.groups)
        user:SetSkin(user.BodygroupsData.skin)

        return
      end

  end )
end
hook.Add( "PS2_PlayermodelShouldShow", "BG_SetBodyGroups", SetBodyGroups )

net.Receive( "Bodygroups_Set", function( len, client )
  if client.AntiSpam != nil and client.AntiSpam > SysTime() then return end

  client.AntiSpam = SysTime() + 1

  local Skin   = net.ReadUInt(5)
  local Groups = net.ReadString()

  client:SetBodyGroups(Groups)
  client:SetSkin(Skin)

  client.BodygroupsData.modelId = client:PS2_GetItemInSlot( "Model" ).id
  client.BodygroupsData.groups  = Groups
  client.BodygroupsData.skin    = Skin

  client.BodygroupsData:save()
end)

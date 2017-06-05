util.AddNetworkString("Bodygroups_Init")
util.AddNetworkString("Bodygroups_Set")

local BodygroupsModel = Pointshop2.BodygroupsModel

local meta = FindMetaTable("Player")
local entity = FindMetaTable("Entity")

function meta:LoadBodygroups()
	if !self:IsValid() then return end
	
	self.BodygroupsData = {}
	
	BodygroupsModel.findByOwnerId( self.kPlayerId )
	:Then( function( Data )
		if Data == nil then return end
		
		self.BodygroupsData[Data.modelId] = {Data.skin, Data.groups}
		
		net.Start( "Bodygroups_Init" )
		    for k, v in pairs( self.BodygroupsData ) do
			    net.WriteUInt( k, 16 )
				net.WriteUInt( v[1], 8 )
				net.WriteString( v[2] )
			end
		net.Send( self )

	end )
	
end

function meta:SaveBodyGroups( modelID )
	if !self:IsValid() then return end

	return BodygroupsModel.findWhere{ ownerId = self.kPlayerId }
	:Then( function( bodygroups )
		local bodygroup = bodygroups[1]
		if not bodygroup then
			--Create it
			bodygroup = BodygroupsModel:new( )
			bodygroup.ownerId = self.kPlayerId 
			bodygroup.modelId = modelID
		end
		bodygroup.skin   =  self.BodygroupsData[modelID][1]
		bodygroup.groups =  self.BodygroupsData[modelID][2]
		
		return bodygroup:save( )
	end )
end

function meta:UpdateBodygroups(ID, Skin, Groups)
	if !self:IsValid() then return end
	
	if not self.BodygroupsData then
		self:LoadBodygroups()
		
		timer.Simple(5, function()
			if not self:IsValid() then return end
			self:UpdateBodygroups(ID, Skin, Groups)
		end)
		return
	end

	self.BodygroupsData[ID] = {Skin, Groups}
	
	self:SaveBodyGroups(ID)
end

function meta:SetSkin(skin)
    if self:PS2_GetItemInSlot( "Model" ) == nil then return end
	local ID = self:PS2_GetItemInSlot( "Model" ).id
	if self.BodygroupsData and self.BodygroupsData[ID] != nil then
		self:SetBodyGroups(self.BodygroupsData[ID][2])
		entity.SetSkin(self, self.BodygroupsData[ID][1])
	end
end

-- hook.Add( "PS2_EquipItem", "Maybeusefulsomeday", function( ply, id, slotused )

net.Receive("Bodygroups_Set", function(len, ply)
    local ModelID = net.ReadInt(32)
    local groups = net.ReadString()
	local skin = net.ReadString()
	if ply.BGSpam != nil and ply.BGSpam > SysTime() then ply:ChatPrint(FLOOD_TAG.."You just set your bodygroup, please wait a moment before setting them again.") return end
	
	ply:UpdateBodygroups(ModelID, skin, groups)
	ply:SetSkin() --Overwritten skin function to set groups and skin.
	
	ply.BGSpam = SysTime() + 4
end)

hook.Add( "PS2_PlayerFullyLoaded", "Playerloaded22", function( ply )
    if !ply:IsValid() then return end
	ply:LoadBodygroups()
end )

-- hook.Add("LibK_PlayerInitialSpawn", "LoadBodygroups", function(ply)
	-- timer.Simple(5, function() -- Hm.
		-- if !ply:IsValid() then return end
		-- ply:LoadBodygroups()
	-- end)
-- end)
 --{Made by SNO}--

local PANEL = {}

function PANEL:Init()
	Pointshop2.BodyGroups = self
	
	self.id = 0
	self.skin = 0
	self.groups = "0"
    self.player = LocalPlayer()
	
	self.leftPanel = vgui.Create("DPanel", self)
	self.leftPanel:DockMargin( 8, 8, 8, 8 )
	self.leftPanel:DockPadding( 8, 8, 8, 8 )
	self.leftPanel:SetWide( 400 )
	self.leftPanel:Dock( LEFT )
	Derma_Hook( self.leftPanel, "Paint", "Paint", "InnerPanel" )

	self.bdcontrolspanel = vgui.Create("DIconLayout", self.leftPanel)
	self.bdcontrolspanel:DockMargin( 18, 0, 0, 0)
	self.bdcontrolspanel:SetSpaceX( 5 )
	self.bdcontrolspanel:SetSpaceY( 5 )
	self.bdcontrolspanel:Dock( FILL )
	self.bdcontrolspanel:SetSkin( "Default" )
	
	self.bottomPnl = vgui.Create( "DPanel", self.leftPanel )
	self.bottomPnl:Dock( BOTTOM )
	self.bottomPnl:SetTall( 50 )
	self.bottomPnl:DockMargin( 0, 8, 0, 0 )
	self.bottomPnl:DockPadding( 5, 5, 5, 5 )
	Derma_Hook( self.bottomPnl, "Paint", "Paint", "InnerPanel" )
	
	self.ApplyBtn = vgui.Create( "DButton", self.bottomPnl )
	self.ApplyBtn:Dock( FILL )
	self.ApplyBtn:SetText( "Apply" )
	self.ApplyBtn:SetVisible(false)
	self.ApplyBtn.DoClick = function()
	    self.player.BodygroupsData[self.id] = {self.skin, self.groups}
		hook.Run( "PS2_DoUpdatePreviewModel" )
		net.Start("Bodygroups_Set")
	        net.WriteUInt(self.id, 32)
		    net.WriteString(string.gsub(self.groups, "%s+", ""))
			net.WriteString(self.skin)
	    net.SendToServer()
	end
	
	self.preview = vgui.Create( "DPointshopInventoryPreviewPanel", self )
	self.preview:DockMargin( 0, 8, 8, 8 )
	self.preview:DockPadding( 0, 8, 8, 8 )
	self.preview:Dock( FILL )
	self.preview:SetFOV( 45 )
	self.preview:SetAnimated( true )

	self:UpdateAndList()

end

function PANEL:UpdateAndList() 
		self.bdcontrolspanel:Clear()
		
		hook.Run( "PS2_DoUpdatePreviewModel" )
		
        local playerModelItem = self.player.PS2_Slots["Model"]
		
		if playerModelItem == nil then return end
		
		self.id     = playerModelItem.id or 0
		self.skin   = self.player.BodygroupsData[self.id] and self.player.BodygroupsData[self.id][1] or 0
		self.groups = self.player.BodygroupsData[self.id] and self.player.BodygroupsData[self.id][2] or "0"
		
		self.previewentity = Pointshop2.InventoryPreviewPanel.Entity
		
		if self.id == 0 then return end
		
		local nskins = self.previewentity:SkinCount() - 1
		if ( nskins > 0 ) then
			local skins = vgui.Create( "DNumSlider" )
			skins:Dock( TOP )
			skins:SetText( "Skin" )
			skins:SetDark( false )
			skins:SetTall( 50 )
			skins:SetDecimals( 0 )
			skins:SetMax( nskins )
			skins:SetValue( self.skin )
			skins.type = "skin"
			skins.OnValueChanged = function( pnl, val ) 
			    self.preview.Entity:SetSkin( math.Round( val ) )
		        self.skin = math.Round( val )
			end
			
			self.bdcontrolspanel:Add( skins )
			self.bdcontrolspanel:Layout()
			self.preview.Entity:SetSkin( self.skin )
			self.ApplyBtn:SetVisible(true)
		end

		local groups = string.Explode( " ", self.groups )
		for k = 0, self.previewentity:GetNumBodyGroups() - 1 do
			if ( self.previewentity:GetBodygroupCount( k ) <= 1 ) then continue end

			local bgroup = vgui.Create( "DNumSlider" )
			bgroup:Dock( TOP )
			bgroup:SetText( MakeNiceName( self.previewentity:GetBodygroupName( k ) ) )
			bgroup:SetDark( false )
			bgroup:SetTall( 50 )
			bgroup:SetDecimals( 0 )
			bgroup.type = "bgroup"
			bgroup.typenum = k
			bgroup:SetMax( self.previewentity:GetBodygroupCount( k ) - 1 )
			bgroup:SetValue( groups[ k + 1 ] or 0 )
			bgroup.OnValueChanged = function( pnl, val ) 
			    self.preview.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )
				local str = string.Explode( " ", self.groups )
		        if ( #str < pnl.typenum + 1 ) then for i = 1, pnl.typenum + 1 do str[ i ] = str[ i ] or 0 end end
		        str[ pnl.typenum + 1 ] = math.Round( val )
		        self.groups = table.concat( str, " " )
			end
			
			self.bdcontrolspanel:Add( bgroup )
	        self.bdcontrolspanel:Layout()
			self.preview.Entity:SetBodygroup( k, groups[ k + 1 ] or 0 )
			self.ApplyBtn:SetVisible(true)
		end
end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopBodygroupsPanel", "", PANEL )

Pointshop2:AddInventoryPanel("Bodygroups", "icon64/playermodel.png", "DPointshopBodygroupsPanel")

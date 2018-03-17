
local Player = LocalPlayer()

local PANEL = {}

function PANEL:Init()

  self.ModelID = LocalPlayer().PS2_Slots["Model"] and LocalPlayer().PS2_Slots["Model"].id or 0

  self.skin   = 0
  self.groups = "0"

  local MainPanel = vgui.Create( "DPanel", self )
  MainPanel:DockMargin( 8, 8, 8, 8 )
  MainPanel:DockPadding( 8, 8, 8, 8 )
  MainPanel:SetWide( 400 )
  MainPanel:Dock( LEFT )
  Derma_Hook( MainPanel, "Paint", "Paint", "InnerPanel" )

  local bottomPnl = vgui.Create( "DPanel", MainPanel )
  bottomPnl:Dock( BOTTOM )
  bottomPnl:SetTall( 50 )
  bottomPnl:DockMargin( 0, 8, 0, 0 )
  bottomPnl:DockPadding( 5, 5, 5, 5 )
  Derma_Hook( bottomPnl, "Paint", "Paint", "InnerPanel" )

  self.ScrollPanel = vgui.Create( "DScrollPanel", MainPanel )
  self.ScrollPanel:DockMargin( 18, 0, 0, 0)
  self.ScrollPanel:Dock( FILL )
  self.ScrollPanel.Clear = function( ScrollPanel )
    self.ApplyBtn:SetVisible(false)
    return ScrollPanel.pnlCanvas:Clear()
  end

  self.ApplyBtn = vgui.Create( "DButton", bottomPnl )
  self.ApplyBtn:Dock( FILL )
  self.ApplyBtn:SetText( "Apply" )
  self.ApplyBtn:SetVisible(false)
  self.ApplyBtn.DoClick = function()
      Player.BodygroupsData[self.ModelID] = {self.skin, self.groups}

      hook.Run( "PS2_DoUpdatePreviewModel" )

      net.Start("Bodygroups_Set")
        net.WriteUInt(self.skin, 5)
        net.WriteString(string.gsub(self.groups, "%s+", ""))
      net.SendToServer()
  end

  self.PreviewPanel = vgui.Create( "DPointshopInventoryPreviewPanel", self )
  self.PreviewPanel:DockMargin( 0, 8, 8, 8 )
  self.PreviewPanel:DockPadding( 0, 8, 8, 8 )
  self.PreviewPanel:Dock( FILL )
  self.PreviewPanel:SetFOV( 65 )
  self.PreviewPanel:SetAnimated( true )

  if self.ModelID != 0 then self:UpdateAndList() end

  hook.Add( "PS2_ItemEquipped", "BGItemEquipped", function( ply, item )
    if Player != ply or !instanceOf( Pointshop2.GetItemClassByName( "base_playermodel" ), item ) then return end

    self.ModelID = item.id

    self:UpdateAndList()
  end)

  hook.Add( "PS2_ItemUnequipped", "BGItemUnequipped", function( ply, item )
    if Player != ply or !instanceOf( Pointshop2.GetItemClassByName( "base_playermodel" ), item ) then return end

    self.ScrollPanel:Clear()
  end)

end

function PANEL:UpdateAndList()

  hook.Run( "PS2_DoUpdatePreviewModel" )

  self.skin   = Player.BodygroupsData[self.ModelID] and Player.BodygroupsData[self.ModelID][1] or 0
  self.groups = Player.BodygroupsData[self.ModelID] and Player.BodygroupsData[self.ModelID][2] or "0"

  local PS2PreviewEntity = Pointshop2.InventoryPreviewPanel.Entity

  local nskins = PS2PreviewEntity:SkinCount() - 1
  if ( nskins > 0 ) then
    local skins = self.ScrollPanel:Add( "DNumSlider" )
    skins:SetSkin( "Default" )
    skins:Dock( TOP )
    skins:SetText( "Skin" )
    skins:SetDark( false )
    skins:SetTall( 50 )
    skins:SetDecimals( 0 )
    skins:SetMax( nskins )
    skins:SetValue( self.skin )
    skins.OnValueChanged = function( pnl, val )
        self.PreviewPanel.Entity:SetSkin( math.Round( val ) )
        self.skin = math.Round( val )
      end
    end

  local groups = string.Explode( " ", self.groups )
  for k = 0, PS2PreviewEntity:GetNumBodyGroups() - 1 do
    if ( PS2PreviewEntity:GetBodygroupCount( k ) <= 1 ) then continue end

    local bgroup = self.ScrollPanel:Add( "DNumSlider" )
    bgroup:SetSkin( "Default" )
    bgroup:Dock( TOP )
    bgroup:SetText( MakeNiceName( PS2PreviewEntity:GetBodygroupName( k ) ) )
    bgroup:SetDark( false )
    bgroup:SetTall( 50 )
    bgroup:SetDecimals( 0 )
    bgroup:SetMax( PS2PreviewEntity:GetBodygroupCount( k ) - 1 )
    bgroup:SetValue( groups[ k + 1 ] or 0 )
    bgroup.typenum = k
    bgroup.OnValueChanged = function( pnl, val )
        self.PreviewPanel.Entity:SetBodygroup( pnl.typenum, math.Round( val ) )

        local str = string.Explode( " ", self.groups )
        if ( #str < pnl.typenum + 1 ) then for i = 1, pnl.typenum + 1 do str[ i ] = str[ i ] or 0 end end
        str[ pnl.typenum + 1 ] = math.Round( val )

        self.groups = table.concat( str, " " )
    end
  end

  if PS2PreviewEntity:GetNumBodyGroups() > 1 or nskins > 0 then
    self.ApplyBtn:SetVisible(true)
  end

end

Derma_Hook( PANEL, "Paint", "Paint", "PointshopInventoryTab" )
derma.DefineControl( "DPointshopBGPanel", "", PANEL )

Pointshop2:AddInventoryPanel( "Bodygroups", "icon64/playermodel.png", "DPointshopBGPanel" )

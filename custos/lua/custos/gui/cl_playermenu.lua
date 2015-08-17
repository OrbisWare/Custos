/*
	 _____           _            
	/  __ \         | |           
	| /  \/_   _ ___| |_ ___  ___ 
	| |   | | | / __| __/ _ \/ __|
	| \__/\ |_| \__ \ || (_) \__ \
	 \____/\__,_|___/\__\___/|___/

	~https://github.com/BadWolfGames/custos

	Player Menu
*/
local PANEL = {}

function PANEL:Init()
	self:SetSize(250, 500)
	self:SetPos((ScrW()/2) - (self:GetWide()/2), (ScrH()/2) - (self:GetTall()/2))

	self.List = vgui.Create("DPanelList", self)
	self.List:SetSize(self:GetWide(), self:GetTall())
	self.List:DockMargin(0,0,0,0)
	self.List:EnableVerticalScrollbar(true)
end

function PANEL:Think()
	if !self.NextUpdate or self.NextUpdate < RealTime() then
		for _,ply in pairs(player.GetAll()) do

			local bHasPlayer = false
			for n,items in pairs(self.List.Items) do
				if items:GetPlayer() == ply then
					bHasPlayer = true
				end
			end

			if !bHasPlayer then
				local plyrow = vgui.Create("CUPlayerRow")
				plyrow:SetPlayer(ply)

				self.List:AddItem(plyrow)
			end
		end

		for n,items in pairs(self.List.Items) do
			if !table.HasValue(player.GetAll(), items:GetPlayer()) then
				self.List:Remove(items)
			end
		end

		self.NextUpdate = RealTime() + 0.5
	end
end

function PANEL:PerformLayout()
	for _,items in pairs(self.List.Items) do
		items:InvalidateLayout(true)
		items:SetWide(self:GetWide())
	end
end

function PANEL:Paint(w, h)
	//Background
	surface.SetDrawColor(255,255,255,255)
	surface.DrawRect(0, 0, self:GetWide(), self:GetTall())
end
vgui.Register("CUPlayerMenu", PANEL)

local cu_qm = nil
concommand.Add("+cu_playermenu", function()
	if !ValidPanel(cu_qm) then
		cu_qm = vgui.Create("CUPlayerMenu")
		cu_qm:InvalidateLayout(true)
		cu_qm:SetVisible(true)
		gui.EnableScreenClicker(true)
	end
end)

concommand.Add("-cu_playermenu", function()
	if ValidPanel(cu_qm) then
		cu_qm:SetVisible(false)
		cu_qm:Clear()
		gui.EnableScreenClicker(false)
		cu_qm = nil
	end
end)
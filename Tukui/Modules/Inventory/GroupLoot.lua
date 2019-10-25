local T, C, L = select(2, ...):unpack()
local Inventory = T["Inventory"]
local GroupLoot = CreateFrame("Frame")

-- Lib Globals
local _G = _G
local select = select
local unpack = unpack
local pairs = pairs

-- WoW Globals
--local GetLootRollItemInfo = GetLootRollItemInfo -- Comment out only for testing.
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local NUM_GROUP_LOOT_FRAMES = NUM_GROUP_LOOT_FRAMES

-- Locals
GroupLoot.Height = 0
GroupLoot.PreviousFrame = {}

function GroupLoot:TestGroupLootFrames()
	GetLootRollItemInfo = function(RollID)
		Texture = 135226
		Name = "Atiesh, Greatstaff of the Guardian"
		Count = RollID
		Quality	= RollID + 1
		BindOnPickUp = math.random(0, 1) > 0.5
		CanNeed	= true
		CanGreed = true
		ReasonNeed = 0
		ReasonGreed = 0

		return Texture, Name, Count, Quality, BindOnPickUp, CanNeed, CanGreed, ReasonNeed, ReasonGreed
	end
	
	function GroupLootFrame_OnUpdate() end

	for i = 1, NUM_GROUP_LOOT_FRAMES do
		GroupLootFrame_OpenNewFrame(i, 300)
		_G["GroupLootFrame" .. i].Timer:SetValue(math.random(8, 300))
	end
end

function GroupLoot:SkinGroupLoot(Frame)
	Frame:StripTexture()

	if (Frame.Timer.Background) then
		Frame.Timer.Background:Kill()
	end
	
	if (_G[Frame:GetName().."NameFrame"] or _G[Frame:GetName().."Corner"]) then
		_G[Frame:GetName().."NameFrame"]:Kill()
		_G[Frame:GetName().."Corner"]:Kill()
	end

	Frame.OverlayContrainerFrame = CreateFrame("Frame", nil, Frame)
	Frame.OverlayContrainerFrame:SetFrameLevel(Frame:GetFrameLevel() - 1)
	Frame.OverlayContrainerFrame:Size(233, 32)
	Frame.OverlayContrainerFrame:Point("CENTER", Frame, 0, 0)
	Frame.OverlayContrainerFrame:CreateBackdrop("Transparent")
	Frame.OverlayContrainerFrame:CreateShadow()
	
	Frame.IconFrame:SetTemplate()
	Frame.IconFrame:CreateShadow()
	Frame.IconFrame:Size(44, 44)
	Frame.IconFrame:ClearAllPoints()
	Frame.IconFrame:Point("LEFT", Frame.OverlayContrainerFrame, -48, -6)
	
	Frame.IconFrame.Icon:SetTexCoord(unpack(T.IconCoord))
	Frame.IconFrame.Icon:SetInside()
	Frame.IconFrame.Icon:SetSnapToPixelGrid(false)
	Frame.IconFrame.Icon:SetTexelSnappingBias(0)
	
	Frame.PassButton:ClearAllPoints()
	Frame.PassButton:Point("RIGHT", Frame.OverlayContrainerFrame, 0, 0)
	Frame.PassButton:SkinCloseButton(nil, nil, 16)
	
	Frame.GreedButton:Size(28, 28)
	Frame.GreedButton:ClearAllPoints()
	Frame.GreedButton:Point("LEFT", Frame.PassButton, -26, -2)

	Frame.NeedButton:Size(28, 28)
	Frame.NeedButton:ClearAllPoints()
	Frame.NeedButton:Point("LEFT", Frame.GreedButton, -32, 1)
end

function GroupLoot:UpdateGroupLoot(Frame)
	Frame.Name:ClearAllPoints()
	Frame.Name:Point("LEFT", Frame.OverlayContrainerFrame, 6, 0)
	--Frame.Name:SetFontTemplate("Default", 14) -- Needs to be changed for Tukui
	
	Frame.IconFrame.Count:ClearAllPoints()
	Frame.IconFrame.Count:Point("BOTTOMRIGHT", -2, 4)
	--Frame.IconFrame.Count:SetFontTemplate("Default", 14) -- Needs to be changed for Tukui
	
	Frame.Timer:StripTexture(true)
	--Frame.Timer:SetStatusBarTexture(C.Media.Texture) -- Needs to be changed for Tukui
	Frame.Timer:ClearAllPoints()
	Frame.Timer:Size(232, 8)
	Frame.Timer:Point("BOTTOM", Frame.OverlayContrainerFrame, 0, -12)
	
	Frame.Timer.OverlayTimerFrame = CreateFrame("Frame", nil, 	Frame.Timer)
	Frame.Timer.OverlayTimerFrame:SetFrameLevel(Frame.Timer:GetFrameLevel() - 1)
	Frame.Timer.OverlayTimerFrame:SetInside()
	Frame.Timer.OverlayTimerFrame:CreateBackdrop("Transparent")
	Frame.Timer.OverlayTimerFrame:CreateShadow()
end

function GroupLoot:GroupLootFrameOnShow()
	local Texture, Name, Count, Quality, BindOnPickUp, CanNeed, CanGreed, ReasonNeed, ReasonGreed = GetLootRollItemInfo(self.rollID)
	local Color = ITEM_QUALITY_COLORS[Quality]

	self:SetBackdrop(nil)
	self.OverlayContrainerFrame:SetBackdropColor(Color.r * 0.25, Color.g * 0.25, Color.b * 0.25, 0.7)
	self.Timer:SetStatusBarColor(1, 0.82, 0, 0.50)
	--self.Name:SetVertexColor(1, 1, 1)
end

function GroupLoot:UpdateGroupLootContainer()
	for ID, Frames in ipairs(self.rollFrames) do
		Frames:ClearAllPoints()
		
		if (ID == 1) then
			Frames:Point("TOP", UIParent, 0, -6)
		else

			Frames:Point("TOP", GroupLoot.PreviousFrame, "BOTTOM", 0, 28)
		end

		GroupLoot.PreviousFrame = Frames
		GroupLoot.Height = GroupLoot.Height + 128 + 4
	end

	self:Height(GroupLoot.Height, 4)
end

function GroupLoot:Enable()
	for i = 1, NUM_GROUP_LOOT_FRAMES do
		local Frame = _G["GroupLootFrame" .. i]
		self:SkinGroupLoot(Frame)
		self:UpdateGroupLoot(Frame)
		Frame:HookScript("OnShow", self.GroupLootFrameOnShow)
	end
	
	-- So we can move the Group Loot Container.
	UIPARENT_MANAGED_FRAME_POSITIONS.GroupLootContainer = nil
	hooksecurefunc("GroupLootContainer_Update", self.UpdateGroupLootContainer)
	
	--self:TestGroupLootFrames() -- FOR TESTING!
end

Inventory.GroupLoot = GroupLoot
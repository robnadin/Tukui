local T, C, L = select(2, ...):unpack()
local ObjectiveTracker = CreateFrame("Frame", nil, UIParent)
local Misc = T["Miscellaneous"]
local Movers = T["Movers"]
local Class = select(2, UnitClass("player"))
local CustomClassColor = T.Colors.class[Class]
local QuestWatchFrame = QuestWatchFrame
local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -228, -325

function ObjectiveTracker:CreateHolder()
	local ObjectiveFrameHolder = CreateFrame("Frame", "TukuiObjectiveTracker", UIParent)
	ObjectiveFrameHolder:Size(130, 22)
	ObjectiveFrameHolder:SetPoint(Anchor1, Parent, Anchor2, X, Y)
	
	self.Holder = ObjectiveFrameHolder
end

function ObjectiveTracker:SetDefaultPosition()
	local Data = TukuiData[GetRealmName()][UnitName("Player")]
	local ObjectiveFrameHolder = self.Holder
	
	QuestWatchFrame:SetParent(ObjectiveFrameHolder)
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOPLEFT")
	
	if Data and Data.Move and Data.Move.TukuiObjectiveTracker then
		ObjectiveFrameHolder:ClearAllPoints()
		ObjectiveFrameHolder:SetPoint(unpack(Data.Move.TukuiObjectiveTracker))
	end
	
	Movers:RegisterFrame(ObjectiveFrameHolder)
end

function ObjectiveTracker:Skin()
	local HeaderBar = CreateFrame("StatusBar", nil, QuestWatchFrame)
	local HeaderText = HeaderBar:CreateFontString(nil, "OVERLAY")
	
	HeaderBar:Size(QuestWatchFrame:GetWidth(), 2)
	HeaderBar:SetPoint("TOPLEFT", QuestWatchFrame, 0, -4)
	HeaderBar:SetStatusBarTexture(C.Medias.Blank)
	HeaderBar:SetStatusBarColor(unpack(CustomClassColor))
	HeaderBar:SetTemplate()
	HeaderBar:CreateShadow()
	
	HeaderText:SetFontTemplate(C.Medias.Font, 12)
	HeaderText:Point("LEFT", HeaderBar, "LEFT", -2, 14)
	HeaderText:SetText(CURRENT_QUESTS)
	
	-- Change font of watched quests
	for i = 1, 30 do
		local Line = _G["QuestWatchLine"..i]

		Line:SetFont(C.Medias.Font, 12, "OUTLINE")
	end
	
	self.HeaderBar = HeaderBar
end

function ObjectiveTracker:AddHooks()

end

function ObjectiveTracker:Enable()
	self:CreateHolder()
	self:SetDefaultPosition()
	self:Skin()
	self:AddHooks()
end

Misc.ObjectiveTracker = ObjectiveTracker
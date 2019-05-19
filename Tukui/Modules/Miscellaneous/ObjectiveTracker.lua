local T, C, L = select(2, ...):unpack()
local ObjectiveTracker = CreateFrame("Frame", nil, UIParent)
local Misc = T["Miscellaneous"]
local Movers = T["Movers"]

function ObjectiveTracker:Enable()
	local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -228, -325
	local Data = TukuiData[GetRealmName()][UnitName("Player")]
	local QuestWatchFrame = QuestWatchFrame
	
	local ObjectiveFrameHolder = CreateFrame("Frame", "TukuiObjectiveTracker", UIParent)
	ObjectiveFrameHolder:Size(130, 22)
	ObjectiveFrameHolder:SetPoint(Anchor1, Parent, Anchor2, X, Y)
	
	QuestWatchFrame:SetParent(ObjectiveFrameHolder)
	QuestWatchFrame:ClearAllPoints()
	QuestWatchFrame:SetPoint("TOPLEFT")
	
	if Data and Data.Move and Data.Move.TukuiObjectiveTracker then
		ObjectiveFrameHolder:ClearAllPoints()
		ObjectiveFrameHolder:SetPoint(unpack(Data.Move.TukuiObjectiveTracker))
	end
	
	Movers:RegisterFrame(ObjectiveFrameHolder)
end

Misc.ObjectiveTracker = ObjectiveTracker
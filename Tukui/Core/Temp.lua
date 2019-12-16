----------------------------------
-- Temporary code in this file! --
----------------------------------

local T, C, L = select(2, ...):unpack()

-- TEMP for bg bugs
local Battleground = CreateFrame("Frame", nil, UIParent)
Battleground:Size(574, 40)
Battleground:SetTemplate()
Battleground:CreateShadow()
Battleground:SetPoint("TOP", 0, -29)
Battleground:Hide()
Battleground.Text = Battleground:CreateFontString(nil, "OVERLAY")
Battleground.Text:SetFontTemplate(C.Medias.UnitFrameFont, 16)
Battleground.Text:SetText("You can now enter a new battleground, right-click on minimap battleground button to enter or leave")
Battleground.Text:SetPoint("CENTER")
Battleground.Text:SetTextColor(1, 0, 0)

local Animation = Battleground:CreateAnimationGroup()
Animation:SetLooping("BOUNCE")

local FadeOut = Animation:CreateAnimation("Alpha")
FadeOut:SetFromAlpha(1)
FadeOut:SetToAlpha(0.8)
FadeOut:SetDuration(0.2)
FadeOut:SetSmoothing("IN_OUT")

local function OnEvent()
	for i = 1, MAX_BATTLEFIELD_QUEUES do
		local Status, Map, InstanceID = GetBattlefieldStatus(i)
		
		if Status == "confirm" then
			StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
			
			Battleground:Show()
			Animation:Play()
			
			return
		end
	end
	
	Battleground:Hide()
	Animation:Stop()
end

Battleground:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
Battleground:SetScript("OnEvent", OnEvent)
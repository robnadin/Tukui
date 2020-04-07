----------------------------------
-- Temporary code in this file! --
----------------------------------

local T, C, L = select(2, ...):unpack()

-- TEMP for bg popup taint bug
local Battleground = CreateFrame("Frame", nil, UIParent)
Battleground:SetFrameStrata("HIGH")
Battleground:Size(400, 60)
Battleground:SetTemplate()
Battleground:CreateShadow()
Battleground:SetPoint("TOP", 0, -29)
Battleground:Hide()
Battleground:SetBorderColor(1.00, 0.95, 0.32)

Battleground.Text1 = Battleground:CreateFontString(nil, "OVERLAY")
Battleground.Text1:SetFontTemplate(C.Medias.Font, 16)
Battleground.Text1:SetPoint("TOP", 0, -10)
Battleground.Text1:SetTextColor(1.00, 0.95, 0.32)

Battleground.Text2 = Battleground:CreateFontString(nil, "OVERLAY")
Battleground.Text2:SetFontTemplate(C.Medias.Font, 16)
Battleground.Text2:SetPoint("BOTTOM", 0, 10)
Battleground.Text2:SetTextColor(1.00, 0.95, 0.32)
Battleground.Text2:SetText("Right-click on minimap battleground button to enter")

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
			local String = StaticPopup1Text:GetText()
			local Text = string.gsub(String, ",.*", "")

			StaticPopup_Hide("CONFIRM_BATTLEFIELD_ENTRY")
			
			Battleground.Text1:SetText(Text)
			Battleground:Show()
			
			Animation:Play()
			
			T.Print(Text)
			
			return
		end
	end
	
	Battleground:Hide()
	Animation:Stop()
end

Battleground:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
Battleground:SetScript("OnEvent", OnEvent)

-- Temp for nickname color in chat, because altering RAID_CLASS_COLOR taint.
function GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12)
	local chatType = strsub(event, 10)
	
	if (strsub(chatType, 1, 7) == "WHISPER") then
		chatType = "WHISPER"
	end
	
	if (strsub(chatType, 1, 7) == "CHANNEL") then
		chatType = "CHANNEL"..arg8
	end
	
	local info = ChatTypeInfo[chatType]

	if (chatType == "GUILD") then
		arg2 = Ambiguate(arg2, "guild")
	else
		arg2 = Ambiguate(arg2, "none")
	end

	if (arg12 and info and Chat_ShouldColorChatByClass(info)) then
		local localizedClass, englishClass, localizedRace, englishRace, sex = GetPlayerInfoByGUID(arg12)

		if (englishClass) then
			local R, G, B = unpack(T.Colors.class[englishClass])
			
			if (not R) then
				return arg2
			end
			
			return string.format("\124cff%.2x%.2x%.2x", R * 255, G * 255, B * 255)..arg2.."\124r"
		end
	end

	return arg2
end

-- Temp, for /who command, shaman color.
local function UpdateWhoShamanColor()
	local WhoOffset = FauxScrollFrame_GetOffset(WhoListScrollFrame)
	local WhoIndex, Button, Text
	
	for i=1, WHOS_TO_DISPLAY, 1 do
		WhoIndex = WhoOffset + i;
		Button = _G["WhoFrameButton"..i]
		Text = _G["WhoFrameButton"..i.."Class"]

		local Info = C_FriendList.GetWhoInfo(WhoIndex)
		
		if Info and Info.filename == "SHAMAN" and Text then
			Text:SetTextColor(unpack(T.Colors.class["SHAMAN"]))
		end
	end
end

hooksecurefunc("WhoList_Update", UpdateWhoShamanColor)
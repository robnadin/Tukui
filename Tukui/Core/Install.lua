local T, C, L = select(2, ...):unpack()

local Install = CreateFrame("Frame", nil, UIParent)

-- Create a Tukui popup for resets
T.Popups.Popup["TUKUI_RESET_SETTINGS"] = {
	Question = "This will clear all of your saved settings. Continue?",
	Answer1 = ACCEPT,
	Answer2 = CANCEL,
	Function1 = function(self)
		Install.ResetSettings()
		
		ReloadUI()
	end,
}

-- Reset GUI settings
function Install:ResetSettings()
	if TukuiUseGlobal then
		TukuiSettings = {}
	else
		TukuiSettingsPerChar = {}
	end
	
	if TukuiData[GetRealmName()][UnitName("Player")].Move then
		TukuiData[GetRealmName()][UnitName("Player")].Move = {}
	end
end

-- Reset datatext & chats
function Install:ResetData()
	if (T.DataTexts) then
		T.DataTexts:Reset()
	end

	TukuiData[GetRealmName()][UnitName("Player")] = {}

	TukuiUseGlobal = false
	
	FCF_ResetChatWindows()
	
	if ChatConfigFrame:IsShown() then
		ChatConfig_UpdateChatSettings()
	end
	
	self:SetDefaults()

	ReloadUI()
end

-- Apply these defaults automaticaly when a new character is created [step 1]
function Install:SetDefaults()
	-- CVars
	SetCVar("countdownForCooldowns", 1)
	SetCVar("buffDurations", 1)
	SetCVar("scriptErrors", 1)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("screenshotQuality", 8)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "im")
	SetCVar("showTutorials", 0)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoQuestProgress", 1)
	SetCVar("UberTooltips", 1)
	SetCVar("removeChatDelay", 1)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("spamFilter", 0)
	SetCVar("violenceLevel", 5)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("nameplateMotion", 0)
	SetCVar("lootUnderMouse", 1)
	SetCVar("instantQuestText", 1)
	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("nameplateShowEnemyMinions", 1)
	SetCVar("nameplateShowEnemyMinus", 1)
	SetCVar("nameplateShowFriends", 0)
	SetCVar("nameplateShowFriendlyMinions", 0)
	SetCVar("cameraSmoothStyle", 0)
	SetCVar("profanityFilter", 0)

	local Chat = T["Chat"]

	if (Chat) then
		Chat:Install()
	end
end

-- Apply these defaults automaticaly when a new character is created [step 2]
function Install:MoveChannels()
	local Chat = T["Chat"]

	if (Chat) then
		Chat:MoveChannels()
	end
	
	TukuiData[GetRealmName()][UnitName("Player")].InstallDone = true	
end

Install:RegisterEvent("VARIABLES_LOADED")
Install:RegisterEvent("PLAYER_ENTERING_WORLD")
Install:SetScript("OnEvent", function(self, event)
	if (event == "VARIABLES_LOADED") then
		local Name = UnitName("Player")
		local Realm = GetRealmName()

		if (not TukuiData) then
			TukuiData = {}
		end

		if (not TukuiData[Realm]) then
			TukuiData[Realm] = {}
		end

		if (not TukuiData[Realm][Name]) then
			TukuiData[Realm][Name] = {}
		end

		if (not TukuiData[GetRealmName()][UnitName("Player")].InstallDone) then
			self:SetDefaults()
		end
	elseif (event == "PLAYER_ENTERING_WORLD") then
		if (TukuiData[GetRealmName()][UnitName("Player")].ChatReset) or (not TukuiData[GetRealmName()][UnitName("Player")].InstallDone) then
			self:MoveChannels()
				
			if (TukuiData[GetRealmName()][UnitName("Player")].ChatReset) then
				TukuiData[GetRealmName()][UnitName("Player")].ChatReset = false
			end
		end
	end
end)

T["Install"] = Install
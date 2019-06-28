local T, C, L = select(2, ...):unpack()

local Loading = CreateFrame("Frame")

function Loading:LoadCustomSettings()
	local Settings
	local Name = UnitName("Player")
	local Realm = GetRealmName()

	if (TukuiConfigPerAccount) then
		Settings = TukuiConfigShared.Account
	else
		Settings = TukuiConfigShared[Realm][Name]
	end

	for group, options in pairs(Settings) do
		if C[group] then
			local Count = 0

			for option, value in pairs(options) do
				if (C[group][option] ~= nil) then
					if (C[group][option] == value) then
						Settings[group][option] = nil
					else
						Count = Count + 1

						C[group][option] = value
					end
				end
			end

			-- Keeps TukuiConfig clean and small
			if (Count == 0) then
				Settings[group] = nil
			end
		else
			Settings[group] = nil
		end
	end
end

function Loading:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		-- PANELS
			T["Panels"]:Enable()

		-- INVENTORY
			-- Bags
			if (C.Bags.Enable) then
				T["Inventory"]["Bags"]:Enable()
			end

			-- Loot Frame
			T["Inventory"]["Loot"]:Enable()

			-- Merchant
			T["Inventory"]["Merchant"]:Enable()

		-- ACTION BARS
			if (C.ActionBars.Enable) then
				T["ActionBars"]:Enable()
			end

		-- COOLDOWNS
			T["Cooldowns"]:Enable()

		-- MISCELLANEOUS
			if C["Misc"].ExperienceEnable then
				T["Miscellaneous"]["Experience"]:Enable()
			end

			if C["Misc"].ReputationEnable then
				T["Miscellaneous"]["Reputation"]:Enable()
			end

			if C["Misc"].ErrorFilterEnable then
				T["Miscellaneous"]["ErrorFilter"]:Enable()
			end

			T["Miscellaneous"]["MirrorTimers"]:Enable()
			T["Miscellaneous"]["DropDown"]:Enable()
			T["Miscellaneous"]["CollectGarbage"]:Enable()
			T["Miscellaneous"]["GameMenu"]:Enable()
			T["Miscellaneous"]["StaticPopups"]:Enable()
			T["Miscellaneous"]["Durability"]:Enable()
			--T["Miscellaneous"]["UIWidgets"]:Enable()
			T["Miscellaneous"]["AFK"]:Enable()
			T["Miscellaneous"]["MicroMenu"]:Enable()

		-- BUFFS
			if (C.Auras.Enable) then
				T["Auras"]:Enable()
			end

		-- Maps
			T["Maps"]["Minimap"]:Enable()
			--T["Maps"]["Zonemap"]:Enable()
			T["Maps"]["Worldmap"]:Enable()

		-- DATATEXTS
			T["DataTexts"]:Enable()

		-- CHAT
			T["Chat"]:Enable()

		-- UNITFRAMES
			T["UnitFrames"]:Enable()

		-- TOOLTIPS
			T["Tooltips"]:Enable()

		-- Because peoples seem to not know about this?
			print(T.WelcomeMessage)

		-- Taint Fix
		--ShowUIPanel(SpellBookFrame)
		--HideUIPanel(SpellBookFrame)
	elseif (event == "PLAYER_ENTERING_WORLD") then
		-- OBJECTIVE TRACKER
			T["Miscellaneous"]["ObjectiveTracker"]:Enable()
	end
end

Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("PLAYER_ENTERING_WORLD")
Loading:RegisterEvent("ADDON_LOADED")
Loading:SetScript("OnEvent", Loading.OnEvent)

T["Loading"] = Loading


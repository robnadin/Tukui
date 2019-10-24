local T, C, L = select(2, ...):unpack()

local Miscellaneous = T["Miscellaneous"]
local MicroMenu = CreateFrame("Frame", "TukuiMicroButtonsDropDown", UIParent, "UIDropDownMenuTemplate")

function MicroMenu:Enable()
	MicroMenu.Buttons = {
		{text = CHARACTER_BUTTON,
		func = function()
			ToggleCharacter("PaperDollFrame")
		end,
		notCheckable = true},

		{text = SPELLBOOK_ABILITIES_BUTTON,
		func = function()
			ShowUIPanel(SpellBookFrame)
		end,
		notCheckable = true},
		
		{text = QUESTLOG_BUTTON,
		func = function()
			ShowUIPanel(QuestLogFrame)
		end,
		notCheckable = true},

		{text = WORLD_MAP,
		func = function()
			ShowUIPanel(WorldMapFrame)
			MaximizeUIPanel(WorldMapFrame)
		end,
		notCheckable = true},

		{text = SOCIAL_BUTTON,
		func = function()
			ToggleFriendsFrame(1)
		end,
		notCheckable = true},
		
		{text = TALENTS,
		func = function()
			ToggleTalentFrame()
		end,
		notCheckable = true},

		{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE.." / "..COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
		func = function()
			--PVEFrame_ToggleFrame()
		end,
		notCheckable = true},

		{text = VOICE,
		func = function()
			ToggleChannelFrame()
		end,
		notCheckable = true},

		{text = RAID,
		func = function()
			ToggleFriendsFrame(4)
		end,
		notCheckable = true},
		
		{text = _G.TIMEMANAGER_TITLE,
    	func = function()
			TimeManagerFrame:SetMovable(true)
			TimeManagerFrame:RegisterForDrag("LeftButton")
			TimeManagerFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
			TimeManagerFrame:SetScript("OnDragStop", WorldMapFrame.StopMovingOrSizing)
			ToggleFrame(TimeManagerFrame)
		end,
		notCheckable = true},

		{text = HELP_BUTTON,
		func = function()
			ToggleHelpFrame()
		end,
		notCheckable = true},
	}
end

Miscellaneous.MicroMenu = MicroMenu

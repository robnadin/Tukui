local T, C, L = select(2, ...):unpack()

local Miscellaneous = T["Miscellaneous"]
local GuildNamesByClassColor = CreateFrame("Frame")

function GuildNamesByClassColor:Update()
	if (FriendsFrame.playerStatusFrame) then
		local Offset = FauxScrollFrame_GetOffset(GuildListScrollFrame)
		
		for i=1, GUILDMEMBERS_TO_DISPLAY, 1 do
			local Index = Offset + i
			local FullName, _, _, _, Class, _, _, _, Online = GetGuildRosterInfo(Index)
			local Button = _G["GuildFrameButton"..i.."Name"]
			
			for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
				if Class == v then
					Class = k
				end
			end

			local R, G, B = unpack(T.Colors.class[Class])
			local Hex = T.RGBToHex(R, G, B)
			
			if Online then
				local Name = Ambiguate(FullName, "guild")
				
				Button:SetText(Hex..Name.."|r")
			end
		end
	end
end

function GuildNamesByClassColor:Enable()
	hooksecurefunc("GuildStatus_Update", self.Update)
end

Miscellaneous.GuildNamesByClassColor = GuildNamesByClassColor
local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local Popups = T["Popups"]
local format = format
local BNGetGameAccountInfo = BNGetGameAccountInfo
local BNGetFriendInfo = BNGetFriendInfo

local OnMouseUp = function(self, btn)
	local Click = btn

	if (Click == "RightButton") then
		-- menu here for invites
	else
		ToggleFriendsFrame(1)
	end
end

local OnEnter = function(self)
	if InCombatLockdown() then
		return
	end
	
	local NumFriends = C_FriendList.GetNumFriends()
	local NumFriendsOnline = C_FriendList.GetNumOnlineFriends()
	local FriendInfo = {}
	
	if NumFriendsOnline == 0 then
		return
	end
	
	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddDoubleLine(FRIENDS, NumFriendsOnline.."/"..NumFriends)
	GameTooltip:AddLine(" ")
	
	for i = 1, NumFriends do
		FriendInfo = C_FriendList.GetFriendInfoByIndex(i)
		
		local Online = FriendInfo.connected

		if Online then
			local Name = FriendInfo.name
			local Level = FriendInfo.level
			local Area = FriendInfo.area
			local Class = string.upper(FriendInfo.className)
			local ClassR, ClassG, ClassB = unpack(T.Colors.class[Class])
			local LevelColor = GetQuestDifficultyColor(Level)
			local FormatedName = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", LevelColor.r*255, LevelColor.g*255, LevelColor.b*255, Level, ClassR*255, ClassG*255, ClassB*255, Name)
			
			GameTooltip:AddDoubleLine(FormatedName, Area)
		end
	end
	
	GameTooltip:Show()
end

local Update = function(self, event)
	local NumOnline = C_FriendList.GetNumOnlineFriends()
	
	self.Text:SetFormattedText("%s %s%s", DataText.NameColor .. FRIENDS .. "|r", DataText.ValueColor, NumOnline)
end

local Enable = function(self)
	self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
	self:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
	self:RegisterEvent("FRIENDLIST_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("IGNORELIST_UPDATE")
	self:RegisterEvent("MUTELIST_UPDATE")
	self:RegisterEvent("PLAYER_FLAGS_CHANGED")
	self:RegisterEvent("BN_FRIEND_LIST_SIZE_CHANGED")
	self:RegisterEvent("BN_FRIEND_INFO_CHANGED")
	self:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
	self:RegisterEvent("BN_FRIEND_INVITE_ADDED")
	self:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
	self:RegisterEvent("BN_BLOCK_LIST_UPDATED")
	self:RegisterEvent("BN_CONNECTED")
	self:RegisterEvent("BN_DISCONNECTED")
	self:RegisterEvent("BN_INFO_CHANGED")
	self:RegisterEvent("BATTLETAG_INVITE_SHOW")
	self:RegisterEvent("PARTY_REFER_A_FRIEND_UPDATED")
	
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnEvent", Update)

	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnMouseUp", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnEvent", nil)
end

DataText:Register(L.DataText.Friends, Enable, Disable, Update)
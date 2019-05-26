local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local Popups = T["Popups"]
local format = format
local BNGetGameAccountInfo = BNGetGameAccountInfo
local BNGetFriendInfo = BNGetFriendInfo

--[[
C_FriendList={
  IsFriend=<function>,
  DelIgnoreByIndex=<function>,
  IsIgnored=<function>,
  SortWho=<function>,
  GetIgnoreName=<function>,
  ShowFriends=<function>,
  GetSelectedIgnore=<function>,
  SetWhoToUi=<function>,
  AddOrRemoveFriend=<function>,
  DelIgnore=<function>,
  AddIgnore=<function>,
  GetFriendInfoByIndex=<function>,
  SendWho=<function>,
  GetSelectedFriend=<function>,
  GetNumIgnores=<function>,
  IsIgnoredByGuid=<function>,
  SetFriendNotes=<function>,
  RemoveFriendByIndex=<function>,
  GetFriendInfo=<function>,
  GetWhoInfo=<function>,
  RemoveFriend=<function>,
  AddOrDelIgnore=<function>,
  GetNumWhoResults=<function>,
  SetFriendNotesByIndex=<function>,
  AddFriend=<function>,
  SetSelectedFriend=<function>,
  SetSelectedIgnore=<function>,
  GetNumFriends=<function>,
  GetNumOnlineFriends=<function>
}
]]

local OnMouseUp = function(self, btn)
	local Click = btn

	if (Click == "RightButton") then
		-- menu here for invites
	else
		ToggleFriendsFrame()
	end
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnEnter = function(self)
	if not InCombatLockdown() then
		return
	end
	
	-- rewrite needed for classic
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
	self:SetScript("OnLeave", OnLeave)
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
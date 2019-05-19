local T, C, L = select(2, ...):unpack()

local WorldMap = CreateFrame("Frame")

function WorldMap:OnUpdate(elapsed)
	if not WorldMapFrame:IsShown() then
		WorldMap.Interval = 0
		
		return
	end
	
	WorldMap.Interval = WorldMap.Interval - elapsed

	if WorldMap.Interval < 0 then
		local UnitMap = C_Map.GetBestMapForUnit("player")
		local X, Y = 0, 0

		if UnitMap then
			local GetPlayerMapPosition = C_Map.GetPlayerMapPosition(UnitMap, "player")

			if GetPlayerMapPosition then
				X, Y = C_Map.GetPlayerMapPosition(UnitMap, "player"):GetXY()
			end
		end

		X = math.floor(100 * X)
		Y = math.floor(100 * Y)

		if X ~= 0 and Y ~= 0 then
			WorldMap.Coords.PlayerText:SetText(PLAYER..":   "..X..", "..Y)
		else
			WorldMap.Coords.PlayerText:SetText(" ")
		end

		WorldMap.Interval = 1
	end
end

function WorldMap:CreateCoords()
	local Map = WorldMapFrame.ScrollContainer.Child
	
	self.Coords = CreateFrame("Frame", nil, WorldMapFrame)
	self.Coords:SetFrameLevel(90)
	self.Coords:FontString("PlayerText", C.Medias.Font, 12, "THINOUTLINE")
	self.Coords.PlayerText:SetTextColor(1, 1, 1)
	self.Coords.PlayerText:SetPoint("BOTTOMLEFT", Map, "BOTTOMLEFT", 5, 5)
	self.Coords.PlayerText:SetText("")
end

function WorldMap:SkinMap()
	local Frame = WorldMapFrame
	local Blackout = Frame.BlackoutFrame
	local Borders = Frame.BorderFrame
	local Map = Frame.ScrollContainer.Child
	local CloseButton = WorldMapFrameCloseButton
	local ContinentButton = WorldMapContinentDropDown
	local ZoneButton = WorldMapZoneDropDown
	local ZoonButton = WorldMapZoomOutButton
	local MagnifyButton = WorldMapMagnifyingGlassButton
	
	Frame:CreateBackdrop()
	Frame.Backdrop:ClearAllPoints()
	Frame.Backdrop:SetAllPoints(Map)
	Frame.Backdrop:CreateShadow()

	Blackout:StripTextures()
	Blackout:EnableMouse(false)
	
	Borders:SetAlpha(0)
	
	ContinentButton:SetParent(T.Panels.Hider)
	
	ZoneButton:SetParent(T.Panels.Hider)
	
	WorldMapZoomOutButton:SetParent(T.Panels.Hider)
	
	MagnifyButton:SetParent(T.Panels.Hider)
	
	CloseButton:ClearAllPoints()
	CloseButton:SetPoint("TOPRIGHT", -10, -72)
	CloseButton:SetFrameStrata("FULLSCREEN")
	CloseButton:SetFrameLevel(Map:GetFrameLevel() + 1)
end

function WorldMap:Enable()
	self.Interval = 1
	self:CreateCoords()
	self:HookScript("OnUpdate", WorldMap.OnUpdate)
	self:SkinMap()
end

T["Maps"].Worldmap = WorldMap

local T, C, L = select(2, ...):unpack()

local DataText = T["DataTexts"]
local tonumber = tonumber
local format = format
local date = date
local Interval = 10
local Timer = 0

local Update = function(self, Elapsed)
	Timer = Timer - Elapsed

	if Timer < 0 then
		self.Text:SetFormattedText("%s", date(DataText.ValueColor .. "%I:%M|r %p"))
		
		Timer = Interval
	end
end

local Enable = function(self)
	self:SetScript("OnUpdate", Update)
end

local Disable = function(self)
	self:SetScript("OnUpdate", nil)
end

DataText:Register(L.DataText.Time, Enable, Disable, Update)

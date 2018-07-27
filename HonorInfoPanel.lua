
HonorInfoPanel = LibStub("AceAddon-3.0"):NewAddon("HonorInfoPanel", "AceConsole-3.0","AceEvent-3.0","AceHook-3.0")

local L = LibStub("AceLocale-3.0"):GetLocale("HonorInfoPanel", true)
local honorThrottle = 1
local honorCounter = 0
local Timer = 0
local PerHour = 0
local Session = 0
local Goal 
local timeToNextHonorLevel = 0 
local current_honor = 0
local max_honor = 0
local current_level = 0
local my_honor_level_max = 0
local character_kills = 0
local update_tooltip = false

--Options Defaults
local defaults = {
    profile = {
	goal = 0,
	goal_alert = true,
	date = date("%m/%d/%y"),
	daily_gain = 0,
	panel_level = true,
	panel_sessionTime = true,
	panel_PerHour = true,
	panel_SessionHonor = true,
	panel_DailyHonor = true,
	panel_TimeToLevel = true,
	panel_Goal = true,
	panel_HonorPoints = true,
	panel_HonorKills = true,
	show_panel = false,
	panel_color = {r =0, g=0, b=0, a=.8},
	panel_border = true,
    },
}

--ACE3 Options
local options = {
	name = "HonorInfoPanel",
	handler = HonorInfoPanel,
	type = "group",
	args = {
		goal = {
			type = "input",
			name = L["OPTIONS_HONOR_GOAL"],
			desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.goal = tonumber(val) or 0; HonorInfoPanel.LDB:Update( ) end,
			get = function(info) return tostring(HonorInfoPanel.db.profile.goal) end,
			order = 1, 
			width = 1.5,
		},
		goal_alert = {
			type = "toggle",
			name = L["OPTIONS_HONOR_GOAL_ALERT"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.goal_alert = val end,
			get = function(info) return HonorInfoPanel.db.profile.goal_alert end,
			order = 1.1, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_header = {
			type = "header",
			name = L["OPTIONS_PANEL_HEADER"],
			order = 1.2, 
		},
		panel_level= {
			type = "toggle",
			name = L["OPTIONS_PANEL_HONORLEVEL"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.panel_level = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_level end,
			order = 2, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_sessionTime= {
			type = "toggle",
			name = L["OPTIONS_PANEL_SESSIONTIME"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,val) HonorInfoPanel.db.profile.panel_sessionTime = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_sessionTime end,
			order = 3, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_HonorKills= {
			type = "toggle",
			name = L["OPTIONS_PANEL_HONORKILLS"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.panel_HonorKills = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_HonorKills end,
			order = 4, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_HonorPoints= {
			type = "toggle",
			name = L["OPTIONS_PANEL_CURRENTHONOR"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,val) HonorInfoPanel.db.profile.panel_HonorPoints = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_HonorPoints end,
			order = 5, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_PerHour= {
			type = "toggle",
			name = L["OPTIONS_PANEL_PERHOUR"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,val) HonorInfoPanel.db.profile.panel_PerHour = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_PerHour end,
			order = 6, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_SessionHonor= {
			type = "toggle",
			name = L["OPTIONS_PANEL_SESSIONHONOR"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,val) HonorInfoPanel.db.profile.panel_SessionHonor = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_SessionHonor end,
			order = 7, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_DailyHonor= {
			type = "toggle",
			name = L["OPTIONS_PANEL_DAILYHONOR"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.panel_DailyHonor = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_DailyHonor end,
			order = 8, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_TimeToLevel= {
			type = "toggle",
			name = L["OPTIONS_PANEL_TIMETOLEVEL"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,val) HonorInfoPanel.db.profile.panel_TimeToLevel = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_TimeToLevel end,
			order = 9, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_Goal= {
			type = "toggle",
			name = L["OPTIONS_PANEL_GOAL"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.panel_Goal = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_Goal end,
			order = 10, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_border= {
			type = "toggle",
			name = L["OPTIONS_PANEL_BORDER"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.panel_border = val; HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_border end,
			order = 11, 
			width = 1.5,
			cmdHidden  = true,
		},
		panel_color= {
			type = "color",
			name = L["OPTIONS_PANEL_COLOR"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			set = function(info,r,g,b,a) HonorInfoPanel.db.profile.panel_color.r = r; HonorInfoPanel.db.profile.panel_color.g = g;HonorInfoPanel.db.profile.panel_color.b = b;HonorInfoPanel.db.profile.panel_color.a = a;HonorInfoPanel:UpdateFrame_Settings() end,
			get = function(info) return HonorInfoPanel.db.profile.panel_color.r,HonorInfoPanel.db.profile.panel_color.g,HonorInfoPanel.db.profile.panel_color.b,HonorInfoPanel.db.profile.panel_color.a;  end,
			hasAlpha = true,
			order = 12, 
			width = 1.5,
			cmdHidden  = true,
		},
		Show = {
			type = "toggle",
			name = L["OPTIONS_PANEL_SHOW"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.show_panel = true; HonorInfoPanel.frame:Show(); end,
			get = function(info) return end,
			--order = 11, 
			--width = 1.5,
			guiHidden = true,
		},
		Hide = {
			type = "toggle",
			name = L["OPTIONS_PANEL_HIDE"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) HonorInfoPanel.db.profile.show_panel = false; HonorInfoPanel.frame:Hide(); end,
			get = function(info) return end,
			--order = 11, 
			--width = 1.5,
			guiHidden = true,
		},
		Options = {
			type = "toggle",
			name = L["OPTIONS_PANEL_HIDE"],
			--desc = L["OPTIONS_HONOR_GOAL_DESCRIPTION"],
			--usage = "<Your message>",
			set = function(info,val) LibStub("AceConfigDialog-3.0"):Open("HonorInfoPanel"); end,
			get = function(info) return end,
			--order = 11, 
			--width = 1.5,
			guiHidden = true,
		},
	},
}

--LDB registration
HonorInfoPanel.LDB = LibStub("LibDataBroker-1.1"):NewDataObject("HonorInfoPanel", {
	type = "data source",
	text = "",
	OnClick = function(self, button, down)
		if (button == "RightButton") then
			LibStub("AceConfigDialog-3.0"):Open("HonorInfoPanel")
		elseif (button == "LeftButton") then
			HonorInfoPanel:ToggleDisplay()	
		end
	end,})


--LDB Functions
function HonorInfoPanel.LDB:OnTooltipShow()
	local Goal = HonorInfoPanel.db.profile.goal
	local daily = HonorInfoPanel.db.profile.daily_gain
	local character_kills = GetPVPLifetimeStats("player")
	local sessionTime = time() - HonorInfoPanel.startSessionTime
	local percent = floor(10000*(current_honor/max_honor)+0.5)/100

	local tooltip = L["HONOR_STATS"].."\n"

	tooltip = tooltip .. L["SESSION_TIME"] .. HonorInfoPanel:SetTextColor(HonorInfoPanel:GetAbbrTimeText(sessionTime)).."\n"
	tooltip = tooltip .. L["TOTAL_KILLS"] .. HonorInfoPanel:SetTextColor(character_kills).."\n"
	tooltip = tooltip .. L["HONOR_POINTS"] .. ": " .. HonorInfoPanel:SetTextColor(current_honor) .. " / " .. HonorInfoPanel:SetTextColor(max_honor) .." ("..HonorInfoPanel:SetTextColor(percent).."%)".."\n"

	if (PerHour ~= nil) then
		tooltip = tooltip .. L["HONOR_PER_HOUR"] .. HonorInfoPanel:SetTextColor(PerHour) .. "\n"
	end

	tooltip = tooltip .. L["SESSION_HONOR"] .. HonorInfoPanel:SetTextColor(Session) .. "\n"
	tooltip = tooltip .. L["DAILY_HONOR"] .. HonorInfoPanel:SetTextColor(daily) .. "\n"
	tooltip = tooltip .. L["TIME_TO_LEVEL"] .. HonorInfoPanel:SetTextColor(timeToNextHonorLevel) .. "\n"

	if (Goal ~= 0 or nil) then
		tooltip = tooltip .. L["GOAL"] .. HonorInfoPanel:SetTextColor(Session).." /"..HonorInfoPanel:SetTextColor(Goal) .. "\n"
	end

	self:AddLine(tooltip)
	self:Show()
end


function HonorInfoPanel.LDB:OnEnter()
	update_tooltip = true
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
	GameTooltip:ClearLines()
	HonorInfoPanel.LDB.OnTooltipShow(GameTooltip)
	GameTooltip:Show()
end


function HonorInfoPanel.LDB:OnLeave()
	update_tooltip = false
	GameTooltip:Hide()
end


function HonorInfoPanel.LDB:Update( )
	HonorInfoPanel.LDB.text = HonorInfoPanel:GetButtonText()
end


--Main Functions
function HonorInfoPanel:OnEnable()
	Goal = self.db.profile.goal
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("HONOR_XP_UPDATE")
	self:HookScript(UIParent, "OnUpdate", "OnUpdate")

	HonorInfoPanel:ResetDailyHonor()

	HonorInfoPanel.LDB.icon = select(1, HonorInfoPanel:SetIcon())
	HonorInfoPanel.LDB.iconCoords = select(2, HonorInfoPanel:SetIcon())
	HonorInfoPanel.LDB:Update( )

	HonorInfoPanel:UpdateFrame_Settings()

	if HonorInfoPanel.db.profile.show_panel then 
		HonorInfoPanel.frame:Show()
	else 
		HonorInfoPanel.frame:Hide()
	end
end


function HonorInfoPanel:PLAYER_ENTERING_WORLD()
	self.startSessionTime = time()
	HonorInfoPanel:UpdateHonor()
	HonorInfoPanel.LDB:Update( )
end


function HonorInfoPanel:HONOR_XP_UPDATE()
	HonorInfoPanel:UpdateProgress()
	HonorInfoPanel:UpdateHonor()
	HonorInfoPanel.LDB:Update( )
end


function HonorInfoPanel:ToggleDisplay()
	if HonorInfoPanel.frame:IsShown() then 
		HonorInfoPanel.db.profile.show_panel = false
		HonorInfoPanel.frame:Hide()
	else
		HonorInfoPanel.db.profile.show_panel = true
		HonorInfoPanel.frame:Show()
	end
end


function HonorInfoPanel:UpdateHonor()
	current_honor = UnitHonor("player")
	max_honor = UnitHonorMax("player")
	current_level = UnitHonorLevel("player")
	my_honor_level_max = 500
end

function HonorInfoPanel:UpdateProgress()

	local honorOld, honorNew, honorDiff, honorMaxOld, honorRemain, honorLevelNew
	local Daily = HonorInfoPanel.db.profile.daily_gain
	local Goal = HonorInfoPanel.db.profile.goal

	honorLevelNew = UnitHonorLevel("player")
	honorOld = current_honor
	honorNew = UnitHonor("player")

	--if the current level isn't what it was:
	if honorLevelNew ~= current_level then
		honorMaxOld = max_honor
		honorRemain = honorMaxOld - honorOld
		honorDiff = honorNew + honorRemain
		--Goal = Goal - honorDiff
	else
		honorDiff = honorNew - honorOld
		--Goal = Goal - honorDiff
	end

	Session = Session + honorDiff
	HonorInfoPanel.db.profile.daily_gain = HonorInfoPanel.db.profile.daily_gain + honorDiff

	if Goal >= 0 then
	--do nothing.
	else
		Goal = 0
	end

	if Session >= Goal and HonorInfoPanel.db.profile.goal_alert then
		PlaySound(878)
	end
end


--Create Function to round the decimals
local function mathround(number, precision)
	precision = precision or 0

	local decimal = string.find(tostring(number), ".", nil, true)

	if ( decimal ) then
		local power = 10 ^ precision

		if ( number >= 0 ) then
			number = math.floor(number * power + 0.5) / power
		else
			number = math.ceil(number * power - 0.5) / power
		end

		-- convert number to string for formatting :M
		number = tostring(number)

		-- set cutoff :M
		local cutoff = number:sub(decimal + 1 + precision)

		-- delete everything after the cutoff :M
		number = number:gsub(cutoff, "")
	else
		-- number is an integer :M
		if ( precision > 0 ) then
			number = tostring(number)

			number = number .. "."

			for i = 1,precision do
				number = number .. "0"
			end
		end
	end

	return number
end


function HonorInfoPanel:ResetDailyHonor()
	local Daily = HonorInfoPanel.db.profile.daily_gain
	local Date = HonorInfoPanel.db.profile.date

	if HonorInfoPanel.db.profile.date ~= date("%m/%d/%y") then
		Daily = 0
	end

	HonorInfoPanel.db.profile.date = date("%m/%d/%y")
end


local function GetTimeParts(s)
	local days = 0
	local hours = 0
	local minutes = 0
	local seconds = 0
	if not s or (s < 0) then
		seconds = L["NA"]
	else
		days = floor(s/24/60/60); s = mod(s, 24*60*60)
		hours = floor(s/60/60); s = mod(s, 60*60)
		minutes = floor(s/60); s = mod(s, 60)
		seconds = s
	end

	return days, hours, minutes, seconds
end


function HonorInfoPanel:GetAbbrTimeText(s)
	local timeText = ""
	local days, hours, minutes, seconds = GetTimeParts(s)

	if seconds == L["NA"] then
		timeText = L["NA"]
	else
		if (days ~= 0) then
			timeText = timeText..format("%d"..L["DAYS_ABBR"].." ", days)
		end
		if (days ~= 0 or hours ~= 0) then
			timeText = timeText..format("%d"..L["HOURS_ABBR"].." ", hours)
		end
		if (days ~= 0 or hours ~= 0 or minutes ~= 0) then
			timeText = timeText..format("%d"..L["MINUTES_ABBR"].." ", minutes)
		end
		timeText = timeText..format("%d"..L["SECONDS_ABBR"], seconds)
	end
	return timeText
end


function HonorInfoPanel:OnUpdate(self, elapsed)
	if (self.totalTime) then
		self.totalTime = self.totalTime + elapsed
		self.levelTime = self.levelTime + elapsed
	end

	honorCounter = honorCounter + elapsed
	Timer = Timer + elapsed
	if honorCounter >= honorThrottle then
		honorCounter = 0
		if (Session ~= 0) then
			PerHour = Session / Timer * 3600
			PerHour = mathround(PerHour, 0)
		end

	    --time to next level
		if (PerHour ~= 0) then
			local tempTimeToNextHonorLevel = (max_honor - current_honor) / PerHour
			timeToNextHonorLevel = HonorInfoPanel:GetAbbrTimeText((max_honor - current_honor) / Session * Timer) --mathround(tempTimeToNextHonorLevel, 2)
		else
			timeToNextHonorLevel = 0
			timeToNextPrestige = 0
		end
	 end

	if update_tooltip then
		GameTooltip:ClearLines()
		HonorInfoPanel.LDB.OnTooltipShow(GameTooltip)
		GameTooltip:Show()
	end
end


function HonorInfoPanel:GetButtonText()
	local Goal = self.db.profile.goal
	local text = "L: " .. HonorInfoPanel:SetTextColor(current_level).." "
	text = text .."H: " .. HonorInfoPanel:SetTextColor(current_honor) .. "/" .. HonorInfoPanel:SetTextColor(max_honor)

	if (Goal ~= 0 or nill) then
		text = text .. " Goal: " .. HonorInfoPanel:SetTextColor(Session).." / "..HonorInfoPanel:SetTextColor(Goal)
	end
	return text
end


function HonorInfoPanel:SetTextColor(text)
	if (text) then
		if (text == 0) then
			return GRAY_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
		else
			return HIGHLIGHT_FONT_COLOR_CODE..text..FONT_COLOR_CODE_CLOSE
		end
	end
end

function HonorInfoPanel:SetIcon()
	local factionGroup = UnitFactionGroup("player")
	local texture = "Interface\\TargetingFrame\\UI-PVP-FFA"
	local coords = {0.046875, 0.609375, 0.03125, 0.59375}

	if (factionGroup == "Horde") then
		texture = "Interface\\TargetingFrame\\UI-PVP-Horde"
		coords = {0.046875, 0.609375, 0.015625, 0.578125}
		elseif (factionGroup == "Alliance") then
		texture ="Interface\\TargetingFrame\\UI-PVP-Alliance"
		coords = {0.046875, 0.609375, 0.03125, 0.59375}
	end

	return  texture, coords
end


function HonorInfoPanel:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("HONOR_INFO_PANEL_SETTINGS", defaults, true)
	LibStub("AceConfig-3.0"):RegisterOptionsTable("HonorInfoPanel", options)
	self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("HonorInfoPanel", "HonorInfoPanel")

	self:RegisterChatCommand("hip", "ChatCommand")
	self:RegisterChatCommand("honor", "ChatCommand")
	HonorInfoPanel.goal = self.db.profile.goal
	Goal = self.db.profile.goal
	CreateDisplayFrame()
end


function HonorInfoPanel:ChatCommand(input)
	local command, rest = input:match("^(%S*)%s*(.-)$");
	if string.lower(command) == 'goal' and string.lower(rest) == "reset" then
		self.db.profile.goal = 0
		print(L["GOAL_RESET"])
	else
		LibStub("AceConfigCmd-3.0"):HandleCommand("hip", "HonorInfoPanel", input)
	end
end


function CreateDisplayFrame()
--Create the Frame
	local frame = CreateFrame("Frame", "HonorInfoPanel_Display", UIParent), {};
	HonorInfoPanel.frame = frame
	frame:SetWidth(235);
	frame:SetHeight(200);
	frame:SetPoint("CENTER", UIParent, "CENTER");
	frame:SetMovable(true);
	frame:EnableMouse(true);
	frame:RegisterForDrag("LeftButton");
	frame:SetScript("OnDragStart", frame.StartMoving);
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
	frame:SetScript("OnUpdate", function(...) HonorInfoPanel:UpdateFrame(...) end)
	frame:SetClampedToScreen(true);
	frame.Title = frame:CreateFontString("HonorInfoPanel_Title", "OVERLAY", "GameFontNormal");
	frame.Title:SetPoint("TOP", 0, -2);
	frame.Title:SetText(L["HONOR_STATS"]);
	frame:SetBackdrop({
	    bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
	    edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
	    tile=false,
	    tileSize=0,
	    edgeSize=10,})
	frame:SetBackdropColor(0,0,0,.8)
	frame:SetBackdropBorderColor(1,1,1,1)
	frame.Spacer = frame:CreateFontString("HonorInfoPanel_Spacer", "OVERLAY", "GameFontNormal");
	frame.Spacer:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -2);
	frame.Spacer:SetText(".")
	frame.Spacer:Hide()
	--Add the text
	frame.SessionTimeText = frame:CreateFontString("HonorInfoPanel_SessionTimeText", "OVERLAY", "GameFontNormal");
	frame.HonorLevelText = frame:CreateFontString("HonorInfoPanel_HonorLevelText", "OVERLAY", "GameFontNormal");
	frame.HonorKills = frame:CreateFontString("HonorInfoPanel_HonorKills", "OVERLAY", "GameFontNormal");
	frame.HonorAmountText = frame:CreateFontString("HonorInfoPanel_HonorAmountText", "OVERLAY", "GameFontNormal");
	frame.HonorGoalText = frame:CreateFontString("HonorInfoPanel_HonorGoalText", "OVERLAY", "GameFontNormal");
	frame.HonorPerHourText = frame:CreateFontString("HonorInfoPanel_HonorPerHourText", "OVERLAY", "GameFontNormal");
	frame.HonorSessionEarnedText = frame:CreateFontString("HonorInfoPanel_HonorSessionEarnedText", "OVERLAY", "GameFontNormal");
	frame.HonorDailyEarnedText = frame:CreateFontString("HonorInfoPanel_HonorDailyEarnedText", "OVERLAY", "GameFontNormal");
	frame.TimeToLevelText = frame:CreateFontString("HonorInfoPanel_TimeToLevelText", "OVERLAY", "GameFontNormal");
	frame.HonorGoalAmountText = frame:CreateFontString("HonorInfoPanel_HonorGoalAmountText", "OVERLAY", "GameFontNormal");

end

function HonorInfoPanel:UpdateFrame(self, elapsed)
	local Goal = HonorInfoPanel.db.profile.goal
	local daily = HonorInfoPanel.db.profile.daily_gain
	local character_kills = GetPVPLifetimeStats("player")
	local sessionTime = time() - HonorInfoPanel.startSessionTime
	local percent = floor(10000*(current_honor/max_honor)+0.5)/100


	if (self.totalTime) then
		self.totalTime = self.totalTime + elapsed
		self.levelTime = self.levelTime + elapsed
	end

	honorCounter = honorCounter + elapsed
	Timer = Timer + elapsed
	if honorCounter >= honorThrottle then
		honorCounter = 0
		if (Session ~= 0) then
			PerHour = Session / Timer * 3600
			PerHour = mathround(PerHour, 0)
		end

	    --time to next level
		if (PerHour ~= 0) then
			local tempTimeToNextHonorLevel = (max_honor - current_honor) / PerHour
			timeToNextHonorLevel = HonorInfoPanel:GetAbbrTimeText((max_honor - current_honor) / Session * Timer) --mathround(tempTimeToNextHonorLevel, 2)
		else
			timeToNextHonorLevel = 0
			timeToNextPrestige = 0
		end
	 end


	HonorInfoPanel.frame.SessionTimeText:SetText(L["SESSION_TIME"] .. HonorInfoPanel:SetTextColor(HonorInfoPanel:GetAbbrTimeText(sessionTime)))
	HonorInfoPanel.frame.HonorLevelText:SetText(L["LEVEL"]..HonorInfoPanel:SetTextColor(current_level))
	HonorInfoPanel.frame.HonorKills:SetText(L["TOTAL_KILLS"] .. HonorInfoPanel:SetTextColor(character_kills));
	HonorInfoPanel.frame.HonorAmountText:SetText(L["HONOR_POINTS"] .. ": " .. HonorInfoPanel:SetTextColor(current_honor) .. " / " .. HonorInfoPanel:SetTextColor(max_honor) .." ("..HonorInfoPanel:SetTextColor(percent).."%)")
	HonorInfoPanel.frame.HonorPerHourText:SetText(L["HONOR_PER_HOUR"] .. HonorInfoPanel:SetTextColor(PerHour));
	HonorInfoPanel.frame.HonorSessionEarnedText:SetText(L["SESSION_HONOR"] .. HonorInfoPanel:SetTextColor(Session));
	HonorInfoPanel.frame.HonorDailyEarnedText:SetText(L["DAILY_HONOR"] .. HonorInfoPanel:SetTextColor(daily));
	HonorInfoPanel.frame.TimeToLevelText:SetText(L["TIME_TO_LEVEL"] .. HonorInfoPanel:SetTextColor(timeToNextHonorLevel));
	HonorInfoPanel.frame.HonorPerHourText:SetText(L["HONOR_PER_HOUR"] .. HonorInfoPanel:SetTextColor(PerHour))
	
	if (Goal ~= 0 or nill) then
		HonorInfoPanel.frame.HonorGoalText:Show()
		HonorInfoPanel.frame.HonorGoalText:SetText(L["GOAL"] .. HonorInfoPanel:SetTextColor(Session).." / "..HonorInfoPanel:SetTextColor(Goal));
	else
		HonorInfoPanel.frame.HonorGoalText:Hide()

	end
end








function HonorInfoPanel:UpdateFrame_Settings()
	local profile = HonorInfoPanel.db.profile
	local frameTable = {}
	local frameIndex = 1

	tinsert(frameTable, HonorInfoPanel_Spacer)

	if profile.panel_level then
		HonorInfoPanel.frame.HonorLevelText:Show()
		HonorInfoPanel.frame.HonorLevelText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorLevelText)
		frameIndex = frameIndex + 1

	else
		HonorInfoPanel.frame.HonorLevelText:Hide()
	end

	if profile.panel_sessionTime then
		HonorInfoPanel.frame.SessionTimeText:Show()
		HonorInfoPanel.frame.SessionTimeText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.SessionTimeText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.SessionTimeText:Hide()
	end

	if profile.panel_HonorKills then
		HonorInfoPanel.frame.HonorKills:Show()
		HonorInfoPanel.frame.HonorKills:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorKills)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorKills:Hide()
	end

	if profile.panel_HonorPoints then
		HonorInfoPanel.frame.HonorAmountText:Show()
		HonorInfoPanel.frame.HonorAmountText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorAmountText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorAmountText:Hide()
	end
	if profile.panel_PerHour then
		HonorInfoPanel.frame.HonorPerHourText:Show()
		HonorInfoPanel.frame.HonorPerHourText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorPerHourText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorPerHourText:Hide()
	end
	if profile.panel_SessionHonor then
		HonorInfoPanel.frame.HonorSessionEarnedText:Show()
		HonorInfoPanel.frame.HonorSessionEarnedText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorSessionEarnedText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorSessionEarnedText:Hide()
	end
	
	if profile.panel_DailyHonor then
		HonorInfoPanel.frame.HonorDailyEarnedText:Show()
		HonorInfoPanel.frame.HonorDailyEarnedText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorDailyEarnedText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorDailyEarnedText:Hide()
	end

	if profile.panel_TimeToLevel then
		HonorInfoPanel.frame.TimeToLevelText:Show()
		HonorInfoPanel.frame.TimeToLevelText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.TimeToLevelText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.TimeToLevelText:Hide()
	end
	if profile.panel_Goal then
		HonorInfoPanel.frame.HonorGoalText:Show()
		HonorInfoPanel.frame.HonorGoalText:SetPoint("TOPLEFT", frameTable[frameIndex], "BOTTOMLEFT")
		tinsert(frameTable, HonorInfoPanel.frame.HonorGoalText)
		frameIndex = frameIndex + 1
	else 
		HonorInfoPanel.frame.HonorGoalText:Hide()
	end

	if profile.panel_border then
		HonorInfoPanel.frame:SetBackdropBorderColor(1,1,1,1)
	else 
		HonorInfoPanel.frame:SetBackdropBorderColor(1,1,1,0)
	end

	HonorInfoPanel.frame:SetHeight(frameIndex*12.95)
	HonorInfoPanel.frame:SetBackdropColor(profile.panel_color.r ,profile.panel_color.g,profile.panel_color.b,profile.panel_color.a)
end
function LoadMicroButtonTextures(self, name)
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:RegisterEvent("UPDATE_BINDINGS");
	local prefix = "Interface\\Buttons\\UI-MicroButton-";
	self:SetNormalTexture(prefix..name.."-Up");
	self:SetPushedTexture(prefix..name.."-Down");
	self:SetDisabledTexture(prefix..name.."-Disabled");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
end

function MicroButtonTooltipText(text, action)
	if ( GetBindingKey(action) ) then
		return text.." "..NORMAL_FONT_COLOR_CODE.."("..GetBindingText(GetBindingKey(action), "KEY_")..")"..FONT_COLOR_CODE_CLOSE;
	else
		return text;
	end
	
end

function UpdateMicroButtons()
	local playerLevel = UnitLevel("player");
	if ( CharacterFrame:IsShown() ) then
		CharacterMicroButton:SetButtonState("PUSHED", 1);
		CharacterMicroButton_SetPushed();
	else
		CharacterMicroButton:SetButtonState("NORMAL");
		CharacterMicroButton_SetNormal();
	end
	
	if ( SpellBookFrame:IsShown() ) then
		SpellbookMicroButton:SetButtonState("PUSHED", 1);
	else
		SpellbookMicroButton:SetButtonState("NORMAL");
	end

	if ( PlayerTalentFrame and PlayerTalentFrame:IsShown() ) then
		TalentMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( playerLevel < TalentMicroButton.minLevel ) then
			TalentMicroButton:Disable();
		else
			TalentMicroButton:Enable();
			TalentMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( QuestLogFrame:IsShown() ) then
		QuestLogMicroButton:SetButtonState("PUSHED", 1);
	else
		QuestLogMicroButton:SetButtonState("NORMAL");
	end
	
	if ( ( GameMenuFrame:IsShown() ) 
		or ( InterfaceOptionsFrame:IsShown()) 
		or ( KeyBindingFrame and KeyBindingFrame:IsShown()) 
		or ( MacroFrame and MacroFrame:IsShown()) ) then
		MainMenuMicroButton:SetButtonState("PUSHED", 1);
		MainMenuMicroButton_SetPushed();
	else
		MainMenuMicroButton:SetButtonState("NORMAL");
		MainMenuMicroButton_SetNormal();
	end

	if ( PVPParentFrame:IsShown() and (not PVPFrame_IsJustBG())) then
		PVPMicroButton:SetButtonState("PUSHED", 1);
		PVPMicroButton_SetPushed();
	else
		if ( playerLevel < PVPMicroButton.minLevel ) then
			PVPMicroButton:Disable();
		else
			PVPMicroButton:Enable();
			PVPMicroButton:SetButtonState("NORMAL");
			PVPMicroButton_SetNormal();
		end
	end
	
	if ( FriendsFrame:IsShown() ) then
		SocialsMicroButton:SetButtonState("PUSHED", 1);
	else
		SocialsMicroButton:SetButtonState("NORMAL");
	end

	if ( LFDParentFrame:IsShown() ) then
		LFDMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( playerLevel < LFDMicroButton.minLevel ) then
			LFDMicroButton:Disable();
		else
			LFDMicroButton:Enable();
			LFDMicroButton:SetButtonState("NORMAL");
		end
	end

	if ( HelpFrame:IsShown() ) then
		HelpMicroButton:SetButtonState("PUSHED", 1);
	else
		HelpMicroButton:SetButtonState("NORMAL");
	end
	
	if ( AchievementFrame and AchievementFrame:IsShown() ) then
		AchievementMicroButton:SetButtonState("PUSHED", 1);
	else
		if ( HasCompletedAnyAchievement() and CanShowAchievementUI() ) then
			AchievementMicroButton:Enable();
			AchievementMicroButton:SetButtonState("NORMAL");
		else
			AchievementMicroButton:Disable();
		end
	end

	-- Paragon microbutton
	if ( UIParagon and UIParagon:IsShown() ) then
		ParagonMicroButton:SetButtonState("PUSHED", 1);
	else
		ParagonMicroButton:Enable();
		ParagonMicroButton:SetButtonState("NORMAL");
	end

	-- Keyring microbutton
	if ( IsBagOpen(KEYRING_CONTAINER) ) then
		KeyRingButton:SetButtonState("PUSHED", 1);
	else
		KeyRingButton:SetButtonState("NORMAL");
	end
end

function AchievementMicroButton_OnEvent(self, event, ...)
	if ( event == "UPDATE_BINDINGS" ) then
		AchievementMicroButton.tooltipText = MicroButtonTooltipText(ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT");
	else
		UpdateMicroButtons();
	end
end

function CharacterMicroButton_OnLoad(self)
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	self.newbieText = NEWBIE_TOOLTIP_CHARACTER;
end

function CharacterMicroButton_OnEvent(self, event, ...)
	if ( event == "UNIT_PORTRAIT_UPDATE" ) then
		local unit = ...;
		if ( unit == "player" ) then
			SetPortraitTexture(MicroButtonPortrait, unit);
		end
		return;
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		SetPortraitTexture(MicroButtonPortrait, "player");
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText = MicroButtonTooltipText(CHARACTER_BUTTON, "TOGGLECHARACTER0");
	end
end

function CharacterMicroButton_SetPushed()
	MicroButtonPortrait:SetTexCoord(0.2666, 0.8666, 0, 0.8333);
	MicroButtonPortrait:SetAlpha(0.5);
end

function CharacterMicroButton_SetNormal()
	MicroButtonPortrait:SetTexCoord(0.2, 0.8, 0.0666, 0.9);
	MicroButtonPortrait:SetAlpha(1.0);
end

function MainMenuMicroButton_SetPushed()
	MainMenuMicroButton:SetButtonState("PUSHED", 1);
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 9, -36);
end

function MainMenuMicroButton_SetNormal()
	MainMenuMicroButton:SetButtonState("NORMAL");
	MainMenuBarPerformanceBar:SetPoint("TOPLEFT", MainMenuMicroButton, "TOPLEFT", 10, -34);
end

--Talent button specific functions
function TalentMicroButton_OnEvent(self, event, ...)
	if ( event == "PLAYER_LEVEL_UP" ) then
		local level = ...;
		UpdateMicroButtons();
		if ( not CharacterFrame:IsShown() and level >= SHOW_TALENT_LEVEL) then
			SetButtonPulse(self, 60, 1);
		end
	elseif ( event == "UNIT_LEVEL" or event == "PLAYER_ENTERING_WORLD" ) then
		UpdateMicroButtons();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self.tooltipText =  MicroButtonTooltipText(TALENTS_BUTTON, "TOGGLETALENTS");
	end
end

--Paragon button specific functions
function ParagonMicroButton_OnLoad(self)
	self:SetNormalTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Up");
	self:SetPushedTexture("Interface\\Buttons\\UI-MicroButtonCharacter-Down");
	self:SetHighlightTexture("Interface\\Buttons\\UI-MicroButton-Hilight");
	self:RegisterEvent("UPDATE_BINDINGS");
end

function ParagonMicroButton_SetPushed()
	ParagonMicroButton:SetButtonState("PUSHED", 1);
end

function ParagonMicroButton_SetNormal()
	ParagonMicroButton:SetButtonState("NORMAL");
end

function ToggleParagonFrame()
	if (UIParagon:IsShown()) then
		UIParagon:Hide();
		ParagonMicroButton_SetNormal();
		if ParagonMicroButton and ParagonMicroButton.Notification then
			ParagonMicroButton.Notification.dismissed = false
		end
		if ParagonMicroButton_UpdateNotification then
			ParagonMicroButton_UpdateNotification()
		end
	else
		UIParagon:Show();
		ParagonMicroButton_SetPushed();
		if ParagonMicroButton.Notification then
			ParagonMicroButton.Notification:Hide()
		end
	end
end

-- Notification badge functions
function ParagonMicroButton_Notification_OnLoad(self)
	self.pulseTimer = 0
	self.dismissed = false  -- Track if user manually dismissed the notification
end

function ParagonMicroButton_Notification_OnUpdate(self, elapsed)
	if self:IsShown() then
		self.pulseTimer = self.pulseTimer + elapsed
		local alpha = 0.5 + (math.sin(self.pulseTimer * 3) * 0.3)  -- Pulse between 0.2 and 0.8
		if self.Glow then
			self.Glow:SetAlpha(alpha)
		end
	end
end

function ParagonMicroButton_Notification_OnClick(self)
	self.dismissed = true
	self:Hide()
	PlaySound("igMainMenuOptionCheckBoxOn")
end

function ParagonMicroButton_Notification_OnEnter(self)
	local Locales = GetLocaleTable and GetLocaleTable() or {}
	local title = Locales.NOTIFICATION_TITLE or "Unspent Paragon Points"
	local message = Locales.NOTIFICATION_MESSAGE or "You have unspent Paragon points!"
	local dismiss = Locales.NOTIFICATION_DISMISS or "Click to dismiss this notification."

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(title, 1.0, 0.82, 0, 1)
	GameTooltip:AddLine(message, 1, 1, 1, 1)
	GameTooltip:AddLine(" ", 1, 1, 1, 1)
	GameTooltip:AddLine(dismiss, 0.5, 0.5, 0.5, 1)
	GameTooltip:Show()
end

-- Update notification visibility based on available points
function ParagonMicroButton_UpdateNotification()
	if not ParagonMicroButton or not ParagonMicroButton.Notification then
		return
	end

	local notification = ParagonMicroButton.Notification

	-- Only show if:
	-- 1. Player has unspent points
	-- 2. Notification was not manually dismissed
	-- 3. Paragon frame is not currently open
	local hasUnspentPoints = ParagonData and ParagonData.availablePoints and ParagonData.availablePoints > 0
	local frameNotOpen = not (UIParagon and UIParagon:IsShown())

	if hasUnspentPoints and not notification.dismissed and frameNotOpen then
		notification:Show()
	else
		notification:Hide()
	end
end

-- Re-enable notification when player gains a level
function ParagonMicroButton_OnLevelUp()
	if ParagonMicroButton and ParagonMicroButton.Notification then
		ParagonMicroButton.Notification.dismissed = false
		ParagonMicroButton_UpdateNotification()
	end
end

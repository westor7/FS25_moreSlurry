-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreSlurryUI = {}

-- Create a meta table to get basic Class-like behavior
local moreSlurryUI_mt = Class(moreSlurryUI)

---Creates the settings UI object
---@return SettingsUI @The new object
function moreSlurryUI.new(settings, debug)
    local self = setmetatable({}, moreSlurryUI_mt)

    self.controls = {}
	self.settings = settings
	self.debug = debug

    return self
end

---Register the UI into the base game UI
function moreSlurryUI:registerSettings()
    -- Get a reference to the base game general settings page
    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
	
	-- Define the UI controls. For each control, a <prefix>_<name>_short and _long key must exist in the i18n values
    local controlProperties = {
        { name = "Multiplier", min = 1.5, max = 50, step = 0.5, autoBind = true, nillable = false }
    }

    UIHelper.createControlsDynamically(settingsPage, "mm_setting_title", self, controlProperties, "mm_")
    UIHelper.setupAutoBindControls(self, self.settings, moreSlurryUI.onSettingsChange)

    -- Apply initial values
    self:updateUiElements()

    -- Update any additional settings whenever the frame gets opened
    InGameMenuSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameOpen, function()
        self:updateUiElements(true) -- We can skip autobind controls here since they are already registered to onFrameOpen
    end)
	
	-- Trigger to update the values when settings frame is closed
	InGameMenuSettingsFrame.onFrameClose = Utils.appendedFunction(InGameMenuSettingsFrame.onFrameClose, function()
		self:onFrameClose();
   	end);

end

function moreSlurryUI:onSettingsChange()
    self:updateUiElements()
end

---Updates the UI elements to reflect the current settings
---@param skipAutoBindControls boolean|nil @True if controls with the autoBind properties shall not be newly populated
function moreSlurryUI:updateUiElements(skipAutoBindControls)
    if not skipAutoBindControls then
        -- Note: This method is created dynamically by UIHelper.setupAutoBindControls
        self.populateAutoBindControls()
    end

	local isAdmin = g_currentMission:getIsServer() or g_currentMission.isMasterUser

	for _, control in ipairs(self.controls) do
		control:setDisabled(not isAdmin)
	end
	
    -- Update the focus manager
    local settingsPage = g_gui.screenControllers[InGameMenu].pageSettings
    settingsPage.generalSettingsLayout:invalidateLayout()
end

function moreSlurryUI:onFrameClose()
	if moreSlurry.settings.Multiplier == moreSlurry.settings.Multiplier_OLD then return	end
	
	moreSlurry.settings.Multiplier_OLD = moreSlurry.settings.Multiplier

	g_currentMission:showBlinkingWarning(g_i18n:getText("mm_blink_warn"), 5000)
end
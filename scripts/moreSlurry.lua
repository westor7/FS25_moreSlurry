-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreSlurry = {}
moreSlurry.settings = {}
moreSlurry.name = g_currentModName or "FS25_moreSlurry"
moreSlurry.version = "1.0.0.0"
moreSlurry.debug = true -- for debugging purposes only
moreSlurry.dir = g_currentModDirectory
moreSlurry.init = false

function moreSlurry.prerequisitesPresent(specializations)
    return true
end

function moreSlurry:loadMap()
	Logging.info("[%s]: Initializing mod v".. moreSlurry.version .. " (c) 2025 by westor.", moreSlurry.name)
	
	if g_dedicatedServer or g_currentMission.missionDynamicInfo.isMultiplayer or not g_server or not g_currentMission:getIsServer() then
		Logging.error("[%s]: Error, Cannot use this mod because this mod is working only for singleplayer!", moreSlurry.name)

		return
    end
	
	InGameMenu.onMenuOpened = Utils.appendedFunction(InGameMenu.onMenuOpened, moreSlurry.initUi)

	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, moreSlurry.saveSettings)
	
	moreSlurry:loadSettings()
end

function moreSlurry:defSettings()
	moreSlurry.settings.Multiplier = 1.5
	moreSlurry.settings.Multiplier_OLD = 1.5
end

function moreSlurry:saveSettings()
	Logging.info("[%s]: Trying to save settings..", moreSlurry.name)

	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileName = "moreSlurry.xml"
	local createXmlFile = modSettingsDir .. "/" .. fileName

	local xmlFile = createXMLFile("moreSlurry", createXmlFile, "moreSlurry")
	
	setXMLFloat(xmlFile, "moreSlurry.slurry#Multiplier",moreSlurry.settings.Multiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	Logging.info("[%s]: Settings have been saved.", moreSlurry.name)
end

function moreSlurry:loadSettings()
	Logging.info("[%s]: Trying to load settings..", moreSlurry.name)
	
	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileName = "moreSlurry.xml"
	local fileNamePath = modSettingsDir .. "/" .. fileName
	
	if fileExists(fileNamePath) then
		Logging.info("[%s]: File founded, loading now the settings..", moreSlurry.name)
		
		local xmlFile = loadXMLFile("moreSlurry", fileNamePath)
		
		if xmlFile == 0 then
			Logging.warning("[%s]: Could not read the data from XML file, maybe the XML file is empty or corrupted, using the default!", moreSlurry.name)
			
			moreSlurry:defSettings()
			
			Logging.info("[%s]: Settings have been loaded.", moreSlurry.name)
			
			return
		end

		local Multiplier = getXMLFloat(xmlFile, "moreSlurry.slurry#Multiplier")

		if Multiplier == nil or Multiplier == 0 then
			Logging.warning("[%s]: Could not parse the correct 'Multiplier' value from the XML file, maybe it is corrupted, using the default!", moreSlurry.name)
			
			Multiplier = 1.5
		end

		if Multiplier < 1.5 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is lower than '1.5' from the XML file or it is corrupted, using the default!", moreSlurry.name)
			
			Multiplier = 1.5
		end
		
		if Multiplier > 50 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is higher than '50' from the XML file or it is corrupted, using the default!", moreSlurry.name)
			
			Multiplier = 1.5
		end
		
		moreSlurry.settings.Multiplier = Multiplier
		moreSlurry.settings.Multiplier_OLD = Multiplier
		
		delete(xmlFile)
					
		Logging.info("[%s]: Settings have been loaded.", moreSlurry.name)
	else
		moreSlurry:defSettings()

		Logging.info("[%s]: NOT any File founded!, using the default settings.", moreSlurry.name)
	end
end

function moreSlurry:initUi()
	if not moreSlurry.init then
		local uiSettingsmoreSlurry = moreSlurryUI.new(moreSlurry.settings,moreSlurry.debug)
		
		uiSettingsmoreSlurry:registerSettings()
		
		moreSlurry.init = true
	end
end

function moreSlurry:updateOutput(of, superFunc, foodFactor, productionFactor, globalProductionFactor)
	if self.isServer then
		local spec = self.spec_husbandryLiquidManure
		local perHour = spec.litersPerHour
	
		if perHour > 0 then
			local liters = perHour * moreSlurry.settings.Multiplier

			if liters > 0 then
				self:addHusbandryFillLevelFromTool(self:getOwnerFarmId(), liters, spec.fillType, nil, nil, nil)
			end

		end
	end

	superFunc(self, foodFactor, productionFactor, globalProductionFactor)
end

PlaceableHusbandryLiquidManure.updateOutput = Utils.overwrittenFunction(PlaceableHusbandryLiquidManure.updateOutput, moreSlurry.updateOutput)

addModEventListener(moreSlurry)
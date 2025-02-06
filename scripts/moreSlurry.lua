-- Author: westor
-- Contact: westor7 @ Discord
--
-- Copyright (c) 2025 westor

moreSlurry = {}
moreSlurry.settings = {}
moreSlurry.name = g_currentModName or "FS25_moreSlurry"
moreSlurry.version = "1.0.1.0"
moreSlurry.dir = g_currentModDirectory
moreSlurry.init = false

function moreSlurry.prerequisitesPresent(specializations)
	return true
end

function moreSlurry:loadMap()
	if g_dedicatedServer or g_currentMission.missionDynamicInfo.isMultiplayer or not g_server or not g_currentMission:getIsServer() then
		Logging.error("[%s]: Error, Cannot use this mod because this mod is working only for singleplayer!", moreSlurry.name)

		return
	end
	
	InGameMenu.onMenuOpened = Utils.appendedFunction(InGameMenu.onMenuOpened, moreSlurry.initUi)

	FSBaseMission.saveSavegame = Utils.appendedFunction(FSBaseMission.saveSavegame, moreSlurry.saveSettings)
end

function moreSlurry:defSettings()
	moreSlurry.settings.Multiplier = 2
	moreSlurry.settings.Multiplier_OLD = 2
end

function moreSlurry:saveSettings()
	Logging.info("[%s]: Trying to save settings..", moreSlurry.name)

	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local createXmlFile = modSettingsDir .. "/" .. "moreSlurry.xml"

	local xmlFile = createXMLFile("moreSlurry", createXmlFile, "moreSlurry")
	
	setXMLFloat(xmlFile, "moreSlurry.slurry#Multiplier",moreSlurry.settings.Multiplier)
	
	saveXMLFile(xmlFile)
	delete(xmlFile)
	
	Logging.info("[%s]: Settings have been saved.", moreSlurry.name)
end

function moreSlurry:loadSettings()
	Logging.info("[%s]: Trying to load settings..", moreSlurry.name)
	
	local modSettingsDir = getUserProfileAppPath() .. "modSettings"
	local fileNamePath = modSettingsDir .. "/" .. "moreSlurry.xml"
	
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
			
			Multiplier = 2
		end

		if Multiplier < 1.5 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is lower than '1.5' from the XML file or it is corrupted, using the default!", moreSlurry.name)
			
			Multiplier = 2
		end
		
		if Multiplier > 100 then
			Logging.warning("[%s]: Could not retrieve the correct 'Multiplier' digital number value because it is higher than '100' from the XML file or it is corrupted, using the default!", moreSlurry.name)
			
			Multiplier = 2
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
		local uiSettingsmoreSlurry = moreSlurryUI.new(moreSlurry.settings)
		
		uiSettingsmoreSlurry:registerSettings()
		
		moreSlurry.init = true
	end
end

function moreSlurry:loadAnimals()
	if not self.isServer then return end

	Logging.info("[%s]: Initializing mod v%s (c) 2025 by westor.", moreSlurry.name, moreSlurry.version)

	moreSlurry:loadSettings()
	moreSlurry:initAllAnimals()
	
	Logging.info("[%s]: End of mod initalization.", moreSlurry.name)
end

function moreSlurry:initAllAnimals()
	local types = { 
		"COW_SWISS_BROWN", 
		"COW_HOLSTEIN", 
		"COW_ANGUS", 
		"COW_LIMOUSIN", 
		"COW_WATERBUFFALO",
		
		"PIG_LANDRACE",
		"PIG_BLACK_PIED",
		"PIG_BERKSHIRE"
	}
	
	moreSlurry.updated = 0
	
	Logging.info("[%s]: Start of animals slurry updates. - Total: %s", moreSlurry.name, table.getn(types))

	moreSlurry:initCows()
	moreSlurry:initPigs()
	
	Logging.info("[%s]: End of animals slurry updates. - Updated: %s - Total: %s", moreSlurry.name, moreSlurry.updated, table.getn(types))
end

function moreSlurry:initCows()
	for _1, subTypeIndex in ipairs(g_currentMission.animalSystem.nameToType["COW"].subTypes) do
		local subType = g_currentMission.animalSystem.subTypes[subTypeIndex]

		if subType.output.liquidManure then
			local animalType = subType.name
			
			moreSlurry.updated = moreSlurry.updated + 1
		
			for _2, output in ipairs(subType.output.liquidManure.keyframes) do
				local amount = output[1]
				local age = output.time
				local newAmount = amount * moreSlurry.settings.Multiplier

				output[1] = newAmount
				
				Logging.info("[%s]: Cow animal slurry amount has been updated. - Animal Type: %s - Age: %s - Old Value: %s - New Value: %s - Multiplier: %s", moreSlurry.name, animalType, age, amount, newAmount, moreSlurry.settings.Multiplier)
			end	

		end
		
	end
end

function moreSlurry:initPigs()
	for _1, subTypeIndex in ipairs(g_currentMission.animalSystem.nameToType["PIG"].subTypes) do
		local subType = g_currentMission.animalSystem.subTypes[subTypeIndex]

		if subType.output.liquidManure then
			local animalType = subType.name
			
			moreSlurry.updated = moreSlurry.updated + 1
		
			for _2, output in ipairs(subType.output.liquidManure.keyframes) do
				local amount = output[1]
				local age = output.time
				local newAmount = amount * moreSlurry.settings.Multiplier

				output[1] = newAmount
				
				Logging.info("[%s]: Pig animal slurry amount has been updated. - Animal Type: %s - Age: %s - Old Value: %s - New Value: %s - Multiplier: %s", moreSlurry.name, animalType, age, amount, newAmount, moreSlurry.settings.Multiplier)
			end	

		end
		
	end
end

AnimalSystem.loadAnimals = Utils.appendedFunction(AnimalSystem.loadAnimals, moreSlurry.loadAnimals)

addModEventListener(moreSlurry)
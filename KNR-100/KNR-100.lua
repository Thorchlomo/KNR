local component = require("component")
local term = require("term")
local event = require("event")


local reactor = component.br_reactor
local gpu = component.gpu


-- Get resolution of the current screen
local w,h = gpu.getResolution()

local lastError = "No error for this time"
local suposedProduction = 200

local function clear()
	term.clear()
end

local function restefg()
	gpu.setForeground(0xffffff)
end

local function eventhandler (eventType)
	print("eventType")
end


event.listen("key_down", eventhandler)

-- Main program
while true do 
	clear()
	
	local stateOfReactor = reactor.getFuelTemperature()
	if stateOfReactor < 200 then
		gpu.setForeground(0x55ff56)
		print("Sous Utilisation !")
	elseif stateOfReactor > 199 and stateOfReactor < 1001 then
		gpu.setForeground(0xFDFF52)
		print("Temperature d'utilisation optimale")
	elseif stateOfReactor > 1000 then
		gpu.setForeground(0xAA0000)
		print("Overheat !")
	else
		gpu.setForeground(0x1100A9)
		print("Error !")
		lastError = "Error 1 : No reactor temperature reacheable"
	end
	gpu.setForeground(0xffffff)
	print("statistiques:")
	print("Fuel Temperature" + br_reactor.getFuelTemperature())
	print("Case Temperature" + br_reactor.getCasingTemperature())
	gpu.fill(1, 4, w, 1, "-")
	local percentOfFuel = br_reactor.getFuelAmountMax() / br_reactor.getFUelAmount()
	local percentOfWaste = br_reactor.getFuelAmountMax() / br_reactor.getWasteAmount()
	print("Amount of fuel (in percent) : " + percentOfFuel)
	print("Amount of waste (in percent) : " + percentOfWaste)
	gpu.setForeground(0xAAAAAA)
	gpu.fill(1, 7, w, 1, "-")
	restefg()
	print("Security information :")
	print("Insertion of " + br_reactor.getControlRodName(0) + " : " + br_reactor.getControlRodLevel())
	gpu.setForeground(0xff5555)
	gpu.fill(1, 10, w, 1, "-")
	restefg()
	print("Energy information :")
	print("Enrgy Stored : " + br_reactor.getEnergyStored())
	print("Energy produced last tick : " + br_reactor.getEnergyProducedLastTick())
	gpu.setForeground(0x0000AA)
	gpu.fill(1, 14, w, 1, "-")
	restefg()
	print("Computing data :")


	local currentHeat = br_reactor.getFuelTemperature()
	local currentProduction = br_reactor.getEnergyProducedLastTick()
	local energyStored = br_reactor.getEnergyStored()
	local currentControlRodLevel = br_reactor.getControlRodLevel(0)

	if currentHeat < 200 
		br_reactor.setAllControlRodLevels(0)
		lastError = "Underheat !"
	end
	if currentHeat > 1000 :
		br_reactor.setAllControlRodLevels(70)
		lastError = "Overheat !"
	end

	if suposedProduction > currentProduction and currentControlRodLevel ~= 0
		br_reactor.setAllControlRodLevels(currentControlRodLevel - 1)
	end
	if suposedProduction < currentProduction and currentControlRodLevel ~= 100
		br_reactor.setAllControlRodLevels(currentControlRodLevel + 1)
	end

	os.sleep(0,1)
end
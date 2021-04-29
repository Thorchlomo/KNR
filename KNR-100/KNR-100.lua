local component = require("component")
local term = require("term")
local event = require("event")


local reactor = component.br_reactor
local gpu = component.gpu
local keyboard = component.keyboard


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

local function eventhandler (opt)
	print(opt)
	if opt == 23 then --I
		if reactor.getActive() == false then
			reactor.setActive(true)
		end
	end
	if opt == 24 then --O
		if reactor.getActive() == true then	
			reactor.setActive(false)
		end
	end
	if opt == 14 then -- backspace
		os.exit()
	end
end



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
	print("Fuel Temperature : " .. reactor.getFuelTemperature())
	print("Case Temperature : " .. reactor.getCasingTemperature())
	gpu.fill(1, 4, w, 1, "-")
	local percentOfFuel = reactor.getFuelAmount() / reactor.getFuelAmountMax() * 100
	local percentOfWaste = reactor.getWasteAmount() / reactor.getFuelAmountMax() * 100
	print("Amount of fuel (in percent) : " .. percentOfFuel)
	print("Amount of waste (in percent) : " .. percentOfWaste)
	gpu.setForeground(0xAAAAAA)
	gpu.fill(1, 7, w, 1, "-")
	restefg()
	print("Security information :")
	print("Insertion of " .. reactor.getControlRodName(0) .. " : " .. reactor.getControlRodLevel(0))
	gpu.setForeground(0xff5555)
	gpu.fill(1, 10, w, 1, "-")
	restefg()
	print("Energy information :")
	print("Enrgy Stored : " .. reactor.getEnergyStored())
	print("Energy produced last tick : " .. reactor.getEnergyProducedLastTick())
	gpu.setForeground(0x0000AA)
	gpu.fill(1, 14, w, 1, "-")
	restefg()
	print("Computing data :")


	local currentHeat = reactor.getFuelTemperature()
	local currentProduction = reactor.getEnergyProducedLastTick()
	local energyStored = reactor.getEnergyStored()
	local currentControlRodLevel = reactor.getControlRodLevel(0)

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

	local event, adress, arg1, arg2, arg3 = event.pull(1)
	if event == "key_down" then
		eventhandler(arg2)
	end
	os.sleep(2)
end
local component = require("component")
local term = require("term")
local event = require("event")


local reactor = component.br_reactor
local turbine = component.br_turbine
local gpu = component.gpu
local keyboard = component.keyboard


-- Get resolution of the current screen
local w,h = gpu.getResolution()

local lastError = "No error for this time"
local suposedProduction = 200	--Change here for the energy you want to produce

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
            turbine.setActive(true)
		end
	end
	if opt == 24 then --O
		if reactor.getActive() == true then	
			reactor.setActive(false)
            turbine.setActive(false)
		end
	end
	if opt == 14 then -- backspace
		os.exit()
	end
end

print("Veuillez entrer la production demandé")
suposedProduction = tonumber(io.read())

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

    local stateOfTurbine = turbine.getRotorSpeed()
    if stateOfTurbine < 200 then
		gpu.setForeground(0x55ff56)
		print("Sous Utilisation !")
	elseif stateOfTurbine > 199 and stateOfTurbine < 1001 then
		gpu.setForeground(0xFDFF52)
		print("Temperature d'utilisation optimale")
	elseif stateOfTurbine > 1000 then
		gpu.setForeground(0xAA0000)
		print("Overheat !")
	else
		gpu.setForeground(0x1100A9)
		print("Error !")
		lastError = "Error 1 : No turbine temperature reacheable"
	end

	gpu.setForeground(0xffffff)
	print("statistiques:")
	print("Fuel Temperature : " .. reactor.getFuelTemperature())
	print("Case Temperature : " .. reactor.getCasingTemperature())
    print("Rotor Speed : " .. turbine.getRotorSpeed())
	gpu.fill(1, 5, w, 1, "-")
	local percentOfFuel = reactor.getFuelAmount() / reactor.getFuelAmountMax() * 100
	local percentOfWaste = reactor.getWasteAmount() / reactor.getFuelAmountMax() * 100
	print("Amount of fuel (in percent) : " .. percentOfFuel)
	print("Amount of waste (in percent) : " .. percentOfWaste)
	gpu.setForeground(0xAAAAAA)
	gpu.fill(1, 8, w, 1, "-")
	restefg()
	print("Security information :")
	print("Insertion of " .. reactor.getControlRodName(0) .. " : " .. reactor.getControlRodLevel(0))
    print("Insertion of " .. reactor.getControlRodName(1) .. " : " .. reactor.getControlRodLevel(1))
    print("Insertion of " .. reactor.getControlRodName(2) .. " : " .. reactor.getControlRodLevel(2))
    print("Insertion of " .. reactor.getControlRodName(3) .. " : " .. reactor.getControlRodLevel(3))
	gpu.setForeground(0xff5555) -- 0 due to turbine
	gpu.fill(1, 14, w, 1, "-")
	restefg()
	print("Energy information :")
	print("Enrgy Stored : " .. turbine.getEnergyStored())
	print("Energy produced last tick : " .. turbine.getEnergyProducedLastTick())
	gpu.setForeground(0x0000AA)
	gpu.fill(1, 18, w, 1, "-")
	restefg()
	print("Computing data :")


	local currentHeat = reactor.getFuelTemperature()
	local currentProduction = turbine.getEnergyProducedLastTick()
	local energyStored = turbine.getEnergyStored()
	local currentControlRodLevel = reactor.getControlRodLevel(0)
    local coilEngaged = turbine.getInductorEngaged()

    --Emergency Stop Zone

	if currentHeat < 200 then
		reactor.setAllControlRodLevels(0)
		lastError = "Underheat !"
        computer.beep(1000)
	end
	if currentHeat > 1000 then
		reactor.setAllControlRodLevels(70)
		lastError = "Overheat !"
        computer.beep(1000, 20)
	end

    if stateOfTurbine < 200 then
        turbine.setInductorEngaged(false)
		lastError = "Under speed !"
        computer.beep(1000)
	end
	if stateOfTurbine > 2000 then
        turbine.setVentAll()
		turbine.setInductorEngaged(true)
		lastError = "Over speed !"
        computer.beep(1000, 20)
	end

	if suposedProduction > currentProduction and currentControlRodLevel ~= 0 then
		reactor.setAllControlRodLevels(currentControlRodLevel - 1)
	end
	if suposedProduction < currentProduction and currentControlRodLevel ~= 100 then
		reactor.setAllControlRodLevels(currentControlRodLevel + 1)
	end

    if currentProduction == 0 and coilEngaged == false then
        turbine.setInductorEngaged(true)
    if stateOfTurbine < 200 and turbine.getFluidFlowRate() == 0 then
        turbine.setVentNone()


	local event, adress, arg1, arg2, arg3 = event.pull(1)
	if event == "key_down" then
		eventhandler(arg2)
	end
	os.sleep(2)
end

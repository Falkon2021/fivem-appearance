local ESX = exports.es_extended:getSharedObject()
	
AddEventHandler('skinchanger:loadDefaultModel', function(male, cb)
	client.setPlayerModel(male and 'mp_m_freemode_01' or 'mp_f_freemode_01')
	if cb then cb() end
end)

AddEventHandler('skinchanger:loadSkin', function(skin, cb)
	if not skin.model then skin.model = 'mp_m_freemode_01' end
	client.setPlayerAppearance(skin)
	if cb then cb() end
end)

AddEventHandler('esx_skin:openSaveableMenu', function(submitCb, cancelCb)
	local config = {
		ped = true,
		headBlend = true,
		faceFeatures = true,
		headOverlays = true,
		components = true,
		props = true
	}
	exports['fivem-appearance']:startPlayerCustomization(function (appearance)
		if (appearance) then
			TriggerServerEvent('fivem-appearance:save', appearance)
			if submitCb then submitCb() end
		else
			if cancelCb then cancelCb() end
		end
	end, config)
end)

RegisterCommand("skin", function()
	ESX.TriggerServerCallback("fivem-appearance:getPlayerGroup", function(gruppo)
		if gruppo ~= "user" then
			TriggerEvent('esx_skin:openSaveableMenu')
		end
	end)
end)

RegisterNetEvent('fivem-appearance:pickNewOutfit', function(data)
    local elements = {}
	
	ESX.TriggerServerCallback('fivem-appearance:getOutfits', function(allMyOutfits)
		for k, v in pairs(allMyOutfits) do
			table.insert(elements, {label = v.name, event = "fivem-appearance:setOutfit", args = {ped = v.ped, components = v.components, props = v.props}})
		end
	end)
	
	Citizen.Wait(500)
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_outfits', {
		title = 'Guardaroba',
		elements = elements
	}, function(data, menu)
			TriggerEvent(data.current.event, data.current.args)
		end, function(data2, menu2)
		ESX.UI.Menu.CloseAll()
	end)
end)

RegisterNetEvent('fivem-appearance:setOutfit')
AddEventHandler('fivem-appearance:setOutfit', function(data)
	local pedModel = data.ped
	local pedComponents = data.components
	local pedProps = data.props
	local playerPed = PlayerPedId()
	local currentPedModel = exports['fivem-appearance']:getPedModel(playerPed)

	if currentPedModel ~= pedModel then
    	exports['fivem-appearance']:setPlayerModel(pedModel)
		Citizen.Wait(500)
		playerPed = PlayerPedId()
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	else
		exports['fivem-appearance']:setPedComponents(playerPed, pedComponents)
		exports['fivem-appearance']:setPedProps(playerPed, pedProps)
		local appearance = exports['fivem-appearance']:getPedAppearance(playerPed)
		TriggerServerEvent('fivem-appearance:save', appearance)
	end
	TriggerEvent('skinchanger:modelLoaded')
end)

function ShowDialog(title, cb)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'dialogo',
                     {title = title}, function(data, menu)
        menu.close()
        cb(data.value)
    end, function(_, menu) menu.close() end, function(_, _) end)
end

RegisterNetEvent('fivem-appearance:saveOutfit', function()
	ShowDialog('Nome Outfit', function(nome_outfit)
		local playerPed = PlayerPedId()
		local pedModel = exports['fivem-appearance']:getPedModel(playerPed)
		local pedComponents = exports['fivem-appearance']:getPedComponents(playerPed)
		local pedProps = exports['fivem-appearance']:getPedProps(playerPed)
		Citizen.Wait(500)
		TriggerServerEvent('fivem-appearance:saveOutfit', nome_outfit, pedModel, pedComponents, pedProps)
	end)
end)

RegisterNetEvent('fivem-appearance:deleteOutfitMenu', function(data)
    local elements = {}
	
	ESX.TriggerServerCallback('getOutfits', function(allMyOutfits)
		for k, v in pairs(allMyOutfits) do
		               
			table.insert(elements, {label = v.name, id = v.id})
		end
	end)
	
	Citizen.Wait(500)
	
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_outfits', {
		title = 'Guardaroba',
		elements = elements
	}, function(data, menu)
			TriggerServerEvent('fivem-appearance:deleteOutfit', data.current.id)
			ESX.UI.Menu.CloseAll()
		end, function(data2, menu2)
		ESX.UI.Menu.CloseAll()
	end)
end)

-----------------------------------------------

Citizen.CreateThread(function()
	for k,v in ipairs(Config.NegozioVestitiPos) do
		local blip = AddBlipForCoord(v)

        SetBlipSprite (blip, 73)
        SetBlipDisplay(blip, 6)
        SetBlipScale  (blip, 0.6)
        SetBlipColour (blip, 47)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Negozio di Vestiti")
        EndTextCommandSetBlipName(blip)
	end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k, v in pairs(Config.NegozioVestitiPos) do
		TriggerEvent('gridsystem:registerMarker', {
			name = 'Vestiti_'.. v.x,
            pos = vector3(v.x, v.y, v.z),
            scale = vector3(1.0, 1.0, 1.0),
			size = vector3(2.0, 2.0, 1.0),
			msg = 'Press ~INPUT_CONTEXT~ to do something',
			control = 'E',
			type = 27,
			shouldBob = true,
			shouldRotate = false,
			color = { r = 130, g = 120, b = 110 },
			action = function()
			 
			end,
			onEnter = function()
				local elements = {}

				table.insert(elements, {label = "Negozio", value = "dio"})
				table.insert(elements, {label = "Guardaroba", value = "porco"})

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Menu_NegozioVestiti', {
					title = 'Negozio di vestiti',
					elements = elements
				}, function(data, menu)
						if data.current.value == "dio" then 
							ESX.UI.Menu.CloseAll()
							local config = {
								ped = false,
								headBlend = false,
								faceFeatures = false,
								headOverlays = false,
								components = true,
								props = true
							}
							exports['fivem-appearance']:startPlayerCustomization(function (appearance)
								if (appearance) then
									TriggerServerEvent('fivem-appearance:save', appearance)
								end
							end, config)
						elseif data.current.value == "porco" then
							local elements = {}
	
							table.insert(elements, {label = "Cambia Outfit", evento = "fivem-appearance:pickNewOutfit"})
							table.insert(elements, {label = "Salva Outfit", evento = "fivem-appearance:saveOutfit"})
							table.insert(elements, {label = "Cancella Outfit", evento = "fivem-appearance:deleteOutfitMenu"})
							
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Menu_NegozioOutfit', {
								title = 'Guardaroba',
								elements = elements
							}, function(data, menu)
									TriggerEvent(data.current.evento)
								end, function(data, menu)
								ESX.UI.Menu.CloseAll()
							end)
						end
					end, function(data2, menu2)
					ESX.UI.Menu.CloseAll()
				end)
            end,
            onexit = function()
                ESX.UI.Menu.CloseAll()
            end,
        })
    end
end)

        --[[TriggerEvent('gridsystem:registerMarker', {
            name = 'Vestiti_'.. v.x,
            pos = vector3(v.x, v.y, v.z),
            scale = vector3(1.0, 1.0, 1.0),
            --shouldRotate = true,
            msg = "[E] Accedi al negozio di vesiti",
            control = 'E',                
            type = 27,
            color = {r = 255, g = 255, b = 255},
            --texture = "marker",
            action = function()]]
				--[[local elements = {}

				table.insert(elements, {label = "Negozio", value = "dio"})
				table.insert(elements, {label = "Guardaroba", value = "porco"})

				ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Menu_NegozioVestiti', {
					title = 'Negozio di vestiti',
					elements = elements
				}, function(data, menu)
						if data.current.value == "dio" then 
							ESX.UI.Menu.CloseAll()
							local config = {
								ped = false,
								headBlend = false,
								faceFeatures = false,
								headOverlays = false,
								components = true,
								props = true
							}
							exports['fivem-appearance']:startPlayerCustomization(function (appearance)
								if (appearance) then
									TriggerServerEvent('fivem-appearance:save', appearance)
								end
							end, config)
						elseif data.current.value == "porco" then
							local elements = {}
	
							table.insert(elements, {label = "Cambia Outfit", evento = "fivem-appearance:pickNewOutfit"})
							table.insert(elements, {label = "Salva Outfit", evento = "fivem-appearance:saveOutfit"})
							table.insert(elements, {label = "Cancella Outfit", evento = "fivem-appearance:deleteOutfitMenu"})
							
							ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'Menu_NegozioOutfit', {
								title = 'Guardaroba',
								elements = elements
							}, function(data, menu)
									TriggerEvent(data.current.evento)
								end, function(data, menu)
								ESX.UI.Menu.CloseAll()
							end)
						end
					end, function(data2, menu2)
					ESX.UI.Menu.CloseAll()
				end)
            end,
            onexit = function()
                ESX.UI.Menu.CloseAll()
            end,
        })
    end
end)]]

Citizen.CreateThread(function()
	for k,v in ipairs(Config.BarbierePos) do
		local blip = AddBlipForCoord(v)

        SetBlipSprite (blip, 71)
        SetBlipDisplay(blip, 6)
        SetBlipScale  (blip, 0.6)
        SetBlipColour (blip, 47)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString("Negozio di Vestiti")
        EndTextCommandSetBlipName(blip)
	end
end)


Citizen.CreateThread(function()
    Citizen.Wait(1000)
    for k, v in pairs(Config.BarbierePos) do
        TriggerEvent('gridsystem:registerMarker', {
			name = 'Barbiere_'.. v.x,
            pos = vector3(v.x, v.y, v.z),
            scale = vector3(1.0, 1.0, 1.0),
			size = vector3(2.0, 2.0, 1.0),
			msg = 'Press ~INPUT_CONTEXT~ per cambiare  look',
			control = 'E',
			type = 27,
			shouldBob = true,
			shouldRotate = false,
			color = { r = 130, g = 120, b = 110 },
			action = function()
			ESX.UI.Menu.CloseAll()
			local config = {
				ped = false,
					headBlend = false,
					faceFeatures = false,
					headOverlays = true,
					components = false,
					props = false
				}
				exports['fivem-appearance']:startPlayerCustomization(function (appearance)
					if (appearance) then
						TriggerServerEvent('fivem-appearance:save', appearance)
					end
				end, config)
            end,
            onexit = function()
                ESX.UI.Menu.CloseAll()
            end,
        })
    end
end)
ESX = nil

local playerped = PlayerId()

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent(Config.EsxDefinition, function(obj) ESX = obj end)
        ESX.TriggerServerCallback('dhz_boutique:GetPoint', function(thepoint)
            point = thepoint
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        ESX.TriggerServerCallback('dhz_boutique:GetPoint', function(thepoint)
            point = thepoint
        end)
    end    
end)

local history = {}
local nom = nil
local prix = nil
local NameVehicle = nil
local vehicle = nil
local PreviewEnCours = false
local PositionOriginalJoueur = nil
local Arme = nil

local MenuBoutique = false
RMenu.Add('dhz_boutique', 'home', RageUI.CreateMenu(Config.NomServeur, "~h~"..Config.NomServeur, 0,0))
RMenu.Add('dhz_boutique', 'info', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'home'), "~h~"..Config.NomServeur, "~h~Information"))
RMenu.Add('dhz_boutique', 'Historique', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'home'), "~h~"..Config.NomServeur, "~h~Historique"))
RMenu.Add('dhz_boutique', 'boutique', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'home'), "~h~"..Config.NomServeur, "~h~Boutique"))
RMenu.Add('dhz_boutique', 'menuvehicule', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'boutique'), "~h~"..Config.NomServeur, "~h~Boutique Véhicule"))
RMenu.Add('dhz_boutique', 'menuarme', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'boutique'), "~h~"..Config.NomServeur, "~h~Boutique arme"))
RMenu.Add('dhz_boutique', 'menuargent', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'boutique'), "~h~"..Config.NomServeur, "~h~Boutique argent"))
RMenu.Add('dhz_boutique', 'preview', RageUI.CreateSubMenu(RMenu:Get('dhz_boutique', 'boutique'), "~h~"..Config.NomServeur, "~h~Prévisualisation"))
RMenu:Get("dhz_boutique", "home").Closed = function()
    MenuBoutique = false
end

function OpenMenuBoutique()
    if MenuBoutique then
        MenuBoutique = false
    else
        MenuBoutique = true
        RageUI.Visible(RMenu:Get('dhz_boutique', 'home'), true)

        Citizen.CreateThread(function()
			while MenuBoutique do
				Wait(0)
				RageUI.IsVisible(RMenu:Get('dhz_boutique', 'home'), true, true, true, function()

                    RageUI.ButtonWithStyle("~h~Boutique", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end, RMenu:Get("dhz_boutique","boutique"))         

                    RageUI.ButtonWithStyle("~h~Information", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end,RMenu:Get("dhz_boutique","info"))    
                    
                    RageUI.ButtonWithStyle("~h~Historique", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end,RMenu:Get("dhz_boutique","Historique"))  

				end, function()
				end)
		
				RageUI.IsVisible(RMenu:Get('dhz_boutique', 'boutique'), true, true, true, function()
		
                    RageUI.Separator("~h~"..Config.NomDesCredits.." : ~r~" .. point)
                    RageUI.Separator("~h~~r~Aucun remboursement ne sera effectué")
                    RageUI.Separator("~h~~r~(voir article 894 du code civil)")
                
                    RageUI.ButtonWithStyle("~h~Véhicule", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end, RMenu:Get("dhz_boutique","menuvehicule"))

                    RageUI.ButtonWithStyle("~h~Armes", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end, RMenu:Get("dhz_boutique","menuarme"))

                    RageUI.ButtonWithStyle("~h~Argent", nil, {}, true,function(h,a,s)
                        if s then
                        end
                    end, RMenu:Get("dhz_boutique","menuargent"))

                    if IsPedSittingInAnyVehicle(PlayerPedId()) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId()), -1) then
                        RageUI.ButtonWithStyle("~h~Customiser son véhicul au max (perf)", nil, { RightLabel = Config.PrixMaxCustom , RightBadge = RageUI.BadgeStyle.Coins}, true,function(h,a,s)
                            if s then
                                ESX.TriggerServerCallback('dhz_boutique:BuyItem', function(callback)
                                    if callback then
                                        local Monvehicule = GetVehiclePedIsIn(PlayerPedId(), false)
                                        SetVehicleMaxMods(Monvehicule)
                                        ESX.ShowNotification('~g~[Action effectué]~s~\nMerci pour votre achat dans la boutique')
                                    else
                                        ESX.ShowNotification("~r~[Action imposible]~s~\nVous n'avez pas assez de points")
                                    end
                                end, 'fullcustom')
                            end
                        end)
                    else
                        RageUI.ButtonWithStyle("~h~Customiser son véhicul au max (perf)", nil, { RightLabel = Config.PrixMaxCustom , RightBadge = RageUI.BadgeStyle.Coins}, false,function(h,a,s)
                            if s then
                            end
                        end)
                    end
            
					
				end, function()
				end)

                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'info'), true, true, true, function()
                    RageUI.Separator("~h~~p~Discord~s~ : ~h~~p~"..Config.Discord)
                    RageUI.Separator("~h~~g~Developpeur~s~ : ~h~~g~DHZ#7843")
                    RageUI.Separator("~h~~o~ID sur le serveur~s~ : ~h~~o~" ..GetPlayerServerId(playerped))
                    RageUI.Separator("~h~~r~Aucun remboursement ne sera effectué")
                    RageUI.Separator("~h~~r~(voir article 894 du code civil)")
				end, function()
				end)

                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'Historique'), true, true, true, function()
                    if (#history > 0) then
                        for i = 1, #history, 1 do
                            RageUI.ButtonWithStyle(history[i].achat, nil, {RightLabel = tostring(history[i].prix), RightBadge = RageUI.BadgeStyle.Coins}, true, function(Hovered, Active, Selected)
                                if (Selected) then
                
                                end
                            end)
                        end
                    else
                        RageUI.Separator("Vous n'avez fais aucun achat")
                    end
				end, function()
				end)


                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'menuargent'), true, true, true, function()

                    RageUI.Separator("~h~"..Config.NomDesCredits.." : ~r~" .. point)
   
                    for k, v in pairs(Config.Argent) do
                        RageUI.ButtonWithStyle("~h~" .. v.name, nil, { RightLabel = v.data.Point , RightBadge = RageUI.BadgeStyle.Coins}, true,function(h,a,s)
                            if s then
                                ESX.TriggerServerCallback('dhz_boutique:BuyItem', function(callback)
                                    if callback then
                                        RageUI.PlaySound("HUD_AWARDS", "FLIGHT_SCHOOL_LESSON_PASSED")
                                        ESX.ShowNotification('~g~[Action effectué]~s~\nMerci pour votre achat dans la boutique')
                                    else
                                        ESX.ShowNotification("~r~[Action imposible]~s~\nVous n'avez pas assez de points")
                                    end
                                end, v.data.Somme)
                            end
                        end)
                    end    
				end, function()
				end)

                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'menuarme'), true, true, true, function()

                    RageUI.Separator("~h~"..Config.NomDesCredits.." : ~r~" .. point)
   
                    for k, v in pairs(Config.Armes) do
                        RageUI.ButtonWithStyle("~h~" .. v.name, nil, { RightLabel = v.data.Point , RightBadge = RageUI.BadgeStyle.Coins}, true,function(h,a,s)
                            if s then
                                ESX.TriggerServerCallback('dhz_boutique:BuyItem', function(callback)
                                    if callback then
                                        RageUI.PlaySound("HUD_AWARDS", "FLIGHT_SCHOOL_LESSON_PASSED")
                                        ESX.ShowNotification('~g~[Action effectué]~s~\nMerci pour votre achat dans la boutique')
                                        RageUI.CloseAll()
                                        MenuBoutique = false
                                    else
                                        ESX.ShowNotification("~r~[Action imposible]~s~\nVous n'avez pas assez de points")
                                    end
                                end, v.data.Preview)
                            end
                        end)
                    end    
				end, function()
				end)

                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'menuvehicule'), true, true, true, function()

                    RageUI.Separator("~h~"..Config.NomDesCredits.." : ~r~" .. point)
   
                    for k, v in pairs(Config.Vehicle) do
                        RageUI.ButtonWithStyle("~h~" .. v.name, nil, { RightLabel = v.data.Point , RightBadge = RageUI.BadgeStyle.Coins}, true,function(h,a,s)
                            if s then
                                nom = v.name
                                prix = v.data.Point
                                NameVehicle = v.data.NameVehicle
                            end
                        end, RMenu:Get("dhz_boutique","preview"))
                    end    
				end, function()
				end)

                RageUI.IsVisible(RMenu:Get('dhz_boutique', 'preview'), true, true, true, function()

                    RageUI.Separator("~h~"..Config.NomDesCredits.." : ~r~" .. point)
                    RageUI.Separator("~h~Véhicule : ~b~"..nom)
                    RageUI.Separator("~h~Prix : ~g~"..prix)
   
                    RageUI.ButtonWithStyle("Acheter", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true,function(h,a,s)
                        if s then
                            ESX.TriggerServerCallback('dhz_boutique:BuyItem', function(callback)
                                if callback then
                                    local pos = GetEntityCoords(GetPlayerPed(PlayerId()))
                                    ESX.Game.SpawnVehicle(NameVehicle, vector3(pos.x + 4, pos.y, pos.z ), nil, function(vehicle)
                                        local newPlate = GeneratePlate()
                                        local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
                                        vehicleProps.plate = newPlate
                                        SetVehicleNumberPlateText(vehicle, newPlate)
                                        TriggerServerEvent('esx_vehicleshop:setVehicleOwned', vehicleProps, getVehicleType(vehicleProps.model))
                                    end)
                                    RageUI.PlaySound("HUD_AWARDS", "FLIGHT_SCHOOL_LESSON_PASSED")
                                    ESX.ShowNotification('~g~[Action effectué]~s~\nMerci pour votre achat dans la boutique')
                                    RageUI.CloseAll()
                                    MenuBoutique = false
                                else
                                    ESX.ShowNotification("~r~[Action imposible]~s~\nVous n'avez pas assez de points")
                                end
                            end, NameVehicle)
                        end
                    end)  
                    
                    RageUI.ButtonWithStyle("Prévisualiser", nil, {RightBadge = RageUI.BadgeStyle.Tick}, true,function(h,a,s)
                        if s then
                            if not PreviewEnCours then
                                PositionOriginalJoueur = GetEntityCoords(PlayerPedId())

                                if not ESX.Game.IsSpawnPointClear(Config.PointPreview, 7.0) then
									ESX.ShowNotification("~r~[Problème]~s~\nQuelqu'un est déjà en prévisualisation")
								else
                                    if DoesEntityExist(vehicle) == false then
                                        RequestModel(GetHashKey(NameVehicle)) 
                                        while not HasModelLoaded(GetHashKey(NameVehicle)) do
                                            Wait(1)
                                        end
                                        SetEntityCoords(PlayerPedId(), Config.PointPreview, false, false, false, true)
                                        vehicle = CreateVehicle(GetHashKey(NameVehicle), Config.PointPreview, false, false) 
                                        FreezeEntityPosition(vehicle, true)
                                        SetEntityInvincible(vehicle, true)
                                        SetEntityCoords(vehicle, Config.PointPreview, false, false, false, true)
                                        SetVehicleDoorsLocked(vehicle, 2)
                                        TaskWarpPedIntoVehicle(PlayerPedId(),  vehicle,  -1)
                                        FreezeEntityPosition(PlayerPedId(),true)
                                        local props = ESX.Game.GetVehicleProperties(vehicle)
                                        props['wheelColor'] = 147
                                        props['plate'] = "EXPO"
                                        ESX.Game.SetVehicleProperties(vehicle, props)
                                        PreviewEnCours = true
                                    end
								end
                            else
                                ESX.ShowNotification("~y~[Anti-Bug]~s~\nVous êtes déjà en prévisualisation")
                            end
                        end
                    end) 
				end, function()
				end)
			end	
		end)			
	end				
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local Pos = Config.PointPreviewPerso
        if PreviewEnCours then
            if #(GetEntityCoords(PlayerPedId()) - Pos) < 7.0 then
                TexteBas('Faites ~g~[E]~s~ pour arrêter la preview',0)
                if IsControlJustPressed(1, 51) then
                    SupprimerVoiture(vehicle)  
                    FreezeEntityPosition(PlayerPedId(),false)
                    SetEntityCoords(PlayerPedId(), PositionOriginalJoueur)
                    PreviewEnCours = false  
                end 
            else
                wait(250)
            end  
        end
    end
end)

RegisterCommand('boutique', function()
    if not MenuBoutique then
        ESX.TriggerServerCallback('Recup:Historique', function(Historique)
            history = Historique
            OpenMenuBoutique()
        end)
    end
end)
RegisterKeyMapping('boutique', 'Menu boutique', 'keyboard', 'F1')


    

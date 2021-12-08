ESX = nil

TriggerEvent(Config.EsxDefinition, function(obj) ESX = obj end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(900000)
        TriggerClientEvent("dCore_2:captionIcon",-1,"Notre boutique propose pas mal de promotions en ce moment alors foncez !","Boutique","top",5000,"blue-9","white",true,"mdi-gift")
    end
end)

ESX.RegisterServerCallback('dhz_boutique:GetPoint', function(source, cb)
    local xPlayer  = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
   MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
        cb(result[1].pointboutique)
    end)
end
end)

ESX.RegisterServerCallback('dhz_boutique:BuyItem', function(source, cb, item)
    local xPlayer  = ESX.GetPlayerFromId(source)

    for k, v in pairs(Config.Vehicle) do
        if item == v.data.NameVehicle then
            MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
                if result[1].pointboutique >= tonumber(v.data.Point) then
                    local newpoint = result[1].pointboutique - tonumber(v.data.Point)
                    MySQL.Async.execute("UPDATE `users` SET `pointboutique`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
                    MySQL.Async.execute('INSERT INTO boutique_historique (identifier,achat,prix) VALUES (@identifier,@achat,@prix)', 
                        { 
                            ['@identifier'] = xPlayer.identifier,
                            ['@achat']    = v.name,
                            ['@prix']     = tonumber(Config.PrixMaxCustom)
                        },
                        function ()
                    end)
                    sendToDisc("[Boutique in-game]", "**[ACHAT]** \n**[NOM]**: "..xPlayer.getName().."\n**[ACHAT]**: "..v.name.."\n**[PRIX]**: "..tonumber(Config.PrixMaxCustom).." points", "Boutique")
                    cb(true)         
                else
                    cb(false)
                end
            end)    
        end  
    end

    for k, v in pairs(Config.Armes) do
        if item == v.data.Preview then
            MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
                if result[1].pointboutique >= tonumber(v.data.Point) then
                    local newpoint = result[1].pointboutique - tonumber(v.data.Point)
                    MySQL.Async.execute("UPDATE `users` SET `pointboutique`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
                    MySQL.Async.execute('INSERT INTO boutique_historique (identifier,achat,prix) VALUES (@identifier,@achat,@prix)', 
                        { 
                            ['@identifier'] = xPlayer.identifier,
                            ['@achat']    = v.name,
                            ['@prix']     = tonumber(Config.PrixMaxCustom)
                        },
                        function ()
                    end)
                    sendToDisc("[Boutique in-game]", "**[ACHAT]** \n**[NOM]**: "..xPlayer.getName().."\n**[ACHAT]**: "..v.name.."\n**[PRIX]**: "..tonumber(Config.PrixMaxCustom).." points", "Boutique")
                    xPlayer.addWeapon(v.data.Preview, 100)
                    cb(true)         
                else
                    cb(false)
                end
            end)    
        end  
    end

    for k, v in pairs(Config.Argent) do
        if item == v.data.Somme then
            MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
                if result[1].pointboutique >= tonumber(v.data.Point) then
                    local newpoint = result[1].pointboutique - tonumber(v.data.Point)
                    MySQL.Async.execute("UPDATE `users` SET `pointboutique`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
                    MySQL.Async.execute('INSERT INTO boutique_historique (identifier,achat,prix) VALUES (@identifier,@achat,@prix)', 
                        { 
                            ['@identifier'] = xPlayer.identifier,
                            ['@achat']    = v.name,
                            ['@prix']     = tonumber(Config.PrixMaxCustom)
                        },
                        function ()
                    end)
                    sendToDisc("[Boutique in-game]", "**[ACHAT]** \n**[NOM]**: "..xPlayer.getName().."\n**[ACHAT]**: "..v.name.."\n**[PRIX]**: "..tonumber(Config.PrixMaxCustom).." points", "Boutique")
                    xPlayer.addAccountMoney("bank", v.data.Somme)
                    cb(true)         
                else
                    cb(false)
                end
            end)    
        end  
    end


    if item == 'fullcustom' then
        MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function (result)
            if result[1].pointboutique >= tonumber(Config.PrixMaxCustom) then
                local newpoint = result[1].pointboutique - tonumber(Config.PrixMaxCustom)
                MySQL.Async.execute("UPDATE `users` SET `pointboutique`= '".. newpoint .."' WHERE `identifier` = '".. xPlayer.identifier .."'", {}, function() end)
                MySQL.Async.execute('INSERT INTO boutique_historique (identifier,achat,prix) VALUES (@identifier,@achat,@prix)', 
                    { 
                        ['@identifier'] = xPlayer.identifier,
                        ['@achat']    = 'Full custom véhicule',
                        ['@prix']     = tonumber(Config.PrixMaxCustom)
                    },
                    function ()
                end)
                sendToDisc("[Boutique in-game]", "**[ACHAT]** \n**[NOM]**: "..xPlayer.getName().."\n**[ACHAT]**: Full custom véhicule\n**[PRIX]**: "..tonumber(Config.PrixMaxCustom).." points", "Boutique")
                cb(true)         
            else
                cb(false)
            end
        end)    
    end  
end)


ESX.RegisterServerCallback('Recup:Historique', function(source, cb)
    local Historique = {}
    local xPlayer  = ESX.GetPlayerFromId(source)
    if xPlayer ~= nil then
        MySQL.Async.fetchAll('SELECT * FROM boutique_historique WHERE identifier = @identifier ', {
            ['@identifier'] = xPlayer.identifier
        }, function(data)
            for k, v in pairs(data) do
                table.insert(Historique, 
                {
                    achat = v.achat, 
                    prix = v.prix
                })
            end
    
            cb(Historique)
        end)
    end
end)

function sendToDisc(title, message, footer)
    local embed = {}
    embed = {
        {
            ["color"] = math.random(111111,999999), 
            ["title"] = "**".. title .."**",
            ["description"] = "" .. message ..  "",
            ["footer"] = {
                ["text"] = footer,
            },
        }
    }
    PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = "Boutique", embeds = embed, avatar_url = "https://i.imgur.com/8Dk93zB.png"}), { ['Content-Type'] = 'application/json' })
end





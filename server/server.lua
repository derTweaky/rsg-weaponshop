local RSGCore = exports['rsg-core']:GetCoreObject()

RegisterServerEvent('rsg-weaponshop:server:weaponshopGetShopItems')
AddEventHandler('rsg-weaponshop:server:weaponshopGetShopItems', function(data)
    local src = source
    MySQL.query('SELECT * FROM weapon_stock WHERE shopid = ?', {data.id}, function(data2)
        MySQL.query('SELECT * FROM weapon_shop WHERE shopid = ?', {data.id}, function(data3)
            TriggerClientEvent('rsg-weaponshop:client:ReturnStoreItems', src, data2, data3)
        end)
    end)
end)

RSGCore.Functions.CreateCallback('rsg-weaponshop:server:weaponshopS', function(source, cb, currentweaponshop)
    exports.oxmysql:execute('SELECT * FROM weapon_shop WHERE shopid = ?', {currentweaponshop}, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-- get weaponsmith stock items
RSGCore.Functions.CreateCallback('rsg-weaponshop:server:weaponsmithStock', function(source, cb, playerjob)
    MySQL.query('SELECT * FROM weaponsmith_stock WHERE weaponsmith = ?', { playerjob }, function(result)
        if result[1] then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

-- refill weaponshop from weaponsmith stock
RegisterServerEvent('rsg-weaponshop:server:weaponshopInvReFill')
AddEventHandler('rsg-weaponshop:server:weaponshopInvReFill', function(location, item, qt, price, job)
    local src = source
    MySQL.query('SELECT * FROM weapon_stock WHERE shopid = ? AND items = ?',{location, item} , function(result)
        if result[1] ~= nil then
            local stockadd = result[1].stock + tonumber(qt)
            MySQL.update('UPDATE weapon_stock SET stock = ?, price = ? WHERE shopid = ? AND items = ?',{stockadd, price, location, item})
        else
            MySQL.insert('INSERT INTO weapon_stock (`shopid`, `items`, `stock`, `price`) VALUES (?, ?, ?, ?);',{location, item, qt, price})
        end
    end)
    MySQL.query('SELECT * FROM weaponsmith_stock WHERE weaponsmith = ? AND item = ?',{job, item} , function(result)
        if result[1] ~= nil then
            local stockremove = result[1].stock - tonumber(qt)
            MySQL.update('UPDATE weaponsmith_stock SET stock = ? WHERE weaponsmith = ? AND item = ?',{stockremove, job, item})
        else
            MySQL.insert('INSERT INTO weaponsmith_stock (`weaponsmith`, `item`, `stock`) VALUES (?, ?, ?);', {job, item, qt})
        end
    end)
    TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_26'), 'success')
end)

RegisterServerEvent('rsg-weaponshop:server:weaponshopPurchaseItem')
AddEventHandler('rsg-weaponshop:server:weaponshopPurchaseItem', function(location, item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    
    exports.oxmysql:execute('SELECT * FROM weapon_stock WHERE shopid = ? AND items = ?',{location, item} , function(data)
        local stock = data[1].stock - amount
        local price = data[1].price * amount   
        local currentMoney = Player.Functions.GetMoney('cash')
        if price <= currentMoney then
            MySQL.Async.execute("UPDATE weapon_stock SET stock=@stock WHERE shopid=@location AND items=@item", {['@stock'] = stock, ['@location'] = location, ['@item'] = item}, function(count)
                if count > 0 then
                    Player.Functions.RemoveMoney("cash", price, "market")
                    Player.Functions.AddItem(item, amount)
                    TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[item], "add")
                    MySQL.Async.fetchAll("SELECT * FROM weapon_shop WHERE shopid=@location", { ['@location'] = location }, function(data2)
                        local moneymarket = data2[1].money + price
                        exports.oxmysql:execute('UPDATE weapon_shop SET money = ? WHERE shopid = ?',{moneymarket, location})
                    end)
                    TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_27').." "..amount.."x "..RSGCore.Shared.Items[item].label, 'success')
                end
            end)
        else 
            TriggerClientEvent('RSGCore:Notify', src, Lang:t('lang_28'), 'error')
        end
    end)
end)

RSGCore.Functions.CreateCallback('rsg-weaponshop:server:weaponshopGetMoney', function(source, cb, currentweaponshop)
    print(currentweaponshop)
    exports.oxmysql:execute('SELECT * FROM weapon_shop WHERE shopid = ?', {currentweaponshop}, function(checkmoney)
        if checkmoney[1] then
            cb(checkmoney[1])
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('rsg-weaponshop:server:weaponshopWithdraw')
AddEventHandler('rsg-weaponshop:server:weaponshopWithdraw', function(location, smoney)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local Playercid = Player.PlayerData.citizenid
    
    exports.oxmysql:execute('SELECT * FROM weapon_shop WHERE shopid = ?',{location} , function(result)
        if result[1] ~= nil then
            if result[1].money >= tonumber(smoney) then
                local nmoney = result[1].money - smoney
                exports.oxmysql:execute('UPDATE weapon_shop SET money = ? WHERE shopid = ?',{nmoney, location})
                Player.Functions.AddMoney('cash', smoney)
            else
                --Notif
            end
        end
    end)
end)

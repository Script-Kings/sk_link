function Debug(message)
    if Link.debug then
        print('^6[sk_link] ^1' .. message)
    end
end

local function DetectAndSetFramework()
    if Link.framework ~= 'auto' then return end

    local frameworks = {
        { 'qbx_core',    'qbox' },
        { 'qb-core',     'qbcore' },
        { 'es_extended', 'esx' },
        { 'ox_core',     'ox' },
    }

    for _, fw in ipairs(frameworks) do
        local resource = fw[1]
        local value = fw[2]

        if GetResourceState(resource) == 'started' then
            Link.framework = value
            Debug('Detected framework: ' .. value)
            return
        end
    end

    print('^6[sk_link] ^1Framework not detected. If you are using a framework, configure it in the config.lua')
    Link.framework = 'none'
end

local function DetectAndSetInventory()
    if Link.inventory ~= 'auto' then return end

    Link.inventory = 'framework'

    local inventories = {
        ['ox_inventory'] = 'ox_inventory',
        ['qs-inventory'] = 'qs-inventory',
        ['ps-inventory'] = 'ps-inventory',
        ['minventory'] = 'codem-inventory',
    }

    for resource, config in pairs(inventories) do
        if GetResourceState(resource) == 'started' then
            Link.inventory = config
            Debug('Detected inventory: ' .. config)
            return
        end
    end
end

DetectAndSetFramework()
DetectAndSetInventory()

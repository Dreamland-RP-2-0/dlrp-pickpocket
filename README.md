# DLRP Pickpocket

A pickpocket script converted from QB-Core to use dlrp_base and dlrp_target frameworks.

## Version

**Version 2.2.0** - Integrated with dlrp_mdt dispatch system

## Description

This script allows players to pickpocket NPCs with a skill-based minigame. It includes:
- Interactive targeting system using dlrp_target
- Skill-based minigame for pickpocketing
- NPC reactions (aggressive, calling police, fleeing)
- Police notification system
- Cooldown system to prevent spam
- Configurable items and chances

## Dependencies

- **dlrp_base** - Core framework (QB-Core bridge compatible)
- **dlrp_target** - Targeting system (ox_target compatible)
- **dlrp_mdt** - MDT and dispatch system
- **dlrp_lib** - Library utilities
- **ox_inventory** - Inventory system
- **oxmysql** - Database

## Installation

1. Ensure all dependencies are installed and started before this resource
2. Place `dlrp_pickpocket` in your `resources/[jobs]/` folder
3. Add `ensure dlrp_pickpocket` to your server.cfg
4. Configure the `config.lua` to your liking
5. Restart your server

## Configuration

All configuration is done in `config.lua`. Key settings include:

### General Settings
- `Config.EnableSkillCheck` - Enable/disable skill check minigame
- `Config.MaxPickpocketAttempts` - Maximum attempts per NPC
- `Config.CooldownTime` - Cooldown between pickpocketing same NPC (ms)
- `Config.RequiredPolice` - Number of police required online

### Difficulty Settings
- `Config.MinigameSpeed` - Speed of the arrow (higher = harder)
- `Config.SuccessPercentage` - Percentage needed to succeed

### Dispatch Integration
The script automatically integrates with dlrp_mdt for police notifications:
- When an NPC calls the police, a dispatch call is created in the MDT
- Police will receive a `10-31 - Pickpocket in Progress` alert
- Alert includes location with street/zone information
- Map blip is automatically created for responding officers
- No additional configuration needed - works out of the box

### NPC Reactions
- `Config.NPCCallPoliceChance` - Chance NPC calls police on fail (0-100)
- `Config.NPCAggressiveChance` - Chance NPC becomes aggressive (0-100)
- `Config.DiscoveryChance` - Chance NPC discovers theft after success (0-100)

### Items
- `Config.EmptyPocketChance` - Chance of empty pockets (0-100)
- `Config.StealableItems` - Table of items that can be stolen with their properties

### Blacklist
- `Config.UseModelBlacklist` - Enable NPC model blacklisting
- `Config.BlacklistedNPCModels` - List of NPC models that cannot be pickpocketed

## Framework Conversion Details

### Changes from QB-Core Version

#### Framework Integration
- **Removed**: QB-Core and ESX framework selection
- **Added**: Direct integration with dlrp_base
- **Benefits**: Single framework, better performance, native QB-Core compatibility

#### Target System
- **Changed from**: qb-target / ox_target selection
- **Changed to**: dlrp_target (ox_target compatible)
- **API Update**: Uses `exports.dlrp_target:addGlobalPed()` with proper structure

#### Notifications
- **Changed from**: Framework-specific notifications
- **Changed to**: ox_lib notify system
- **Format**: 
  ```lua
  lib.notify({
      title = 'Pickpocket',
      description = message,
      type = type
  })
  ```

#### Player Functions
- **Changed from**: `QBCore.Functions.GetPlayer(source)`
- **Changed to**: `exports.dlrp_base:GetPlayer(source)`
- **GetBasePlayers**: `exports.dlrp_base:GetBasePlayers()` returns all online players

#### Inventory
- **Primary**: ox_inventory integration
- **Fallback**: dlrp_base Functions.AddItem/AddMoney for compatibility
- **Money**: Changed from 'cash' item to 'money' item (standard ox_inventory)

#### Animation/Library Functions
- **Changed**: `RequestAnimDict()` → `lib.requestAnimSet()`
- **Benefits**: Better performance, automatic cleanup

### Key Code Changes

#### Client Side
```lua
-- Old QB-Core way
QBCore = exports['qb-core']:GetCoreObject()
QBCore.Functions.Notify(message, type)

-- New dlrp_base way
lib.notify({
    title = 'Pickpocket',
    description = message,
    type = type
})
```

```lua
-- Old target system
exports['qb-target']:AddGlobalPed({...})
-- or
exports.ox_target:addGlobalPed({...})

-- New dlrp_target
exports.dlrp_target:addGlobalPed({
    {
        name = 'pickpocket_npc',
        icon = 'fas fa-hand-paper',
        label = 'Pickpocket',
        onSelect = function(data)
            -- Handle interaction
        end,
        canInteract = function(entity)
            -- Return true/false
        end,
        distance = 1.5
    }
})
```

#### Server Side
```lua
-- Old QB-Core way
QBCore = exports['qb-core']:GetCoreObject()
local Player = QBCore.Functions.GetPlayer(source)
Player.Functions.AddMoney('cash', amount)

-- New dlrp_base way
local Player = exports.dlrp_base:GetPlayer(source)
exports.ox_inventory:AddItem(source, 'money', amount)
```

```lua
-- Old police check
for _, v in pairs(QBCore.Functions.GetPlayers()) do
    local Player = QBCore.Functions.GetPlayer(v)
    if Player.PlayerData.job.name == "police" then
        -- Notify
    end
end

-- New dlrp_base way
local players = exports.dlrp_base:GetBasePlayers()
for source, player in pairs(players) do
    if player.PlayerData.job.name == "police" and player.PlayerData.job.onduty then
        -- Notify
    end
end
```

## Dispatch Integration

The script supports dispatch system integration. To use it:

1. Set `Config.UseDispatch = true` in config.lua
2. Uncomment and configure your dispatch export in client/main.lua (line ~260)

### Supported Dispatch Systems

**ps-dispatch**:
```lua
exports['ps-dispatch']:Pickpocket()
```

**cd_dispatch**:
```lua
local data = exports['cd_dispatch']:GetPlayerInfo()
TriggerServerEvent('cd_dispatch:AddNotification', {
    job_table = {'police'},
    coords = data.coords,
    title = '10-31 - Pickpocket',
    message = 'Someone reported a pickpocket at '..data.street,
    flash = 0,
    unique_id = data.unique_id,
    sound = 1,
    blip = {
        sprite = 225,
        scale = 1.0,
        colour = 1,
        flashes = true,
        text = 'Pickpocket',
        time = 60,
        radius = 0,
    }
})
```

## Features

### Minigame System
- Interactive skill-based minigame
- Configurable difficulty
- Multiple attempts per NPC
- Visual feedback

### NPC Reactions
- **Aggressive**: NPC attacks player with melee weapon
- **Calling Police**: NPC calls police, creates alert
- **Fleeing**: NPC runs away from player
- **Natural Behavior**: NPCs perform realistic scenarios while being pickpocketed

### Police System
- Requires minimum police online (configurable)
- Police notification on theft
- Radius blip for responding officers
- Configurable alert timeout

### Item System
- Multiple item types
- Configurable chances
- Random amounts
- Money and physical items
- Empty pocket chance

## Troubleshooting

### Target system not working
- Ensure dlrp_target is started before dlrp_pickpocket
- Check F8 console for errors
- Verify you're looking at a valid NPC (not player, not vehicle)

### Items not being added
- Verify item names exist in ox_inventory
- Check server console for errors
- Ensure ox_inventory is properly configured

### Notifications not showing
- Ensure ox_lib is installed and working
- Check client console for errors
- Verify lib.notify is available

### Police alerts not working
- Check Config.RequiredPolice setting
- Ensure police job name matches your framework
- Verify police are marked as on-duty

## Credits

- **Original Author**: NaorNC - Discord.gg/NCHub
- **Framework Conversion**: DLRP Development Team
- **Version**: 2.1.0 (dlrp_base)

## Support

For support with the original script: Discord.gg/NCHub
For dlrp_base integration issues: Contact your server's development team

## License

Please refer to the original author's license terms.

## Changelog

### Version 2.1.0 (dlrp_base Conversion)
- Converted from QB-Core to dlrp_base framework
- Integrated dlrp_target for targeting system
- Updated to use ox_lib for notifications
- Changed inventory integration to ox_inventory
- Removed framework selection (ESX/QB)
- Updated player getter functions
- Simplified and modernized codebase
- Added comprehensive documentation

### Version 2.0.0 (Original)
- Initial release by NaorNC
- QB-Core and ESX support
- Minigame system
- NPC reactions
- Police alerts

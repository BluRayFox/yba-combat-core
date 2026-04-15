# yba-combat-core
Yba's Core Combat Re Implementation. WIP!

### THIS IS NOT A YBA SOURCE CODE! ITS JUST MY WAY OF REPEATING YBA'S COMBAT!
It follows the same rules as YBA.


# How to use?
Put Character Controller into ServerStorage Modules or smh

```lua
local CharacterController = require(game.ServerStorage.Modules.Character)

-- PLAYERS
game.Players.PlayerAdded:Connect(function(Player)
	local Controller = CharacterController.New({Player = Player})
	Controller:Activate()
end)

-- MOBS
local TestMob = CharacterController.NewAI({Mob = game.ServerStorage.Mobs.Rig, SpawnPoint =  CFrame.new(0, 15, 0)})
TestMob:ActivateAI()


```
# Where do i put my shiT???
```ClientHandler - Replicated First
Character - Somewhere in ServerStorage Modules folder idk LOOOL```

# yba-combat-core
Yba's Core Combat Re Implementation. WIP!

### THIS IS NOT A YBA SOURCE CODE! ITS JUST MY WAY OF REPEATING YBA'S COMBAT!
It follows the same rules as YBA.


# How to use?
Put Character Controller into ServerStorage Modules or smh

```lua
local CharacterController = require(game.ServerStorage.Modules.Character)

game.Players.PlayerAdded:Connect(function(Player)
	local Controller = CharacterController.new({Player = Player})
	Controller:Activate()
end)
```

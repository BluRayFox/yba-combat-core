local Client = game.Players.LocalPlayer
local ClientFX = require(script.ClientFX)
local UIs = game:GetService('UserInputService')

local RemoteEvent, ClientFXEvent
local Char, Humanoid, Root
local Connections = {}

function connect(event, cb)
	local connection = event:Connect(cb)
	table.insert(Connections, connection)
	return connection
end

function disconnectAll()
	for _, connection in ipairs(Connections) do
		connection:Disconnect()
	end
	
	Connections = {} 
end

Client.CharacterAdded:Connect(function(character)
	disconnectAll()
	
	Char = character
	Humanoid = Char:WaitForChild("Humanoid")
	Root = Char:WaitForChild("HumanoidRootPart")
	
	RemoteEvent = Char:WaitForChild('CharRemoteEvents')
end)


UIs.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	RemoteEvent:FireServer('InputBegan', {KeyCode = input.KeyCode, UserInputType = input.UserInputType})
end)

UIs.InputEnded:Connect(function(input, gpe)
	if gpe then return end
	RemoteEvent:FireServer('InputEnded', {KeyCode = input.KeyCode, UserInputType = input.UserInputType})
end)

ClientFXEvent = game.ReplicatedStorage:WaitForChild('Remotes'):WaitForChild('ClientFX')
ClientFXEvent.OnClientEvent:Connect(function(f, ...)
	ClientFX[f](...)
end)

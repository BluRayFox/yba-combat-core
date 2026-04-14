-- Put inside of ReplicatedFirst
local UIs = game:GetService('UserInputService')
local Client = game.Players.LocalPlayer

local Connections = {}
local RemoteEvent, RemoteFunction
local Character, Humanoid, Root

local function connect(event, cb)
	local connection = event:Connect(cb)
	table.insert(Connections, connection)
	return connection
end

local function disconnectAll()
	for _, connection in Connections do
		connection:Disconnect()
	end
end

Client.CharacterAdded:Connect(function(Character)
	RemoteEvent = Character:WaitForChild('RemoteEvent')
	RemoteFunction = Character:WaitForChild('RemoteFunction')
	
	Character = Client.Character
	Humanoid = Character:WaitForChild('Humanoid')
	Root = Character:WaitForChild('HumanoidRootPart')
	
	RemoteEvent:FireServer('PressedPlay')
	
	connect(Character.Destroying, function()
		disconnectAll()
	end)
	
end)

UIs.InputBegan:Connect(function(Input, GPE)
	if GPE then return end
	RemoteEvent:FireServer('InputBegan', {KeyCode = Input.KeyCode, UserInputType = Input.UserInputType})
end)

UIs.InputEnded:Connect(function(Input, GPE)
	if GPE then return end
	RemoteEvent:FireServer('InputEnded', {KeyCode = Input.KeyCode, UserInputType = Input.UserInputType})
end)

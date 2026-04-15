local Hitbox = {}

function Hitbox.new()
	local self = setmetatable({}, {__index = Hitbox})
	
	self.OnHit = function() end
	self.Size = Vector3.new(1,1,1)
	self.Origin = nil
	self.Offset = CFrame.new(0,0,0)
	self.Visualiser = false
	self.VisualiseTo = 'Everyone' -- or specific player
	self.VList = {}
	
	return self
end

function Hitbox:Cast(IgnoreCharacters)
	IgnoreCharacters = IgnoreCharacters or {}
	
	local Overlap = OverlapParams.new()
	Overlap.FilterType = Enum.RaycastFilterType.Include
	Overlap.FilterDescendantsInstances = {workspace.Alive}
	
	local Characters = {}
	local Parts = workspace:GetPartBoundsInBox(self.Origin.CFrame * self.Offset, self.Size, Overlap)
	
	for _, part in pairs(Parts) do
		if part.Parent:FindFirstChild('Humanoid') and not table.find(Characters, part.Parent) and not table.find(IgnoreCharacters, part.Parent) and not table.find(self.VList, part.Parent) then
			table.insert(Characters, part.Parent)
			table.insert(self.VList, part.Parent)
		end		
	end
	
	if self.Visualiser then
		if self.VisualiseTo == 'Everyone' then
			game.ReplicatedStorage.Remotes.ClientFX:FireAllClients('Hitbox Visualiser', {CFrame = self.Origin.CFrame * self.Offset, Size = self.Size})
		else
			game.ReplicatedStorage.Remotes.ClientFX:FireClient(self.VisualiseTo, 'Hitbox Visualiser', {CFrame = self.Origin.CFrame * self.Offset, Size = self.Size})
		end
	end
	
	return Characters
end

return Hitbox

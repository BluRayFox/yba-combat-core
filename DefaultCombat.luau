local DefaultCombat = {}

DefaultCombat['M1'] = function(self, extra)
	
	local CantAttack = not self['ReturnCanAttack'](self)
	local IsUsingMove = self.UsingMove.IsUsingMove
	
	local Speed = 0.35
	
	if IsUsingMove or CantAttack then return end
	
	local Combo = self.Combat.Combo
	local now = os.clock()
	local lastTick = self.Combat.M1LastTick
	
	if now - lastTick > 1.25 and Combo == 4 then
		Combo = 0
	elseif now - lastTick > 0.75 and Combo < 4 then
		Combo = 0
	end

	Combo += 1
	if Combo > 4 then return end
	
	self['DisableSprint'](self)
	
	if self.Combat.Track then
		self.Combat.Track:Stop()
	end
	
	local Anim = game.ReplicatedStorage.Assets.Anims.DefaultCombat['Combo'..Combo]
	self.Combat.Track = self['LoadAnimation'](self, Anim)
	self.Combat.Track:Play()
	
	self.Combat.M1LastTick = now
	self.Combat.Combo = Combo
	
	self['AddUsingMove'](self, {Name = 'M1', Value = true, Timer = Speed})
	self['AddWalkSpeed'](self, {Name = 'M1', Value = -6, Timer = (Combo < 4 and Speed or Speed + 0.85)})
end

DefaultCombat['M2'] = function(self, extra)

end

return DefaultCombat

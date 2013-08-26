local st = {}

function st:init()
	local grid = anim8.newGrid(24, 40, 96, 40)
	self.anims = {
		stand = anim8.newAnimation(grid('1-2',1), .25),
		walk  = anim8.newAnimation(grid('3-4',1, '1-2',1, '1-2',1), {.25, .1, .25, .25, .25, .25}, function()
			self.signals:emit('stand-still')
		end)
	}

	grid = anim8.newGrid(25, 40, 50, 40)
	self.anims.shoot_left = anim8.newAnimation(grid('1-2',1), {0,.1}, function()
		self.anims.shoot_left:pauseAtStart()
		self.signals:emit('i-shot-other')
	end)
	self.anims.shoot_right = anim8.newAnimation(grid('1-2',1), {math.random()*.4+.4,.1}, function()
		self.anims.shoot_right:pauseAtStart()
		self.signals:emit('other-shot-me')
	end)
end

function st:enter(other, prob_sabotage)
	prob_sabotage = prob_sabotage or 0

	Sound.stream.shadows:play()
	Sound.stream.shadows:setVolume(0)
	local vol = 0
	-- TODO: libify fade in/fade out
	self.sound_timer = Timer.do_for(1, function(dt)
		vol = vol + dt
		Sound.stream.shadows:setVolume(.6 * vol)
	end)

	self.tint = {100,100,100}
	self.tween = Timer.tween(20, self.tint, {210,200,200}, 'linear')

	self.phase = 'stand'
	self.steps_taken = 0
	self.dist = 38
	max_steps = math.random(3,5)

	self.signals = signal.new()
	self.signals:register('stand-still', function()
		self.phase = 'stand'
		self.anims.stand:gotoFrame(1)
		if self.steps_taken >= max_steps then
			Timer.add(.5, function() self.signals:emit('shoot') end)
		else
			Timer.add(.75, function() self.signals:emit('do-step') end)
		end
	end)

	self.signals:register('do-step', function()
		self.anims.walk:gotoFrame(1)
		self.phase = 'walk'
		self.steps_taken = self.steps_taken + 1
		self.dist = self.dist + 12
		Timer.add(.2, function()
			Timer.tween(.2, self, {dist = self.dist + 28}, 'quint')
		end)
	end)

	self.may_shoot = false
	self.signals:register('shoot', function()
		self.phase = 'shoot'
		self.anims.shoot_left:pauseAtStart()
		self.anims.shoot_right:pauseAtStart()
		Timer.add(.5, function() self.may_shoot = true end)
		-- TODO: arten der sabotage?
		if math.random() > prob_sabotage then
			self.anims.shoot_right:resume()
		else
			Sound.static.dudshot:play()
		end
	end)

	self.is_shot = false
	self.signals:register('other-shot-me', function()
		self.is_shot = true
		self.anims.shoot_left:pauseAtStart()
		self.flash = {160,82,81, time = .17}
		Timer.add(.5, function() GS.transition(State.lost_duel, 1) end)
		Sound.static.gunshot:play()
	end)

	self.other_shot = false
	self.signals:register('i-shot-other', function()
		self.other_shot = true
		self.anims.shoot_right:pauseAtStart()
		self.flash = {230, 189, 120, time = .17}
		Timer.add(.5, function() GS.transition(State.won_duel, 1) end)
		Sound.static.gunshot:play()
	end)

	Timer.add(3, function()
		self.signals:emit('stand-still')
	end)
end

function st:leave()
	local t = 1
	Timer.cancel(self.sound_timer)
	Timer.do_for(.5, function(dt)
		t = t - 2 * dt
		Sound.stream.shadows:setVolume(.6 * t)
	end, function()
		Sound.stream.shadows:stop()
	end)
	Timer.cancel(self.tween)
end

function st:update(dt)
	if self.phase == 'shoot' then
		self.anims.shoot_left:update(dt)
		self.anims.shoot_right:update(dt)
	else
		self.anims[self.phase]:update(dt)
	end

	if self.flash then
		self.flash.time = self.flash.time - dt
		if self.flash.time <= 0 then self.flash = nil end
	end
end

function st:draw()
	if self.flash and self.flash.time < .1 then
		love.graphics.setColor(self.flash)
		love.graphics.rectangle('fill', 0,0, WIDTH, HEIGHT)
	else
		love.graphics.setColor(self.tint)
		love.graphics.draw(Images.shootout, 0,0)
	end
	love.graphics.setColor(self.tint)

	if self.phase == 'shoot' then
		self.anims.shoot_left:draw(Images.shoot_anim, 400-self.dist,473+self.dist/28, 0,-4,4, 12,40)
		self.anims.shoot_right:draw(Images.shoot_anim, 400+self.dist,473-self.dist/28, 0,4,4, 12,40)

		if self.may_shoot then
			love.graphics.setColor(226,184,104)
			love.graphics.setFont(Font.slkscr[25])
			love.graphics.printf('SHOOT', 0, HEIGHT - 50, WIDTH, 'center')
		end
	else
		local anim = self.anims[self.phase]
		anim:draw(Images.walk_stand_anim_rtl, 400-self.dist,473+self.dist/28, 0,4,4, 12,40)
		anim:draw(Images.walk_stand_anim_ltr, 400+self.dist,473-self.dist/28, 0,4,4, 12,40)
	end
end

function st:keypressed(key)
	if self.phase == 'shoot' and self.may_shoot and  not (self.is_shot or self.other_shot) then
		self.anims.shoot_left:resume()
	end
end

return st

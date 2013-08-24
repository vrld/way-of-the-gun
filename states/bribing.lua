local st = {}

function st:init()
end

function st:enter()
	-- Sound.stream.bribing:play()
	self.intro = {scale=4, textpos=HEIGHT, bars = 300, dontdie = 0}
	self.timer = Timer.new()
	self.timer:tween(43, self.intro, {scale = .3}, 'out-circ')
	self.timer:tween(43, self.intro, {bars = 0}, 'out-quad')
	self.timer:tween(40, self.intro, {textpos = -800}, 'linear')
	self.timer:add(37, function()
		self.timer:tween(3, self.intro, {dontdie = 255}, 'expo')
	end)

	self.timer:add(45, function() GS.transition(State.bribing, 1) end)
end

function st:leave()
	-- Sound.stream.bribing:stop()
end

function st:update(dt)
	self.timer:update(dt)
end

function st:draw()
end

return st

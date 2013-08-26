local st = {}

function st:init()
	Images.intro_shape:setFilter('linear', 'linear')
end

local introtext = [[They laugh at me.

They laugh at me, and they laugh at you, brother.

This cannot go on, brother.

You know there is only one way, brother, only one way to restore my honour.

Aim is not my strengh, brother, we both know that.

But you are smart and you have other ... resources.

Be my second, brother, and
do whatever you need to.

Just don't let me die, brother.]]

function st:enter()
	Sound.stream.voices_of_the_dead:play()
	Sound.stream.voices_of_the_dead:setVolume(0)
	self.intro = {scale=4, textpos=HEIGHT, bars = 300, dontdie = 0}
	self.timer = Timer.new()
	self.timer:tween(53, self.intro, {scale = .3}, 'out-circ')
	self.timer:tween(53, self.intro, {bars = 0}, 'out-quad')
	self.timer:tween(50, self.intro, {textpos = -880}, 'linear')
	self.timer:add(47, function()
		self.timer:tween(3, self.intro, {dontdie = 255}, 'expo')
	end)

	self.timer:add(55, function() GS.transition(State.bribing, 1) end)

	local t = 0
	self.sound_timer = Timer.do_for(1, function(dt)
		t = t + dt
		Sound.stream.voices_of_the_dead:setVolume(.6 * t)
	end)
end

function st:leave()
	local t = 1
	Timer.cancel(self.sound_timer)
	Timer.do_for(.5, function(dt)
		t = t - 2 * dt
		Sound.stream.voices_of_the_dead:setVolume(.6 * t)
	end, function()
		Sound.stream.voices_of_the_dead:stop()
	end)
end

function st:update(dt)
	self.timer:update(dt)
end

function st:draw()
	love.graphics.setColor(53,26,24)
	love.graphics.draw(Images.gradient, 0,0)

	local w,h = Images.intro_shape:getWidth(), Images.intro_shape:getHeight()
	love.graphics.setColor(150,15,150)
	love.graphics.draw(Images.intro_shape, WIDTH/2, HEIGHT, 0, self.intro.scale, self.intro.scale, w/2,h)

	love.graphics.setColor(0,0,0)
	love.graphics.rectangle('fill', 0,0, WIDTH, self.intro.bars)
	love.graphics.rectangle('fill', 0,HEIGHT-self.intro.bars, WIDTH, self.intro.bars)

	love.graphics.setColor(226,184,104)
	love.graphics.setScissor(0,0,WIDTH,HEIGHT-50)
	love.graphics.setFont(Font.slkscr[42])
	love.graphics.printf(introtext, 0, self.intro.textpos, WIDTH-2, 'center')
	love.graphics.setScissor()

	love.graphics.setColor(226,184,104, self.intro.dontdie)
	love.graphics.setFont(Font.slkscr[50])
	love.graphics.printf('Just. dont. let. me. die.', 0, HEIGHT/2-Font.slkscr[50]:getHeight(), WIDTH-2, 'center')

	love.graphics.setColor(226,184,104,100)
	love.graphics.setFont(Font.slkscr[20])
	love.graphics.printf('Press [space] to skip', 0, HEIGHT-20, WIDTH-2, 'center')
end

function st:keypressed(key)
	if key == ' ' or key == 'return' then
		GS.transition(State.bribing, 1)
	end
end

return st

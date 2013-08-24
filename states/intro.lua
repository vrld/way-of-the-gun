local st = {}

function st:init()
	Images.intro_shape:setFilter('linear', 'linear')
end

local introtext = [[They laugh at you, brother.

They laugh at you, and they laugh at us, brother.

This cannot go on, brother.

You know there is only one way, brother, only one way to restore your honor.

Aim is not your strengh, we both know that.

But you are smart, brother, and you have other ... resources.

Do whatever you need to do.

Just don't die, brother.]]

function st:enter()
	-- Sound.stream.intro:play()
	self.intro = {scale=4, textpos=HEIGHT, bars = 300, dontdie = 0}
	self.timer = Timer.new()
	self.timer:tween(43, self.intro, {scale = .3}, 'out-circ')
	self.timer:tween(43, self.intro, {bars = 0}, 'out-quad')
	self.timer:tween(40, self.intro, {textpos = -880}, 'linear')
	self.timer:add(37, function()
		self.timer:tween(3, self.intro, {dontdie = 255}, 'expo')
	end)

	self.timer:add(45, function() GS.transition(State.bribing, 1) end)
end

function st:leave()
	-- Sound.stream.intro:stop()
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
	love.graphics.printf('Just. dont. die.', 0, HEIGHT/2-Font.slkscr[50]:getHeight(), WIDTH-2, 'center')

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

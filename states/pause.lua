local st = {}

function st:enter(pre)
	self.pre = pre
	self.ignore_keypress = true
	-- TODO: pause all active sounds?
end

function st:leave()
	-- TODO: resume all sounds?
end

function st:draw()
	self.pre:draw()
	love.graphics.setColor(20,16,10,150)
	love.graphics.rectangle('fill', 0,0, WIDTH, HEIGHT)

	love.graphics.setColor(226,184,104)
	love.graphics.setFont(Font.slkscr[42])
	love.graphics.printf('PAUSE', 0, HEIGHT/2-21*3, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[32])
	love.graphics.printf([[[Escape] to quit.
Any other key to resume playing.]], 0, HEIGHT/2, WIDTH, 'center')
end

function st:keypressed(key)
	if self.ignore_keypress then
		self.ignore_keypress = nil
		return
	end

	if key == 'escape' then
		love.event.push('quit')
	else
		GS.pop()
	end
end

return st

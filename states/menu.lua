local st = {}

function st:init()
	Images.gun:setFilter('linear', 'linear')
end

function st:enter()
	-- Sound.stream.menu:play()
	foes_remaining = 10
end

function st:leave()
	-- Sound.stream.menu:stop()
end

function st:update(dt)
end

function st:draw()
	love.graphics.setColor(100,100,100)
	love.graphics.draw(Images.title, 0,0)

	local w,h = Images.gun:getWidth(), Images.gun:getHeight()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Images.gun, WIDTH/2, HEIGHT/2+20, 0, 1.5,1.5, w/2,h/2)

	love.graphics.setColor(226,184,104)
	love.graphics.setFont(Font.slkscr[62])
	love.graphics.printf('WAY OF THE', 0, HEIGHT/2-h*1.2, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[28])
	love.graphics.printf('Press [SPACE] to begin', 0, HEIGHT-40, WIDTH, 'center')

	--love.graphics.setColor(72,53,89)
	--love.graphics.setFont(Font.slkscr[18])
	--love.graphics.printf('vrld presets', 2, 2, WIDTH, 'left')

	--love.graphics.setColor(72,53,89)
	--love.graphics.printf('font by Jason Kotte', 0, 2, WIDTH-2, 'right')
end

function st:keypressed(key)
	if key == ' ' or key == 'return' then
		GS.switch(State.shootout)
		-- TODO: GS.transition(State.story)
	end
end

return st

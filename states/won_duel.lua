local st = {}

function st:init()
	Images.gun:setFilter('linear', 'linear')
end

function st:enter()
	-- Sound.stream.menu:play()
	self.fade = {12,11,14,255}
	Timer.tween(1, self.fade, {[4] = 0}, 'sine')
	foes_remaining = (foes_remaining or 10) - 1
end

function st:leave()
	-- Sound.stream.menu:stop()
end

function st:draw()
	--love.graphics.setColor(76,34,37)
	love.graphics.setColor(199,135,59)
	love.graphics.draw(Images.title, 0,0)

	local w,h = Images.gun:getWidth(), Images.gun:getHeight()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Images.gun, WIDTH/2, HEIGHT/2+20, 0, 1.5,1.5, w/2,h/2)

	love.graphics.setColor(226,184,104)
	love.graphics.setFont(Font.slkscr[32])
	love.graphics.printf('YOU ARE A MASTER OF THE', 0, HEIGHT/2-h*2.2, WIDTH, 'center')
	love.graphics.setFont(Font.slkscr[28])
	if foes_remaining == 0 then
		love.graphics.printf('congratulations, you restored your honor', 0, HEIGHT-40, WIDTH, 'center')
	elseif foes_remaining == 1 then
		love.graphics.printf('overcome one more foe to restore your honor', 0, HEIGHT-40, WIDTH, 'center')
	else
		love.graphics.printf(('overcome %d more foes to restore your honor'):format(foes_remaining), 0, HEIGHT-40, WIDTH, 'center')
	end

	love.graphics.setFont(Font.slkscr[62])
	love.graphics.printf('WAY OF THE', 0, HEIGHT/2-h*1.2, WIDTH, 'center')

	love.graphics.setColor(self.fade)
	love.graphics.rectangle('fill', 0, 0, WIDTH, HEIGHT)
end

function st:keypressed(key)
	if key == ' ' or key == 'return' then
		if foes_remaining > 0 then
			GS.transition(State.bribing, .5)
		else
			GS.transition(State.credits, .5)
		end
	end
end

return st

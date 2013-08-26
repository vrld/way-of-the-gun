local st = {}

function st:init()
	Images.gun:setFilter('linear', 'linear')
end

function st:enter()
	-- Sound.stream.menu:play()
	self.credits = {scroll = 0}
	Timer.tween(40, self.credits, {scroll = -2300}, 'linear', function()
		Timer.add(3, function() GS.transition(State.menu, 2) end)
	end)
end

function st:leave()
	-- Sound.stream.menu:stop()
end

function st:draw()
	--love.graphics.setColor(76,34,37)
	love.graphics.setColor(199,135,59)
	love.graphics.draw(Images.title, 0,0)

	love.graphics.push()
	love.graphics.translate(0, self.credits.scroll)
	local w,h = Images.gun:getWidth(), Images.gun:getHeight()
	love.graphics.setColor(255,255,255)
	love.graphics.draw(Images.gun, WIDTH/2, HEIGHT/2+20, 0, 1.5,1.5, w/2,h/2)

	love.graphics.setColor(226,184,104)
	love.graphics.setFont(Font.slkscr[32])
	love.graphics.printf('YOU ARE A MASTER OF THE', 0, HEIGHT/2-h*2.2, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[28])
	love.graphics.printf('congratulations, you restored our honour', 0, HEIGHT-80, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[35])
	love.graphics.printf('A GAME BY VRLD', 0, HEIGHT+50, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[24])
	love.graphics.printf([[MADE IN 48 HOURS FOR THE 27th LUDUM DARE

-
CAST
-

GUNMAN : MAN IN BLACK
SECOND : YOU

Abe Abelton : HIMSELF
Quentin Qurat : HIMSELF
Ben Bloodboil : HIMSELF
Ronald Robsroy : HIMSELF
Charles Cringecrest : HIMSELF
Samuel Sunspot : HIMSELF
Donald Duffdough : HIMSELF
Travis Thrillseeker : HIMSELF
Eathon Earnsalot : HIMSELF
Uistean Ursupator : HIMSELF
Frederic Fortune : HIMSELF
Vaughan Villian : HIMSELF
Geoffrey Gumblesbottom : HIMSELF
Wiliam Willow : HIMSELF
Harry Hatsworth : HIMSELF
Xavier Xalbrain : HIMSELF
Ian Instigator : HIMSELF
Yeoman Yates : HIMSELF
James Jumblejuggle : HIMSELF
Zaiden Zalman : HIMSELF

-
PRODUCTION
-

SCREENPLAY : MATTHIAS RICHTER
MUSIC : MATTHIAS RICHTER
SOUND EFFECTS : MATTHIAS RICHTER

-
SPECIAL EFFECTS
-

Font silkscreen : Jason Kotte
(kotte.org)

animation support : Enrique Garcia
(github.com/kikito/anim8.lua)


This is a work of fiction. Names, characters, places and incidents either are products of the author’s imagination or are used fictitiously. Any resemblance to actual events or locales or persons, living or dead, is entirely coincidental.
]], 0, HEIGHT+100, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[62])
	love.graphics.printf('WAY OF THE', 0, HEIGHT/2-h*1.2, WIDTH, 'center')

	love.graphics.setFont(Font.slkscr[22])
	love.graphics.printf('made with', 0, 2470, WIDTH, 'center')
	w = Images.love_logo:getWidth()
	love.graphics.draw(Images.love_logo, WIDTH/2, 2470, 0, 1,1, w/2)
	love.graphics.printf('(love2d.org)', 0, 2450+Images.love_logo:getHeight()+2, WIDTH, 'center')

	love.graphics.pop()
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

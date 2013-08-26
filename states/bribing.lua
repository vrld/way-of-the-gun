local st = {}

local gui = require 'Quickie'

local offenders = {
	{name = 'Abe Abelton',            trait = 'inept'},
	{name = 'Ben Bloodboil',          trait = 'choleric'},
	{name = 'Charles Cringecrest',    trait = 'pathetic'},
	{name = 'Donald Duffdough',       trait = 'sloth'},
	{name = 'Eathon Earnsalot',       trait = 'rich'},
	{name = 'Frederic Fortune',       trait = 'very rich'},
	{name = 'Geoffrey Gumblesbottom', trait = 'bastard'},
	{name = 'Harry Hatsworth',        trait = 'ancient nobility'},
	{name = 'Ian Instigator',         trait = 'manipulator'},
	{name = 'James Jumblejuggle',     trait = 'prince charmin'},
}

local seconds = {
	{name = 'Quentin Qurat',          trait = 'also inept'},
	{name = 'Ronald Robsroy',         trait = 'susceptible'},
	{name = 'Samuel Sunspot',         trait = 'fed up'},
	{name = 'Travis Thrillseeker',    trait = 'adventurous'},
	{name = 'Uistean Ursupator',      trait = 'well-read'},
	{name = 'Vaughan Villian',        trait = 'villain'},
	{name = 'Wiliam Willow',          trait = 'egocentric'},
	{name = 'Xavier Xalbrain',        trait = 'honourable'},
	{name = 'Yeoman Yates',           trait = 'loyal'},
	{name = 'Zaiden Zalman',          trait = 'secretly in love'},
}

function st:init()
	gui.core.style.gradient:set(255,255)
	gui.core.style.color.normal   = {bg = {0,0,0,0}, fg = {192,134, 55}, border = {0,0,0,0}}
	gui.core.style.color.hot      = {bg = {0,0,0,0}, fg = {246,204,124}, border = {0,0,0,0}}
	gui.core.style.color.active   = {bg = {0,0,0,0}, fg = {246,204,124}, border = {0,0,0,0}}
	gui.core.style.color.disabled = {bg = {0,0,0,0}, fg = {144,144,144}, border = {0,0,0,0}}

	gui.Separator = function(w)
		local pos, size = gui.group.getRect(w.pos, w.size or {nil,0})
		gui.core.registerDraw(gui.core.generateID(), function()
			love.graphics.setColor(gui.core.style.color.normal.fg)
			love.graphics.line(pos[1], pos[2], pos[1]+size[1], pos[2]+size[2])
		end)
	end

	-- XXX: state persistent settings
	foes_remaining = foes_remaining or 10
	--foes_remaining = 1
	money_available = money_available or 1000

	gui.keyboard.disable()

	self.quads = {}
	for x = 1,5 do
		for y = 1,2 do
			self.quads[(y-1) * 5 + x] = love.graphics.newQuad((x-1)*38, (y-1)*50, 38,50, 190,100)
		end
	end

	Sound.static.char:setVolume(.05)
	self.mute = false
end

function st:fade_in_banter()
	local t = 0
	self.banter = Sound.stream.banter:play()
	self.banter:setVolume(0)
	self.sound_timer = Timer.do_for(5, function(dt)
		t = t + dt / 5
		if not self.mute then
			self.banter:setVolume(.6 * t)
		end
	end)
end

function st:fade_out_banter()
	local t = 1
	Timer.cancel(self.sound_timer or {})
	Timer.do_for(1, function(dt)
		t = t - dt
		if not self.mute then
			Sound.stream.banter:setVolume(.6*t)
		end
	end, function()
		Sound.stream.banter:stop()
	end)
end

function st:enter()
	love.graphics.setLineStyle('rough')
	love.graphics.setLineWidth(2)

	self:fade_in_banter()

	self.intro = {scale=4, textpos=HEIGHT, bars = 300, dontdie = 0}
	self.timer = Timer.new()
	self.foe = 11 - foes_remaining

	local function check_for_money(amount, clear, i)
		if amount > money_available then
			self.fulltext = [[You don't have enough money to do that]]
			return false
		end
		money_available = money_available - amount
		if clear then
			while #clear > 0 do table.remove(clear, #clear) end
		end
		return true
	end

	money_available = money_available + ({
		0,
		10,
		20,
		50,
		100,
		1000,
		5000,
		500,
		10000,
		1000,
	})[self.foe]

	self.has_soul = true
	self.can = {talk = true, bribe = true, hire = true}
	self.prob_sabotage = ({
		.9,
		.7,
		.6,
		.5,
		.4,
		.3,
		.2,
		.2,
		.1,
		.0,
	})[self.foe]
	self.state = 'nothing'
	self.dialog = {
		{ -- Quentin Qurat - also inept
			talk = {
				{text = 'puffy cheeks', effect = function(opts, i)
					self.fulltext = [[You:
So, what are you eating?

Quentin:
Nothing. Why? Do you have something to chew?]]
				end},
				{text = 'about abe', effect = function(opts, i)
					self.fulltext = [[You:
How do you like Abe?

Quentin:
I like him. He is the only one that doesn't say I'm stupid.]]
				end},
				{text = 'manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Do you already have the new splosion max gunpowder? It's now the only officially sanctioned duel gunpowder.

Quentin:
Bollux, no. Can you lend me some?

You:
Sure! [You hand him a bag of black pepper.]]
					self.prob_sabotage = 1
				end},
			},
			bribe = {
				{text = 'Give 1', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Abe, would we? [wink]

Quentin: [Takes the money]
Thanks! But what does that have to to with abe?]]

					check_for_money(1)
				end},
				{text = 'Give 10', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Abe, would we? [wink]

Quentin: [Takes the money]
Thanks! But what does that have to to with abe?]]
					check_for_money(10)
				end},
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Abe, would we? [wink]

Quentin: [Takes the money]
YIKES! Thanks! But what does that have to to with abe?]]
					check_for_money(100)
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Abe, would we? [wink]

Quentin: [Takes the money]
YOINK! Thanks! But what does that have to to with abe?]]
					check_for_money(1000)
				end},
			},
			hire = {
				{text = 'Drunkard for 10', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Quentin drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! Apparantly Quentin can outdrink anybody.]]
					check_for_money(10)
				end},
				{text = 'prostitute for 50', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract Abe while you manipulate the gun.

It Works! You exchange the gunpowder with black pepper.]]
					if check_for_money(50) then
						self.prob_sabotage = 1
					end
				end},
				{text = 'Goon Squad for 100', effect = function(opts, i)
					self.fulltext = [[You hire a goon squad to beat up Quentin.

It doesn't work! They say dont hit idiots.]]
					check_for_money(100)
				end},
			},
		}, { -- Ronald Robsroy - susceptible
------------------------------------------------------------------------------------
			talk = {
				{text = 'sideburns', effect = function(opts, i)
					self.fulltext = [[You:
Nice sideburns.

Ronald:
Thanks.]]
				end},
				{text = 'About ben', effect = function(opts, i)
					self.fulltext = [[You:
How is working with ben?

Ronald:
He's an ass. And he doesn't pay well. But I have nowhere else to go.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Do you already have the new splosion max gunpowder? It's now the only officially sanctioned duel gunpowder.

Ronald:
I'm not an iditot. There is no such thing.]]
				end},
			},
			bribe = {
				{text = 'Give 1', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Ben, would we? [wink]

Ronald:
I find this amount rather insulting.]]
				end},
				{text = 'Give 10', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Ben, would we? [wink]

Ronald:
We would. But I'm not *that* cheap.]]
				end},
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Ben, would we? [wink]

Ronald: [takes the money]
Now *that* would be a real tragedy.]]
					if check_for_money(100, opts) then
						self.prob_sabotage = .95
					end
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Ben, would we? [wink]

Ronald: [takes the money, nods.] ]]
					if check_for_money(1000, opts) then
						self.prob_sabotage = 1
					end
				end},
			},
			hire = {
				{text = 'Drunkard for 10', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Ronald drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! Ronald doesn't drink.]]
					check_for_money(10)
				end},
				{text = 'prostitute for 50', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract Ronald while you manipulate the gun.

It doesn't work! Ronald finished too quickly.]]
					check_for_money(50)
				end},
				{text = 'Goon Squad for 100', effect = function(opts, i)
					self.fulltext = [[You hire a goon squad to beat up Ronald.

It doesn't work! Ronald is used to the clobbering.]]
					check_for_money(100)
				end},
			}
		}, { -- Samuel Sunspot - fed up
------------------------------------------------------------------------------------
			talk = {
				{text = 'Angry look', effect = function(opts, i)
					self.fulltext = [[You:
You should lighten up a little.

Samuel:
Shut up. Idiot.

You:
Uh, sorry...?]]
				end},
				{text = 'About charles', effect = function(opts, i)
					self.fulltext = [[You:
Do you like charles?

Samuel:
He's pathetic. Everybody knows. It even says so on the top of the screen.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Any chance you will help my brother win tomorrow?

Samuel:
Go figure.]]
				end},
			},
			hire = {
				{text = 'Drunkard for 50', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Samuel drunk so you can manipulate the gun while he sleeps it off.

It works! Samuel is flat out.]]
					if check_for_money(50, opts) then
						self.prob_sabotage = 1
					end
				end},
				{text = 'prostitute for 100', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract Samuel while you manipulate the gun.

It doesn't work! Samuel spits at the prostitute.]]
					check_for_money(100)
				end},
				{text = 'Goon Squad for 250', effect = function(opts, i)
					self.fulltext = [[You hire a goon squad to beat up Samuel.

It doesn't work! Samuel whoops their asses.]]
					check_for_money(250)
				end},
			},
			bribe = {
				{text = 'Give 1', effect = function(opts, i)
					self.fulltext = [[You:
Here, to end your troubles with charles.

Samuel:
Is this some kind of joke?]]
				end},
				{text = 'Give 10', effect = function(opts, i)
					self.fulltext = [[You:
Here, to end your troubles with charles.

Samuel:
You better leave.]]
				end},
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
Here, to end your troubles with charles.

Samuel: [takes the money]
We'll  see.]]
					if check_for_money(100, opts) and math.random() < .5 then
						self.prob_sabotage = math.max(self.prob_sabotage, math.random() * .3 + .3)
					end
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
Here, to end your troubles with charles.

Samuel: [takes the money]
This will certainly help.]]
					if check_for_money(1000, opts) then
						self.prob_sabotage = math.max(self.prob_sabotage, math.random() * .2 + .8)
					end
				end},
			}
		}, { -- Travis Thrillseeker - adventurous
------------------------------------------------------------------------------------
			talk = {
				{text = 'Look', effect = function(opts, i)
					self.fulltext = [[You:
I've got nothing.

Travis:
Pardon?]]
				end},
				{text = 'About Donald', effect = function(opts, i)
					self.fulltext = [[You:
How much do you like donald?

Travis:
He's a nice guy, but kind of a sloth. He never goes on an adventure with me.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Any chance we could 'enhance' the chances of my brother not dying tommorow?

Travis:
Well, there is this trip to africa i'd like to take. but donald always says it's too expensive... if you know what i mean]]
				end},
			},
			hire = {
				{text = 'Drunkard for 50', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Travis drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! travis doesn't drink.]]
				end},
				{text = 'prostitute for 100', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract travis while you manipulate the gun.

It doesn't work! travis spits at the prostitute.]]
					check_for_money(100)
				end},
				{text = 'animator for 250', effect = function(opts, i)
					self.fulltext = [[You hire an animator to take travis on a boat ride.

It works! You replace the bullets with cotton balls.]]
					if check_for_money(250, opts) then
						self.prob_sabotage = 1
					end
				end},
			},
			bribe = {
				{text = 'Give 10', effect = function(opts, i)
					self.fulltext = [[You:
...

travis: [takes the money]
This won't buy me a ticket africa, but it's a start. Thanks!]]
					check_for_money(10)
				end},
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
...

travis: [takes the money]
This won't buy me a ticket to africa, but it's a start. Thanks!]]
					check_for_money(100)
				end},
				{text = 'Give 500', effect = function(opts, i)
					self.fulltext = [[You:
...

travis: [takes the money]
Africa, here i come!]]
					if check_for_money(500, opts) then
						self.prob_sabotage = 1
					end
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
...

travis: [takes the money]
Africa, here i come!]]
					if check_for_money(1000, opts) then
						self.prob_sabotage = 1
					end
				end},
			}
		}, { -- Uistean Ursupator - intelligent
------------------------------------------------------------------------------------
			talk = {
				{text = 'Brains', effect = function(opts, i)
					self.fulltext = [[You:
I bet you know a lot of stuff.

Uistean:
I read a lot. Did you know that 'throwing the gauntlet' will become a proverb in the future?]]
				end},
				{text = 'About Eathon', effect = function(opts, i)
					self.fulltext = [[You:
Tell me abot eathon.

Uistean:
Who? Oh, eathon. Well, he's rich. That's why I work for ... with him.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
I think the firing mechanism of eathons gun is suboptimal. If you want I can fix it.

Uistean:
Oh! How nice of you! [hands over the gun]

[You 'fix' the mechanism]

]]
					if math.random() < .3 then
						self.fulltext = self.fulltext .. "You:\nHere's the gun back."
						self.prob_sabotage = 1
					else
						self.fulltext = self.fulltext .. "Uistean:\nHey, you broke it!\nI'll have none of that!"
						self.dialog[self.foe].talk = {}
						self.dialog[self.foe].bribe = {}
						self.dialog[self.foe].hire = {}
					end
				end},
			},
			hire = {
				{text = 'University professor (250)', effect = function(opts, i)
					self.fulltext = [[You hire prof. knowsalot to give uistean a private lecture on 'the history and applications of futorology in the mesopotamian empire'.

While uistean is occupied, you manipulate the gun.]]
					if check_for_money(250, opts) then
						self.prob_sabotage = 1
					end
				end},
			},
			bribe = {
				{text = 'Give 10', effect = function(opts, i)
					self.fulltext = [[You:
Here, to good 'cooperation'.

Uistean:
What? Oh. Thanks, but I don't have a use for that.]]
					if check_for_money(10) then
						money_available = money_available + 10
					end
				end},
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
Here, to good 'cooperation'.

Uistean:
What? Oh. Thanks, but I don't have a use for that.]]
					if check_for_money(100) then
						money_available = money_available + 100
					end
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
Here, to good 'cooperation'.

Uistean:
What? Oh. Thanks, but I don't have a use for that.]]
					if check_for_money(1000) then
						money_available = money_available + 1000
					end
				end},
				{text = 'Give 1500', effect = function(opts, i)
					self.fulltext = [[You:
Here, to good 'cooperation'.

Uistean:
What? Oh. Thanks, but I don't have a use for that.]]
					if check_for_money(1500) then
						money_available = money_available + 1500
					end
				end},
			}
		}, { -- Vaughan Villian - villain
------------------------------------------------------------------------------------
			talk = {
				{text = 'Yikes!', effect = function(opts, i)
					self.fulltext = [[You:
Yikes!

Vaughan:
Did i ... startle ... you?

You:
No, but you look so 90ies.]]
				end},
				{text = 'About Frederic', effect = function(opts, i)
					self.fulltext = [[You:
What do you like about frederic?

vaughan:
Well, he's rich. Very rich. That is a very likable trait.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Can i borrow your gun to ... err ... improve it?

vaughan:
[Laughs] Sure. I like your style. But just to be clear: I cannot guarantee frederic will use it tomorrow... Are you willing to gamble?]]
					self.prob_sabotage = .5
				end},
			},
			hire = {
				{text = 'Black Magician (Your soul)', effect = function(opts, i)
					if self.has_soul then
						self.fulltext = [[You hire a black magician to curse frederics gun.
vaughan is impressed.]]
						self.prob_sabotage = 1
						self.has_soul = false
					else
						self.fulltext = [[You don't have a soul anymore.]]
					end
				end},
			},
			bribe = {
				{text = 'Give 100', effect = function(opts, i)
					self.fulltext = [[You:
You know what this is for.

vaughan:
Do you really think I need your money?]]
					if check_for_money(100) then
						money_available = money_available + 100
					end
				end},
				{text = 'Give 500', effect = function(opts, i)
					self.fulltext = [[You:
You know what this is for.

vaughan:
Do you really think I need your money?]]
					if check_for_money(500) then
						money_available = money_available + 500
					end
				end},
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
You know what this is for.

vaughan:
Stop it already.]]
					if check_for_money(1000) then
						money_available = money_available + 1000
					end
				end},
				{text = 'Give copy of picatrix (Your soul)', effect = function(opts, i)
					if self.has_soul then
						self.fulltext = [[You:
You know what this is for.

vaughan:
Wow, where did you get this? I will to anything for that!]]
						self.prob_sabotage = 1
						self.has_soul = false
					else
						self.fulltext = [[You don't have a soul anymore.]]
					end
				end},
			}
		}, { -- Wiliam Willow - egocentric
------------------------------------------------------------------------------------
			talk = {
				{text = 'sideburns', effect = function(opts, i)
					self.fulltext = [[You:
Nice side... wait a minute. Do I know you from somewhere?

Wiliam:
You probably mean Ronald. This copy cat imitates me. Badly. His hair is all wrong.]]
				end},
				{text = 'About Geoffrey', effect = function(opts, i)
					self.fulltext = [[You:
How is working with ben. Geoffrey?

Wiliam:
He's a bastard. And he doesn't pay well. But I have sworn to serve him.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Do you already have the new splosion max gunpowder? It's now the only officially sanctioned duel gunpowder.

Wiliam:
Unlike Ronald I am not an iditot. There is no such thing.]]
				end},
			},
			hire = {
				{text = 'Drunkard for 10', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Wiliam drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! Wiliam is too busy adoring himself.]]
					check_for_money(10)
				end},
				{text = 'prostitute for 50', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract Wiliam while you manipulate the gun.

It doesn't work! Wiliam is too busy adoring himsel.]]
					check_for_money(50)
				end},
				{text = 'two prostitutes for 100', effect = function(opts, i)
					self.fulltext = [[You hire two prostitute to distract Wiliam while you manipulate the gun.

It doesn't work! Wiliam is too busy adoring himsel.]]
					check_for_money(100)
				end},
				{text = 'high-end prostitutes for 500', effect = function(opts, i)
					self.fulltext = [[You hire a high-end prostitute to distract Wiliam while you manipulate the gun.

It works! You remove the trigger from Geofrey's gun.]]
					check_for_money(500)
					self.prob_sabotage = 1
				end},
			},
			bribe = {
				{text = 'Give 1000', effect = function(opts, i)
					self.fulltext = [[You:
Here, we wouldn't want anything to happen to Ben-Geofrey, would we? [wink]

Wiliam:
I find this rather insulting. I have sworn an oath. take your money elsewhere.]]
				end}
			}
		}, { -- Xavier Xalbrain - honourable
------------------------------------------------------------------------------------
			talk = {
				{text = 'hat', effect = function(opts, i)
					self.fulltext = [[You:
I like your hat. very honourable.

Xavier:
Thank you. You sport a rather nice hat yourself, if i may say so.]]
				end},
				{text = 'About Harry', effect = function(opts, i)
					self.fulltext = [[You:
Tell me about Harry.

Xavier:
Our families have walked this earth together since generations. We serve them,
they serve us. It will always be this way.]]
				end},
				{text = 'Manipulate', number = 1, effect = function(opts, i, opt)
					self.fulltext = ({[[You:
Did you know Harry once drank a bucket of horse piss?

Xavier:
I don't believe you.]], [[You:
Did you know Harry once flew over a cuckook's nest?

Xavier:
I don't even know what that means]], [[You:
Did you know harry insulted my mother?

I said: "Y'are a dog."
He said: "Thy mother's of my generation. What's she, if I be a dog?"

Xavier:
*gasp* This cannot ... [faints]

You sabotage Harry's gun while Xavier is out.
]]})[opt.number]
					if opt.number < 3 then
						opt.number = opt.number + 1
						opts[#opts+1] = opt
					else
						self.prob_sabotage = 1
					end
				end},
			},
			hire = {
				{text = 'Drunkard for 10', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Xavier drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! Xavier is too honourable to drink with the homeless.]]
					check_for_money(10)
				end},
				{text = 'prostitute for 50', effect = function(opts, i)
					self.fulltext = [[You hire a prostitute to distract Xavier while you manipulate the gun.

It doesn't work! Xavier is too honourable to sleep with a cheap prostitute.]]
					check_for_money(50)
				end},
				{text = 'Goon Squad for 100', effect = function(opts, i)
					self.fulltext = [[You hire a goon squad to beat up Xavier.

It doesn't work! Xavier is too honourable to fight with common people.]]
					check_for_money(100)
				end},
			},
			bribe = {
				{text = 'Give 500', effect = function(opts, i, opt)
					self.fulltext = [[You:
Would you be willing to close your eyes for a moment?
[You flash the 500 in front of his face.]

Xavier:
Do you want to imply I would be open to immoral behavior? Put that away.]]
				end},
			}
		}, { -- Yeoman Yates - loyal
------------------------------------------------------------------------------------
			talk = {
				{text = 'beard', effect = function(opts, i)
					self.fulltext = [[You:
Are you hiding something under that beard?

Yeoman:
Yes. A world of pain.]]
				end},
				{text = 'About Ian', effect = function(opts, i)
					self.fulltext = [[You:
How to you feel about ian?

Yeoman:
He is the best that ever happend to me. He picked me off the street to give me food and shelter, you know?]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Isn't ian kind of a douche?

Yeoman:
No. But you sound like a jerk.]]
				end},
			},
			hire = {
				{text = 'prostitute for 10', effect = function(opts, i)
					self.fulltext = [[You hire a cheap hooker to distract Yeoman while you manipulate the gun.

Prostitute:
Yeoman? Is that you?

Yeoman:
Mother?

You seize the moment and damage the firing mechanism of the gun.]]
					check_for_money(10)
					self.prob_sabotage = 1
				end},
				{text = 'high-end prostitutes for 1000', effect = function(opts, i)
					self.fulltext = [[You hire a high-end prostitute to distract Yeoman while you manipulate the gun.

It doesn't work! He takes the gun with him.]]
					check_for_money(1000)
				end},
				{text = 'two high-end prostitutes for 2000', effect = function(opts, i)
					self.fulltext = [[You hire two high-end prostitute to distract Yeoman while you manipulate the gun.

It doesn't work! He takes the gun with him.]]
					check_for_money(2000)
				end},
			},
			bribe = {
				{text = 'Give 1', effect = function(opts, i, opt)
					self.fulltext = [[You:
How does this make you feel about Ian?

Yeoman:
Not even all the money in the commonwealth could break my allegiance.]]
					amount = tonumber(opt.text:match('%s(%d+)$'))
					if check_for_money(amount) then
						money_available = money_available + amount
						opts[#opts+1] = opt
						opt.text = opt.text .. '0'
					end
				end},
			}
		}, { -- Zaiden Zalman - secretly in love
------------------------------------------------------------------------------------
			talk = {
				{text = 'shirt', effect = function(opts, i)
					self.fulltext = [[You:
That shirt looks familiar.

Zaiden:
It's by the same tailor who makes xaviers clothes. Expensice, but worth it.]]
				end},
				{text = 'About james', effect = function(opts, i)
					self.fulltext = [[You:
How to you feel about james?

Zaiden:
Normal. I have normal feelings towards james.]]
				end},
				{text = 'Manipulate', effect = function(opts, i)
					self.fulltext = [[You:
Look behind you, A three headed monkey!

Zaiden:
Nice try.]]
				end},
			},
			hire = {
				{text = 'Drunkard for 100', effect = function(opts, i)
					self.fulltext = [[You hire a guy to get Ziaden drunk so you can manipulate the gun while he sleeps it off.

It doesn't work! Zaiden politely declines to drink.]]
					check_for_money(100)
				end},
				{text = 'high-end prostitutes for 1000', number = 1, effect = function(opts, i,opt)
					if opt.number == 1 then
						self.fulltext = [[You hire a prostitute to distract Zaiden.

It doesn't work! He doesn't even look at her.]]
						opts[#opts+1] = opt
					elseif opt.number == 2 then
						self.fulltext = [[You hire a prostitute to distract Zaiden.

It doesn't work! He doesn't even look at her. Again.

What's your obsession with hookers anyway?]]
						opts[#opts+1] = opt
					else
						self.fulltext = [[On a whim, you hire a prostitute for James.

Xavier seems upset. He shoots angry looks over to james.

While Xavier is unobservant, you swap the gun for a prepared one.]]
						self.prob_sabotage = 1
					end
					opt.number = opt.number + 1
					check_for_money(1000)
				end},
			},
			bribe = {
				{text = 'Let\' face it: you cannot bribe him.', effect = function(opts, i, opt)
					self.fulltext = [[You:
I really cannot bribe you?

Zaiden:
You really cannot bribe me.]]
					opts[#opts+1] = opt
				end},
			},
		}
	}

	self.fulltext = ([=[You approach %s to settle the details of the duel and maybe 'win' him over...]=]):format(seconds[self.foe].name:match('^%S+'))
	st:execute({}, 0, {}) -- hackety hack
end

function st:leave()
	self:fade_out_banter()
end

function st:update(dt)
	love.graphics.setFont(Font.slkscr[23])

	gui.group{grow = 'down', size = {WIDTH - 8}, pos = {4,4}, spacing = 2, function()
		gui.Separator{}
		gui.group{grow = 'right', size = {180}, function()
			gui.Label{text = 'Offender:', size = {[2]='tight'}}
			gui.Label{text = ('%s (%s)'):format(offenders[self.foe].name, offenders[self.foe].trait), size = {[2]='tight'}}
		end}
		gui.group{grow = 'right', size = {180}, function()
			gui.Label{text = 'His Second:', size = {[2]='tight'}}
			gui.Label{text = ('%s (%s)'):format(seconds[self.foe].name, seconds[self.foe].trait), size = {[2]='tight'}}
		end}

		gui.group{grow = 'right', size = {180}, function()
			gui.Label{text = 'YOUR FUNDS: ', size = {[2]='tight'}}
			gui.Label{text = ('  %d'):format(money_available), size = {[2]='tight'}}
		end}
		gui.Separator{}
	end}

	love.graphics.setFont(Font.slkscr[28])
	gui.group{grow = 'right', pos = {5,HEIGHT-40}, size = {130, 35}, spacing = 10, function()
		for _, s in ipairs{'talk', 'bribe', 'hire'} do
			self.can[s] = #((self.dialog[self.foe] or {})[s] or {}) > 0
			if gui.Button{text = s, disabled = not self.can[s]} and self.can[s] then
				self.fulltext = [[]]
				self.text = [[]]
				self.state = s
				Sound.static.click:play()
			end
		end

		if gui.Button{text = 'Face consequences', size = {320}, pos = {40}} then
			GS.transition(State.shootout, 1, self.prob_sabotage)
			Sound.static.click:play()
		end
	end}

	love.graphics.setFont(Font.slkscr[24])
	gui.group{grow = 'up', pos = {20, HEIGHT-100}, align = 'left', size = {WIDTH-400, 30}, function()
		local opts = (self.dialog[self.foe] or {})[self.state] or {}
		for i = #opts,1,-1 do
			local opt = opts[i]
			if opt and gui.Button{text = ('%d. %s'):format(i, opt.text), align = 'left'} then
				Sound.static.click:play()
				self:execute(opts, i, opt)
			end
		end
	end}

	self.timer:update(dt)

	if gui.Button{text = self.mute and 'play music' or 'stop music', pos = {WIDTH-185,4}, size={180,30}, align = 'right'} then
		self.mute = not self.mute
		if self.mute then
			self.banter:setVolume(0)
			self.banter:stop()
		else
			self:fade_in_banter()
		end
	end
end

function st:execute(opts, i, opt)
	(opt.effect or function()end)(opts, i, opt)
	table.remove(opts, i)
	self.text, i = '', 1
	self.reveal = self.timer:add(.1, function(f)
		if i < #self.fulltext then
			self.text = self.fulltext:sub(1,i)
			local c = self.fulltext:sub(i,i)
			local dt = ({[true] = .2, [false] = .02})[not not c:match('[,;:%.!%?]')]
			i = i + 1
			self.reveal = self.timer:add(dt+math.random()*.07, f)
			Sound.static.char:play()
		else
			self.reveal = nil
			self.text = self.fulltext
		end
	end)
end

function st:draw()
	love.graphics.setColor(50,60,70)
	love.graphics.draw(Images.title, 0,0)

	local x, y, s, b = WIDTH-20, 110, 7.5, 1
	love.graphics.setColor(192,134, 55)
	love.graphics.rectangle('line', x-s*38-b, y-b, s*38+b*2, s*50+b*2)
	--love.graphics.setColor(12,11,14,50)
	love.graphics.setColor(192,134, 55,20)
	love.graphics.rectangle('fill', x-s*38, y, s*38, s*50)
	love.graphics.setColor(255,255,255)
	love.graphics.drawq(Images.faces, self.quads[self.foe], x,y, 0,s,s, 38,0)

	gui.core.draw()

	-- font has no pound sign -_-
	love.graphics.setColor(192,134, 55)
	love.graphics.draw(Images.pound, 189, 75, 0, 2.3,2.3, 0,7)

	if self.text then
		love.graphics.printf(self.text, 20, 120, x-s*38+b*2-40, 'left')
	end
end

function st:keypressed(key)
	if self.reveal then
		self.text = self.fulltext
		self.timer:cancel(self.reveal)
	end
	local n = tonumber(key)
	if self.dialog[self.state] and n then
		opts = self.dialog[self.state] or {}
		if (opts[self.foe] or {})[n] then
			st:execute(opts[self.foe], i, opt)
		end
	end
end

function st:mousepressed()
	if self.reveal then
		self.text = self.fulltext
		self.timer:cancel(self.reveal)
	end
end

return st

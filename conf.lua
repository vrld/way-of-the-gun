function love.conf(t)
	t.title             = "Way of the Gun"
	t.author            = "vrld"
	t.url               = "http://vrld.org/"
	t.identity          = "vrld-way-of-the-gun"
	--t.release           = true

	t.modules.physics   = false

	--t.screen.width      = 1024
	--t.screen.height     = 700
	t.screen.fullscreen = false
	t.screen.fsaa       = 0
	t.screen.vsync      = false
end

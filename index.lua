-- Main Loop
while true do

	-- Updating screens
	Screen.waitVblankStart()
	Screen.refresh()
	
	-- Writing something on screen
	Screen.debugPrint(0,0,"Needy Girl Overdose",Color.new(255,255,255),TOP_SCREEN)
	
	-- Flipping screen
	Screen.flip()

	-- Sets up HomeMenu syscall
	if Controls.check(Controls.read(),KEY_HOME) or Controls.check(Controls.read(),KEY_POWER) then
		System.showHomeMenu()
	end
	
	-- Exit if HomeMenu calls APP_EXITING
	if System.checkStatus() == APP_EXITING then
		System.exit()
	end
	
end

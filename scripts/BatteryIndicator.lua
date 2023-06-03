Battery = {}

Battery.x = 370
Battery.y = 5

function Battery.update()
	if System.isBatteryCharging() then
		Graphics.drawScaleImage(Battery.x, Battery.y, IMAGES["batteryCharge"], 0.5, 0.5)
	else
		Graphics.drawScaleImage(Battery.x, Battery.y, IMAGES["battery"..System.getBatteryLife()], 0.5, 0.5)
	end
end

return Battery
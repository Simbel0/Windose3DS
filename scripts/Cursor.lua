Cursor = {}

Cursor.sprite = loadImage("img/cursor.png")

Cursor.width = Graphics.getImageWidth(Cursor.sprite)
Cursor.height = Graphics.getImageHeight(Cursor.sprite)
Cursor.x = (320/2)-Cursor.width/2
Cursor.y = (240/2)-Cursor.height/2

Cursor.show = true

function Cursor.update()
	if Cursor.show then
		Graphics.drawScaleImage(Cursor.x, Cursor.y, Cursor.sprite, 0.5, 0.5)
		local old_x, old_y = Cursor.x, Cursor.y

		local touch_x, touch_y = Controls.readTouch()
		local pad_x, pad_y = Controls.readCirclePad()
		if (touch_x>0 and touch_y>0) and (touch_x~=old_x or touch_y~=old_y) then
			Cursor.x, Cursor.y = touch_x-3.5, touch_y
		end
		if (pad_x<-10 and pad_x>10) or (pad_y<-10 and pad_y>10) then
			Cursor.x, Cursor.y = Cursor.x+pad_x/10, Cursor.y+pad_y/10
		end
	end
end

return Cursor
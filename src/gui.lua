click = 0

function no_mouseover()
	return nil
end


function go_to_option()
	launch_menu(option_menu)
end

function go_to_main_menu()
	launch_menu(main_menu)
end

function create_button(img, txt, size_x, size_y, pos_x, pos_y, click_on_func, mouseover_txt)
	local button = {sprite = love.graphics.newImage(img), text = txt, w = (size_x * screen_w) / 1280, h = (size_y * screen_h) / 720, x = (pos_x * screen_w) / 1280, y = (pos_y * screen_h) / 720, click_on = click_on_func, mouseover = mouseover_txt}
	return button
end

function create_slide(txt, size_x, size_y, pos_x, pos_y, minv, maxv, defaultv, click_on_func, mouseover_txt)
	local slide = {text = txt, w = (size_x * screen_w) / 1280, h = (size_y * screen_h) / 720, x = (pos_x * screen_w) / 1280, y = (pos_y * screen_h) / 720, min = minv, max = maxv, value = defaultv, click_on = click_on_func, mouseover = mouseover_txt}
	return slide
end

function load_gui()
	love.graphics.setFont(love.graphics.newFont(40))
	main_menu = {back = love.graphics.newImage("misc/main_menu.jpg"), buttons = {}, slides = {}}
	table.insert(main_menu.buttons, create_button("misc/partie_rapide.png", "", 538, 135, 350, 430, launch_quick_party, nil))
	table.insert(main_menu.buttons, create_button("misc/option.png", "", 538, 135, 350, 570, go_to_option, nil))

	option_menu = {back = love.graphics.newImage("misc/option_menu.png"), buttons = {}, slides = {}}
	table.insert(option_menu.slides, create_slide("music volume", 300, 30, 470, 470, 0, 1, 1, set_volumes, nil))
	table.insert(option_menu.slides, create_slide("sound volume", 300, 30, 470, 530, 0, 1, 1, set_volumes, nil))
	table.insert(option_menu.buttons, create_button("misc/retour.png", "", 538, 135, 350, 570, go_to_main_menu, nil))
end

function draw_buttons(buttons)
	local on_button = 0
	x, y = love.mouse.getPosition()
	for i, button in pairs(buttons) do
		if (x > button.x and x < button.x + button.w and y > button.y and y < button.y +  button.h) 
		then
			love.graphics.setColor(200, 200, 200, 255)
			on_button = 1
		else
			love.graphics.setColor(255, 255, 255, 255)
		end
		if (button.sprite) then
			draw_size(button.sprite, button.x, button.y, button.w, button.h)
			if (on_button) then
				--mouseover			
			end
		end
		if (button.text) then
			love.graphics.print(button.text, button.x, button.y)
		end
	end
	love.graphics.setColor(255, 255, 255, 255)
end

function draw_slide(slides)
	for i, slide in pairs(slides) do
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.rectangle("fill", slide.x , slide.y + (slide.h / 2) - slide.h / 8 , slide.w, slide.h / 4)
		love.graphics.setColor(255, 255, 100, 255)
		love.graphics.circle("fill", slide.x + (slide.value / slide.max - slide.min) * slide.w, slide.y + slide.h / 2, slide.h / 2)
		love.graphics.setColor(0, 0, 0, 255)
		love.graphics.setLineWidth(6)
		love.graphics.circle("line", slide.x + (slide.value / slide.max - slide.min) * slide.w, slide.y + slide.h / 2, slide.h / 2)
	end
end

function draw_menu()
	love.graphics.setColor(255, 255, 255, 255)
	draw_size(active_menu["back"], 0, 0, screen_w, screen_h)
	draw_buttons(active_menu.buttons)
	draw_slide(active_menu.slides)
end

function check_click_button(buttons)
	if (click == 1) then
		x, y = love.mouse.getPosition()
		for i, button in pairs(buttons) do
			if (x > button.x and x < button.x + button.w and y > button.y and y < button.y +  button.h and button.click_on) then
				button.click_on(button)
			end
		end
	end
end

function check_click_slide(slides)
	if (click >= 1) then
		x, y = love.mouse.getPosition()
		for i, slide in pairs(slides) do
			if (x > slide.x and x < slide.x + slide.w and y > slide.y and y < slide.y + slide.h) then
				slide.value = slide.min + (slide.max - slide.min) * ((x - slide.x) / slide.w)   
				if (slide.click_on) then slide.click_on(slide) end
			end
		end
	end
end

function update_menu()
	if (love.keyboard.isDown("escape")) then
		os.exit()
	end
	if (love.mouse.isDown(1) == true) then
		click = click + 1
	elseif love.mouse.isDown(1) == false then
		click = 0
	end
	check_click_button(active_menu.buttons)
	check_click_slide(active_menu.slides)
end

function launch_menu(menu)
	active_menu = menu
	love.draw = draw_menu
	love.update = update_menu
end

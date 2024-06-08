-- drum_seq
-- 
-- 
--
-- 
--
--
-- v0.1 imminent gloom

g = grid.connect()

local br_step_this = 15
local br_step_on = 10
local br_button_on = 8
local br_button_off = 4

s = {}
t = {false, false, false, false}
erase = false

step = 1
start = 1
prev_x = 1
stop = 16

	
press_1 = 0
press_2 = 0
press_min = 1
press_max = 16


function clear_all()
	for x = 1, 16 do s[x] = {0,0,0,0} end
end


function loop()
	while true do
		clock.sync(1/4)
		this_step()
		crow_output()
		redraw()
		redraw_grid()
	end
end


function init()
	clear_all()
	clock.run(loop)
end


function redraw()
	screen.clear()
	screen.aa(1)
	screen.move(6, 56)
	screen.font_face(11)
	screen.font_size(28)
	screen.text('bpm: ' .. params:get('clock_tempo'))
	screen.update()
end


function redraw_grid()
	g:all(0)
	
	--light up sequence
	for x = 1, 16 do
		for y = 1, 4 do
			g:led(x, y, s[x][y] * br_step_on)
		end
	end 
	
	-- light up current step
	g:led(step, 5, br_step_this)

	-- ligth up current loop
	for n = press_min, press_max do g:led(n, 6, 4) end
	
	-- blink fill buttons
	for n = 1, 4 do
		if t[n] == true then
			g:led(n, 7, 15) else g:led(n, 7, (s[step][n] * 2) + 2)
		end
	end
	
	-- blink trigger buttons
	for n = 1, 4 do
		if t[n] == true then
			g:led(n, 8, 15) else g:led(n, 8, (s[step][n] * 4) + 4)
		end
	end
	
	--light up erase button
	if erase == true then g:led(16, 8, 15) else g:led(16, 8, 4) end
	
	g:refresh()
end


function crow_output()
	for n = 1, 4 do
		if s[step][n] == 1 then
		    crow.output[n].action = 'pulse()'
		    crow.output[n]()
		end
	end
end

function this_step()
	step = step + 1
	if step == stop + 1 then step = start end
	
	-- erase if triggers + erase is held
	if erase == true then
		for n = 1, 4 do
			if t[n] == true then s[step][n] = 0 end
		end
	end
	
	-- add if fill is held
	if erase == false then
		for n = 1, 4 do
			if t[n] == true then s[step][n] = 1 end
		end
	end	
	
end


function g.key(x, y, z)
	
	if x == 16 and y == 8 and z == 1 then erase = true end
	if x == 16 and y == 8 and z == 0 then erase = false end
	
	-- trigger buttons
	if y == 8 and z == 1 then
		if erase == false then
			if x == 1 and erase == false then s[step][1] = 1 end
			if x == 2 and erase == false then s[step][2] = 1 end
			if x == 3 and erase == false then s[step][3] = 1 end
			if x == 4 and erase == false then s[step][4] = 1 end
		end
		if erase == true then
			t[x] = true
		end
	end
	
	if y == 8 and z == 0 then
		t[x] = false
	end
	
	-- fill buttons
	if y == 7 and z == 1 then
		t[x] = true
	end
	
	if y == 7 and z == 0 then
		t[x] = false
	end
		
	-- sequence steps	
	if z == 1 then
		if y <= 4 then s[x][y] = (s[x][y] + 1) % 2 end
		if y == 5 then step = util.clamp(x, start, stop) end
		redraw_grid()
	end
	
	-- sequence loop
	if y == 6 and z == 1 then
		if press_1 == 0 then press_1 = x end
		if press_1 ~= 0 then press_2 = x end	
	end
		
	if y == 6 and z == 0 then
		if press_2 ~= 0 then
			if press_1 < press_2 then
				press_min = press_1
				press_max = press_2
			elseif press_1 > press_2 then
				press_min = press_2
				press_max = press_1
			end
			start = press_min
			step = press_min
			stop = press_max
			press_1 = 0
			press_2 = 0
		end
	end
end

function key(n, z)
end

function enc(n, d)
	if n == 1 then params:delta('clock_tempo', d) end
end

function cleanup()

end
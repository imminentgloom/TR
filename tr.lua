-- drum_seq
-- 
-- 
--
-- 
--
--
-- v0.2 imminent gloom

engine.name = 'TR_Sampling' -- All the sample stuff is by infinitedigits

g = grid.connect()

local br_step_this = 15
local br_step_on = 10
local br_button_on = 8
local br_button_off = 4

s = {}
step = 1
start = 1
stop = 16

loop = {}
loop_min = 1
loop_max = 16

jump = {}
jump_step = 1

function clear_all()
	for x = 1, 16 do s[x] = {0,0,0,0} end
end


function forever()
	while true do
		clock.sync(1/4)
		this_step()
		crow_output()
		redraw()
		redraw_grid()
	end
end


function init()

	t = {false, false, false, false}
	erase = false
	fill = false

	
	params:add_group('TR', 16)
	
	params:add_separator('Track 1')
	
	params:add_file('sample1','Sample', '/home/we/dust/audio/common/909/909-BD.wav')
	params:set_action('sample1', function(x) engine.sample(1, x)end)	
	
	params:add_control('rate1','Rate', controlspec.RATE)
	params:set_action('rate1', function(x) engine.rate(1, x) end)
	
	params:add_control('amp1','Amp', controlspec.new(0, 1, 'lin', 0, 0.25))
	params:set_action('amp1', function(x) engine.amp(1, x) end)
		
	params:add_separator('Track 2')
	
	params:add_file('sample2','Sample', '/home/we/dust/audio/common/909/909-SD.wav')
	params:set_action('sample2', function(x) engine.sample(2, x)end)	
	
	params:add_control('rate2','Rate', controlspec.RATE)
	params:set_action('rate2', function(x) engine.rate(2, x) end)
	
	params:add_control('amp2','Amp', controlspec.new(0, 1, 'lin', 0, 0.25))
	params:set_action('amp2', function(x) engine.amp(2, x) end)
	
	params:add_separator('Track 3')

	params:add_file('sample3','Sample', '/home/we/dust/audio/common/909/909-CP.wav')
	params:set_action('sample3', function(x) engine.sample(3, x)end)	
	
	params:add_control('rate3','Rate', controlspec.RATE)
	params:set_action('rate3', function(x) engine.rate(3, x) end)
	
	params:add_control('amp3','Amp', controlspec.new(0, 1, 'lin', 0, 0.25))
	params:set_action('amp3', function(x) engine.amp(3, x) end)
	
	params:add_separator('Track 4')
	
	params:add_file('sample4','Sample', '/home/we/dust/audio/common/909/909-CH.wav')
	params:set_action('sample4', function(x) engine.sample(4, x)end)	
	
	params:add_control('rate4','Rate', controlspec.RATE)
	params:set_action('rate4', function(x) engine.rate(4, x) end)
	
	params:add_control('amp4','Amp', controlspec.new(0, 1, 'lin', 0, 0.25))
	params:set_action('amp4', function(x) engine.amp(4, x) end)
	
	params:read('/home/we/dust/data/tr/state.pset')
	
	params:bang()


	clear_all()
	clock.run(forever)

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
	for n = loop_min, loop_max do g:led(n, 6, 4) end
	
	-- blink trigger buttons
	for n = 1, 4 do
		if t[n] == true then
			g:led(n, 8, 15) else g:led(n, 8, (s[step][n] * 4) + 4)
		end
	end
	
	--light up erase button
	if erase == true then g:led(16, 8, 15) else g:led(16, 8, 4) end
	    
	--light up fill button
	if fill == true then g:led(15, 8, 15) else g:led(15, 8, 4) end
	
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
	
	-- plays sample
	for n = 1, 4 do
		if s[step][n] == 1 then engine.pos(n, 1, 0) end
	end
	
	-- step through sequence
	step = step + 1
	if step > stop then step = start end
	
	-- erase if triggers + erase is held
	if erase == true then
		for n = 1, 4 do
			if t[n] == true then s[step][n] = 0 end
		end
	end
	
	-- add if triggers + fill is held
	if fill == true then
	    for n = 1, 4 do
			if t[n] == true then s[step][n] = 1 end
		end
	end
	
	-- step through table of held steps to jump between them
	if #jump == 1 then
		step = util.clamp(jump[1], start, stop)
	elseif #jump > 1 then
		jump_step = jump_step + 1
		if jump_step > #jump then jump_step = 1 end
		step = util.clamp(jump[jump_step], start, stop)
	end
	
		
end


function g.key(x, y, z)
	
	
	-- set modifiers
	if x == 16 and y == 8 and z == 1 then erase = true end
	if x == 16 and y == 8 and z == 0 then erase = false end
	
	if x == 15 and y == 8 and z == 1 then fill = true end
	if x == 15 and y == 8 and z == 0 then fill = false end
	
	
	-- trigger buttons
	if y == 8 and z == 1 then
		if fill == false and erase == false then
			if x == 1 and erase == false then s[step][1] = 1 end
			if x == 2 and erase == false then s[step][2] = 1 end
			if x == 3 and erase == false then s[step][3] = 1 end
			if x == 4 and erase == false then s[step][4] = 1 end
		end
		t[x] = true
    end
	
	if y == 8 and z == 0 then
		t[x] = false
	end
	
		
	-- sequence steps	
	if z == 1 then
		if y <= 4 then s[x][y] = (s[x][y] + 1) % 2 end
	end
	
	-- sequence loop
	if y == 6 and z == 1 then
		table.insert(loop, 1, x)
	end
	
	if y == 6 and z == 0 then
		if #loop > 1 then
			if loop[1] < loop[2] then
				loop_min = loop[1]
				loop_max = loop[2]
			elseif loop[1] > loop[2] then
				loop_min = loop[2]
				loop_max = loop[1]
			end
			start = loop_min
			stop = loop_max
		end
		table.remove(loop) 
	end
	
	-- jump steps
	-- add all held steps to a table
	if y == 5 and z == 1 then
		table.insert(jump, x)
	end
	
	-- remove each step as it is released
	if y == 5 and z == 0 then
		for i, v in pairs(jump) do
			if v == x then table.remove(jump, i) end
		end
	end
	
	-- redraw the grid whenever we touch it
	redraw_grid()
end

function key(n, z)
end

function enc(n, d)
	if n == 1 then params:delta('clock_tempo', d) end
end

function cleanup()
	params:write('/home/we/dust/data/tr/state.pset')
end

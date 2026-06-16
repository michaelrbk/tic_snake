-- title:   My Tic Snake
-- author:  Michael Becker michaelrbk@gmail.com
-- desc:    first snake version on TIC-80
-- license: MIT License
-- version: 0.5
-- script:  lua

-- GLOBALS
CELL_SIZE = 16
GRID_SIZE = 8
TOP_BORDER = 4
LEFT_BORDER = 54
T = CELL_SIZE
DIR_NEW = -1
DIR = 1
SCORE = 0
END = true
NEW_FRUIT = false

snake_head = {
	x_pos = 3,
	y_pos = 3
}

snake_body = {
}

fruit = {
	x_pos = 0,
	y_pos = 0
}

function INIT()
	new_game()
end

function TIC()
	INPUTS()
	UPDATES()
	DRAW()
end

function INPUTS()
	if btn(0) and DIR ~= 2 then DIR_NEW = 0 end -- up
	if btn(3) and DIR ~= 3 then DIR_NEW = 1 end -- right
	if btn(1) and DIR ~= 0 then DIR_NEW = 2 end -- down
	if btn(2) and DIR ~= 1 then DIR_NEW = 3 end -- left
end

function UPDATES()
	T = T - 1
	if T == 0 then
		move()
		T = CELL_SIZE
	end
	check_fruit()
	check_endgame()
end -- UPDATES

function DRAW()
	cls(0)
	draw_background()
	if (END) then
		if DIR_NEW == -1 then
			return
		end
		new_game()
	end

	-- grids grass
	for _x = LEFT_BORDER, LEFT_BORDER + CELL_SIZE * GRID_SIZE - 1, CELL_SIZE do
		for _y = TOP_BORDER, TOP_BORDER + CELL_SIZE * GRID_SIZE - 1, CELL_SIZE do
			--rectb(_x ,_y, CELL_SIZE, CELL_SIZE, 12)
		 --spr(256, _x, _y, -1, 2, math.random(0,1), math.random(0,1), 1, 1)
			spr(256, _x, _y, -1, 2, 0, 0, 1, 1)
		end
	end

	-- snake head
	spr(257, xgrid(snake_head.x_pos), ygrid(snake_head.y_pos), -1, 2, 0, (DIR - 1) % 4, 1, 1)

	-- fruit
	spr(272, xgrid(fruit.x_pos), ygrid(fruit.y_pos), -15, 2, 0, 0, 1, 1)

	-- snake body
	local body_len = #snake_body
	for i = 1, body_len do
		local seg = snake_body[i]
		local ex_dir = seg.dir -- exit direction
		local sid, flp, rot

		if i == body_len then
			sid = 258 -- tail tip
			flp = 0
			rot = (ex_dir - 1) % 4
		else
			local nx = snake_body[i + 1]
			local en_dir -- entry direction
			if nx.x_pos > seg.x_pos then en_dir = 1
			elseif nx.x_pos < seg.x_pos then en_dir = 3
			elseif nx.y_pos > seg.y_pos then en_dir = 2
			else en_dir = 0 end

			if (ex_dir - en_dir) % 4 == 2 then
				sid = 259 -- straight
				flp = 0
				rot = (ex_dir - 1) % 4
			elseif (ex_dir - en_dir) % 4 == 3 then
				sid = 260 -- corner, rotating snake to right
				flp = 0
				rot = (ex_dir + 3) % 4
			else
				sid = 260 -- corner, rotating snake to left (flipped)
				flp = 1
			 rot = 3 - ex_dir
			end
		end

		spr(sid, xgrid(seg.x_pos), ygrid(seg.y_pos), -1, 2, flp, rot, 1, 1)
	end
end -- DRAW

function draw_background()
	-- spr(id x y colorkey=-1 scale=1 flip=0 rotate=0 w=1 h=1)
	-- sprintes are 64 and 66, change every half a second
	
	-- dog
	sprite = ((math.floor(time() / 500) % 2) * 2)
	spr(324 + sprite, 20, 14, -1, 2, 0, 0, 2, 2)
	
	-- cow
	sprite = ((math.floor(time() / 500) % 2) * 2)
	spr(320 + sprite, 20, 52, -1, 2, 0, 0, 2, 2)
	
	-- pig
	sprite = ((math.floor(time() / 500) % 2) * 2)
	spr(352 + sprite, 20, 87, -1, 2, 0, 0, 2, 2)

	-- cat
	spr(356 + sprite, 185, 14, -1, 2, 1, 0, 2, 2)
	print('SCORE ' .. SCORE, 2, 3, 14)
	
	-- rabbit
	sprite = ((math.floor(time() / 500) % 2) * 2)
	spr(328 + sprite, 185, 52, -1, 2, 0, 0, 2, 2)
	
		-- chicken
	sprite = ((math.floor(time() / 500) % 2) * 2)
	spr(360 + sprite, 185, 87, -1, 2, 0, 0, 2, 2)
end

function new_game()
	SCORE = 0
	T = CELL_SIZE
	DIR = 1
	DIR_NEW = -1
	END = false
	NEW_FRUIT = false
	snake_head.x_pos = 3
	snake_head.y_pos = 3
	spawn_fruit()
	snake_body = {
	}
	math.randomseed(time())
end

function xgrid(val)
	return LEFT_BORDER + (val * CELL_SIZE)
end

function ygrid(val)
	return TOP_BORDER + (val * CELL_SIZE)
end

function move()
	local x_dir = 0
	local y_dir = 0
	DIR = DIR_NEW
	if DIR_NEW == 0 then  --up
		y_dir = -1
	elseif DIR_NEW == 1 then --right
		x_dir = 1
	elseif DIR_NEW == 2 then --down
		y_dir = 1
	elseif DIR_NEW == 3 then --left
		x_dir = -1
	end

	-- move body
	move_body()

	snake_head.x_pos = snake_head.x_pos + x_dir
	snake_head.y_pos = snake_head.y_pos + y_dir

	-- check for tail
	for i = 1, #snake_body do
		if (snake_head.x_pos == snake_body[i].x_pos and snake_head.y_pos == snake_body[i].y_pos) then
			END = true
		end
	end
end --move

function move_body()
	snake_part = {
		x_pos = snake_head.x_pos,
		y_pos = snake_head.y_pos,
		dir = DIR
	}
	if NEW_FRUIT then
		NEW_FRUIT = false
		table.insert(snake_body, 1, snake_part)
	else
		if #snake_body == 0 then
			return
		end
		table.insert(snake_body, 1, snake_part)
		table.remove(snake_body)
	end
end --move_body

function spawn_fruit()
	-- Generate random position for fruit
	fruit.x_pos = math.random(0, GRID_SIZE - 1)
	fruit.y_pos = math.random(0, GRID_SIZE - 1)

	-- Prevent fruit from spawning on snake
	while fruit.x_pos == snake_head.x_pos and fruit.y_pos == snake_head.y_pos do
		fruit.x_pos = math.random(0, GRID_SIZE - 1)
		fruit.y_pos = math.random(0, GRID_SIZE - 1)
	end
end

function check_fruit()
	if snake_head.x_pos == fruit.x_pos and snake_head.y_pos == fruit.y_pos then
		SCORE = SCORE + 1
		NEW_FRUIT = true
		spawn_fruit()
	end
end

function check_endgame()
	if (snake_head.x_pos > GRID_SIZE - 1 or snake_head.x_pos < 0) then
		END = true
	end
	if (snake_head.y_pos > GRID_SIZE - 1 or snake_head.y_pos < 0) then
		END = true
	end
	if END then
		cls(0)
		NEW_DIR = -1
	end
end --check_endgame

-- <SPRITES>
-- 000:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 001:ffffffff666666ff5555756f55555556555555225555756f666666ffffffffff
-- 002:ffffffffff666666f65555556555555565555555f6555555ff666666ffffffff
-- 003:ffffffff666666665555555555555555555555555555555566666666ffffffff
-- 004:ffffffffffff6666fff65555ff655555f6555555f6555555f6555566f655556f
-- 016:ffff65fffff6fffff222222f222222222222222222222222f222222fff2222ff
-- 064:0000000c0000000cc00000000c00000000c0000c0c0ccc0c0cccc0ccccccc0c0
-- 065:c0000cc00cccc0c0c0cc0c00c0cc0c00ccccccc0c0000ccc0cccc0ccc0cc0c0c
-- 066:0000000c0000000c000000000c00000000c0000c0c0ccc0c0cccc0ccccccc0c0
-- 067:c0000cc00cccc0c0c0cc0c00c0cc0c00ccccccc0c0000ccc0cccc0ccc0cc0c0c
-- 068:0000000000000ccc00cccccc0ccccccccccccccccccc0c0c0ccc0ccc0cc00cc0
-- 069:00000000ccccc000cccccc000cc0cc000cc0ccc00cccccc0ccc000c0cccc0cc0
-- 070:0000000000000ccc00cccccc0ccccccccccccccccccc0c0c0ccc0ccc0cc00cc0
-- 071:00000000ccccc000cccccc000cc0cc000cc0ccc00cccccc0ccc000c0cccc0cc0
-- 072:00c00c000c0cc0c00c0cc0c00c0cc0c000ccccc000ccccc00c0cc0cc0c0cc0cc
-- 073:000000000000000000000000000000000000000000000000000000c000000ccc
-- 074:00000c000cccc0c0c000c0c00cc0c0c000cc0cc000ccccc00ccccccc0c0cc0cc
-- 075:000000000000000000000000000000000000000000000000000000c000000cc0
-- 080:ccccc0c0ccccc0c0cc0cc00cccc0cc00ccc0cccc0ccccccc0cc0cc000c00c000
-- 081:c0cc0c0ccccccc0c000000c0cccccc00cccccc00cccccc00cc00cc00c0000c00
-- 082:ccccc0c0ccccc0c0cc0cc00cccc0cc00ccc0cccc0ccccccc0cc0cc000c00c000
-- 083:c0cc0c0ccccccc0c000000c0c0000c00cccccc00cccccc00cc00cc00c0000c00
-- 084:00000ccc0000cccc0000cccc000cccccc00ccc0cc00ccc0c0ccccc0000cccccc
-- 085:0cccccc0c0000000cccccc000ccccc00cccccc00cccc00c0ccccc0c00cccc0cc
-- 086:00000ccc0000cccc0000cccc000ccccc0c0ccc0c0c0ccc0c0ccccc0000cccccc
-- 087:0cccccc0c0000000cccccc000ccccc00cccccc00cccc00c0ccccc0c00cccc0cc
-- 088:0ccccccc00ccccc00000cccc000ccccc000ccccc000ccccc00cc0ccc0000cc00
-- 089:0cccc0c0cccccc00ccccccc0cc0cccc0c0ccccc0c0ccccc0cc00ccc000cccc00
-- 090:0ccccccc00ccccc00000cccc000ccccc000ccccc000ccccc00cc0ccc0000cc00
-- 091:0cccc0c0cccccc00ccccccc0cc0cccc0c0ccccc0c0ccccc0cc00ccc000cccc00
-- 096:00000000000c0ccc00c00c00c0000cc00c0000cc0000000c00cccc0c0cccccc0
-- 097:0c00c000ccccccccccccc00ccc0c0c0cccccccc0ccc00000cc0ccccccc0c0c0c
-- 098:0000000000c00ccc000c0c000c000cc0c00000cc0000000c00cccc0c0cccccc0
-- 099:0c00c000ccccccccccccc00ccc0c0c0cccccccc0ccc00000cc0ccccccc0c0c0c
-- 100:00000000000000000c0000000c0000000c0000000c00000000c0000c00c000cc
-- 101:00c000c000ccccc00ccccccc0cc0c0cc00ccccc000ccccc0cccccccccccccccc
-- 102:0000000000000000000c0000000c0000000c0000000c000000c0000c0c0000cc
-- 103:00c000c000ccccc00ccccccc0cc0c0cc00ccccc000ccccc0cccccccccccccccc
-- 104:00000000000000000000000000c000000c0c0000c0cc00000ccc0000c0cccccc
-- 105:0c0c0c0000cccc0c00c0c0c000ccc0c0000ccc0c0cccc000ccccc000cc00c000
-- 106:00000000000000000000000000c000000c0c0000c0cc00000ccc0000c0cccccc
-- 107:0c0c0c0000cccc0000c0c0c000ccc0cc000ccc000cccc000ccccc000cc00c000
-- 112:ccccccccc0ccccccc0cccccc0cccc0000cc00ccc0c0c0c0c0c0c000000000000
-- 113:0c0cccccc0000000cccc00c00cc00000c0c0000000ccccc000c000c000000000
-- 114:ccccccccc0ccccccc0cccccc0cccc0000cc00ccc0c0c0c0c0c0c000000000000
-- 115:0c0cccccc0000000cccc00c00cc0000cc0c0000c00ccccc000c000c000000000
-- 116:00c00ccc0c00cccccc0cccccc00cccccc0ccccc0c0ccccc00c0cccc000cccccc
-- 117:ccccccccccccccc0ccccccc0ccccccc0ccccccc0cccc0cc00ccc0cc0c0ccc0cc
-- 118:0c000ccc0c00cccccc0cccccc00cccccc0ccccc0c0ccccc00c0cccc000cccccc
-- 119:ccccccccccccccc0ccccccc0ccccccc0ccccccc0cccc0cc00ccc0cc0c0ccc0cc
-- 120:0ccc0cccc0ccc0cc0ccc0ccc0cccc0cc00cc0c00000ccccc0000c00c00000c00
-- 121:cccc0c00cccc0c00ccc0c000cc0c000000c00000cc00000000000000c0000000
-- 122:0ccc0cccc0ccc0cc0ccc0ccc0cccc0cc00cc0c00000ccccc0000c00c00000c00
-- 123:cccc0c00cccc0c00ccc0c000cc0c000000c00000cc00000000000000c0000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db14053ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>


-- Dev Env
-- 1. Load this script on norns
-- 2. Open matron
-- 3. Reference any globals with `var = require 'var'`
-- 4. Save file (in vscode) and delete line from #3
-- 5. Use `rerun()` in matron to see changes

-- Reference
-- N/A

file_length = 1200
max_buffer = 300

cursor = 1
alt_2 = false

num_to_string = {'one', 'two', 'three', 'four', 'five', 'six'}

-- Add parameters for each of the 6 samples of the main file
function add_samples()
  for i = 1,6 do
    params:add_separator('Sample '..i)

    params:add{
      type='number', id='s_'..i..'_start', name='Sample '..i..' Start', 
      min=0, max=file_length, default=0
    }

    params:add{
      type='number', id='s_'..i..'_length', name='Sample '..i..' Length', 
      min=0, max=max_buffer, default=0
    }

    params:add{
      type='number', id='s_'..i..'_level', name='Sample '..i..' Level', 
      min=-math.huge, max=0, default=0
    }

    -- To set an action here for level, use util.dbamp(), as in screen below

    params:add{
      type='number', id='s_'..i..'_pan', name='Sample '..i..' Pan', 
      min=-1, max=1, default=0
    }

    params:add{
      type='number', id='s_'..i..'_rate', name='Sample '..i..' Rate', 
      min=-5, max=5, default=1
    }
  end
end

function init()
  -- Set initial sample values
  add_samples()
end

function draw_sample_line(i)
  line_start = params:get('s_'..i..'_start')
  line_start = math.floor((line_start / file_length) * 100)

  line_length = params:get('s_'..i..'_length')
  line_length = math.floor((line_length / file_length) * 100)

  line_end = util.clamp(14 + line_start + line_length, 14 + line_start, 114)
  
  -- amplitude between 0 and 1, exponential decibel changes
  line_level = params:get('s_'..i..'_level')
  line_level = util.dbamp(line_level)
  line_level = util.linlin(0, 1, 0, 15, line_level)
  line_level = math.floor(line_level + 0.5)

  -- Draw each line 4px below line above it
  screen.level(line_level)
  screen.move(14 + line_start, 10 + 4 * i)
  screen.line(line_end, 10 + 4 * i)
  screen.stroke()

  -- Draw rate (minimum defined is between -5 and 5 times the normal speed)
  line_rate = params:get('s_'..i..'_rate')
  line_rate = util.linlin(-5, 5, 0, line_length, line_rate)

  screen.move(14 + line_start + line_rate, 10 + 4 * i - 1)
  screen.line(14 + line_start + line_rate, 10 + 4 * i + 1)
  screen.stroke()
end

function draw_sample_pan(i)
  line_pan = params:get('s_'..i..'_pan')
  line_pan = 7 * line_pan

  -- Halfway between the end of the sample line and the edge of the screen is 0 pan
  screen.move(121 + line_pan, 10 + 4 * i - 1)
  screen.line(121 + line_pan, 10 + 4 * i + 1)
end

function write_param(name, value, move)
  screen.move(move[1], move[2])
  screen.text(name)
  screen.move(move[1] + 32, move[2])
  screen.text(value)
end

function draw_sample_params()
  -- TODO This got weird. Proabably need to move everything down or up or something
  write_param('s', num_to_string[cursor], {7, 44})
  
  s_level = params:get('s_'..cursor..'_level')
  write_param('level', s_level, {64, 44})

  s_start = params:get('s_'..cursor..'_start')
  write_param('start', s_start, {7, 54})

  s_length = params:get('s_'..cursor..'_length')
  write_param('length', s_length, {64, 54})

  s_rate = params:get('s_'..cursor..'_rate')
  write_param('rate', s_rate, {7, 64})

  s_pan = params:get('s_'..cursor..'_pan')
  write_param('pan', s_pan, {64, 64})
end

-- Draw the line for the sample beneath the main sample line
function draw_sample(i)
  draw_sample_pan(i)
  draw_sample_line(i)
  draw_sample_params()
end

function redraw()
  screen.clear()

  -- Annotate where the cursor is (referencing sample)
  screen.pixel(7, 10 + 4 * cursor)

  -- Draw audio file line (main line)
  screen.move(14, 10)
  screen.line(114, 10)
  screen.stroke()

  -- Draw sample line
  for i = 1, 6 do
    draw_sample(i)
  end

  screen.update()
end

function enc(n, i)
  -- Select sample
  if n == 1 then
    cursor = util.clamp(cursor + i, 1, 6)
  end

  if n == 2 then
    if alt_2 then
      curr_level = params:get('s_'..cursor..'_level')
      params:set('s_'..cursor..'_level', curr_level + i)
    elseif alt_3 then
      curr_rate = params:get('s_'..cursor..'_rate')
      params:set('s_'..cursor..'_rate', curr_rate + i * 0.2)
    else
      curr_start = params:get('s_'..cursor..'_start')
      params:set('s_'..cursor..'_start', curr_start + i)
    end
  end

  if n == 3 then
    if alt_3 then
      curr_pan = params:get('s_'..cursor..'_pan')
      params:set('s_'..cursor..'_pan', curr_pan + i / 10)
    else
      curr_length = params:get('s_'..cursor..'_length')
      params:set('s_'..cursor..'_length', curr_length + i)
    end
  end

  redraw()
end

function key(n, z)
  if n == 2 then
    if z == 1 then
      alt_2 = true
    else
      alt_2 = false
    end
  elseif n == 3 then
    if z == 1 then
      alt_3 = true
    else
      alt_3 = false
    end
  end
end

function rerun()
  norns.script.load(norns.state.script)
end
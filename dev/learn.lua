-- moments
--
-- Given 300 seconds (max)
-- of audio to play with,
-- record as much or as little 
-- into any point in that time.
--
-- Manage 4 different moments 
-- (looping subsamples) of that 
-- main audio timespan. 
-- Manipulate the level, pan, 
-- rate, loop start/stop, and
-- filter ban for each moment.
--
-- E1 - cursor (select moment)
-- K1 (hold) - toggle moment 
--
-- (After the cursor has been 
-- placed between rows 1-4)
-- E2 - start
-- E3 - length
-- K2 + E2 - level
-- K3 + E3 - pan
-- K3 + E2 - rate
-- K2 + E3 - loop end
-- K2 + K3 + E1 - record start
-- K2 + K3 - record/stop record
--
-- (After a moment is toggled 
-- & cursor is at row 5)
-- E2 - BP filter min freq 
--   (LP filter if furthest left)
-- E3 - BP filter bandwidth 
--   (HP filter if furthest right)

-- Adjust buffer_length and
-- max_moment in parameters

buffer_length = 600
max_moment = 300

cursor = 1
alt_2 = false

num_to_string = {'one', 'two', 'three', 'four', 'five', 'six'}

audio.level_cut(1) -- softcut master level (same as in LEVELS screen)
audio.level_adc_cut(1) -- adc to softcut input

softcut.buffer_clear()

-- Add parameters for each of the 6 moments of the main file
function add_moments()
  for i = 1,6 do
    params:add_separator('moment '..i)

    params:add{
      type='number', id='s_'..i..'_start', name='moment '..i..' Start', 
      min=0, max=buffer_length, default=0
    }

    params:add{
      type='number', id='s_'..i..'_length', name='moment '..i..' Length', 
      min=0, max=max_moment, default=0
    }

    params:add{
      type='number', id='s_'..i..'_level', name='moment '..i..' Level', 
      min=-math.huge, max=0, default=0
    }

    -- To set an action here for level, use util.dbamp(), as in screen below

    params:add{
      type='number', id='s_'..i..'_pan', name='moment '..i..' Pan', 
      min=-1, max=1, default=0
    }

    params:add{
      type='number', id='s_'..i..'_rate', name='moment '..i..' Rate', 
      min=-5, max=5, default=1
    }
  end
end

function init_stereo_moments()
  -- send audio input to softcut input

  for i=1,2 do
    softcut.buffer(1,i)
  end
end

function init_moments()
  for i=1,6 do
    
    softcut.loop_start(i,1)
    softcut.loop_end(i,6)  -- This seems to work
    softcut.loop(i,1)
    softcut.fade_time(i, 0.1) -- voice 1 fade time
    softcut.position(i,1)
    softcut.play(i,0)
    softcut.rate_slew_time(i,1)
    softcut.level_slew_time(i,0.1)
    softcut.pan_slew_time(i,1)
    softcut.enable(i,1)
  end
end

function init()
  -- Set initial moment values
  add_moments()
  init_moments()
end

function draw_moment_line(i)
  line_start = params:get('s_'..i..'_start')
  line_start = math.floor((line_start / buffer_length) * 100)

  line_length = params:get('s_'..i..'_length')
  line_length = math.floor((line_length / buffer_length) * 100)

  line_end = util.clamp(14 + line_start + line_length, 14 + line_start, 114)
  
  -- amplitude between 0 and 1, exponential decibel changes
  line_level = params:get('s_'..i..'_level')
  line_level = util.dbamp(line_level)
  line_level = util.linlin(0, 1, 0, 15, line_level)
  line_level = math.floor(line_level + 0.5)

  -- Draw each line 4px below line above it
  screen.level(line_level)
  screen.move(14 + line_start, 5 + 4 * i)
  screen.line(line_end, 5 + 4 * i)
  screen.stroke()

  -- Draw rate (minimum defined is between -5 and 5 times the normal speed)
  line_rate = params:get('s_'..i..'_rate')
  line_rate = util.linlin(-5, 5, 0, line_length, line_rate)

  screen.move(14 + line_start + line_rate, 5 + 4 * i - 1)
  screen.line(14 + line_start + line_rate, 5 + 4 * i + 1)
  screen.stroke()
end

function draw_moment_pan(i)
  line_pan = params:get('s_'..i..'_pan')
  line_pan = 7 * line_pan

  -- Halfway between the end of the buffer line and the edge of the screen is 0 pan
  screen.move(121 + line_pan, 5 + 4 * i - 1)
  screen.line(121 + line_pan, 5 + 4 * i + 1)
end

function write_param(name, value, move)
  screen.move(move[1], move[2])
  screen.text(name)
  screen.move(move[1] + 32, move[2])
  screen.text(value)
end

function draw_moment_params()
  write_param('.-.', num_to_string[cursor], {10, 42})
  
  s_level = params:get('s_'..cursor..'_level')
  write_param('...', s_level, {75, 42})

  s_start = params:get('s_'..cursor..'_start')
  write_param('.-', s_start, {10, 52})

  s_length = params:get('s_'..cursor..'_length')
  write_param('-.', s_length, {75, 52})

  s_rate = params:get('s_'..cursor..'_rate')
  s_rate = string.format("%.1f", s_rate)
  write_param('--', s_rate, {10, 62})

  s_pan = params:get('s_'..cursor..'_pan')
  s_pan = string.format("%.1f", s_pan)
  write_param('.|.', s_pan, {75, 62})
end

-- Draw the line for the moment beneath the main buffer line
function draw_moment(i)
  draw_moment_pan(i)
  draw_moment_line(i)
  draw_moment_params()
end

function redraw()
  screen.clear()

  -- Annotate where the cursor is (referencing moment)
  screen.pixel(7, 5 + 4 * cursor)

  -- Draw audio file line (main line)
  screen.move(14, 5)
  screen.line(114, 5)
  screen.stroke()

  -- Draw moment line
  for i = 1, 6 do
    draw_moment(i)
  end

  screen.update()
end

function enc(n, i)
  -- Select moment
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

function play_voice(i)
  softcut.level(i,1)
  softcut.position(i,1)
  softcut.rate(i,1)
  softcut.play(i,1)
end

function start_recording(i)
  recording = true
  softcut.level_input_cut(1,i,1)
  softcut.level_input_cut(2,i,1)
  softcut.rate_slew_time(i,0)  -- avoid recording slew sound
  softcut.level(i,1)
  softcut.rate(i,1)
  softcut.position(i,1)
  softcut.rec_level(i,1)
  softcut.pre_level(i,0.75)
  softcut.rec(i,1)
end

function stop_recording(i)
  recording = false
  softcut.rate_slew_time(i,1)
  softcut.rec(i,0)
end
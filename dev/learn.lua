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
-- The first two moments are
-- stereo, the second two are
-- mono.
--
-- E1 - cursor (select moment)
-- K1 (hold) - toggle moment 
-- K2 + E1 - position
--   (record start)
--
-- (After the cursor has been 
-- placed between rows 1-4)
-- E2 - start
-- E3 - length
-- K2 + E2 - level
-- K3 + E3 - pan
-- K3 + E2 - rate
-- K2 + E3 - rest (pause)
-- K2 + K3 + E1 - record start
-- K2 + K3 - record/stop record
--
-- (After a moment is toggled
--  & cursor is at row 5)
-- E2 - BP filter min freq
--   (LP if furthest left)
-- E3 - BP filter bandwidth
--   (HP if furthest right)
-- 
-- Adjust in Parameters Menu:
-- buffer length, max moment,
-- and overdub level

-- TODO: Fix the issue with level and screen.level
-- TODO: Capture fade_time in lower menu??

metro = require 'metro'

params:add{
  type='number', id='buffer_length', name='buffer length', 
  min=0, max=300, default=200
}

params:add{
  type='number', id='max_moment', name='maximum moment', 
  min=0, max=300, default=75
}

params:add{
  type='number', id='pre_level', name='overdub', 
  min=0, max=1, default=0.1
}

-- Current (initial) state
position = 0
cursor = 1
cursors = {false, false, false, false}  -- Selected moments

alt_2 = false
alt_3 = false

-- Portions of the buffer yet unrecorded
recorded = {}

num_to_string = {'one', 'two', 'three', 'four', 'filter'}

min_freq = 10  -- min frequency for band (otherwise, lp)
max_freq = 22000  -- max frequency for band (otherwise, hp)

audio.level_cut(1) -- softcut master level (same as in LEVELS screen)
audio.level_adc_cut(1) -- adc to softcut input
softcut.buffer_clear()

-- Add parameters for each of the 4 moments of the main file
function add_moments()
  buffer_length = params:get('buffer_length')
  max_moment = params:get('max_moment')

  for i = 1,4 do
    params:add_separator('moment '..i)

    params:add{
      type='number', id='m_'..i..'_start', name='moment '..i..' start', 
      min=0, max=buffer_length, default=0
    }

    params:add{
      type='number', id='m_'..i..'_length', name='moment '..i..' length', 
      min=0, max=max_moment, default=0
    }

    params:add{
      type='number', id='m_'..i..'_level', name='moment '..i..' level', 
      min=-math.huge, max=0, default=0
    }

    params:add{
      type='number', id='m_'..i..'_pan', name='moment '..i..' pan', 
      min=-1, max=1, default=0
    }

    params:add{
      type='number', id='m_'..i..'_rate', name='moment '..i..' rate', 
      min=-5, max=5, default=1
    }

    params:add{
      type='number', id='m_'..i..'_rest', name='moment '..i..' rest', 
      min=0, max=buffer_length, default=0
    }

    params:add{
      type='number', id='m_'..i..'_min_freq', name='moment '..i..' min freq', 
      min=min_freq, max=max_freq, default=min_freq
    }

    params:add{
      type='number', id='m_'..i..'_bandwidth', name='moment '..i..' bandwidth', 
      min=1, max=max_freq, default=max_freq
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
  for i=1,4 do
    softcut.loop_start(i,1)
    softcut.loop_end(i,6)  -- This seems to work if longer than loop
    softcut.loop(i,1)
    softcut.fade_time(i, 0.1) -- crossfade amount 
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
  buffer_length = params:get('buffer_length')

  line_start = params:get('m_'..i..'_start')
  line_start = math.floor((line_start / buffer_length) * 100)

  line_length = params:get('m_'..i..'_length')
  line_length = math.floor((line_length / buffer_length) * 100)

  line_end = util.clamp(14 + line_start + line_length, 14 + line_start, 114)
  
  -- amplitude between 0 and 1, exponential decibel changes
  line_level = params:get('m_'..i..'_level')
  line_level = util.dbamp(line_level)
  line_level = util.linlin(0, 1, 0, 15, line_level)
  line_level = math.floor(line_level + 0.5)  -- round

  -- Draw each line 4px below line above it
  screen.level(line_level)
  screen.move(14 + line_start, 5 + 4 * i)
  screen.line(line_end, 5 + 4 * i)
  screen.stroke()

  -- Draw rate (minimum defined is between -5 and 5 times the normal speed)
  line_rate = params:get('m_'..i..'_rate')
  line_rate = util.linlin(-5, 5, 0, line_length, line_rate)

  screen.move(14 + line_start + line_rate, 5 + 4 * i - 1)
  screen.line(14 + line_start + line_rate, 5 + 4 * i + 1)
  screen.stroke()
end

function draw_moment_pan(i)
  line_pan = params:get('m_'..i..'_pan')
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
  
  m_level = params:get('m_'..cursor..'_level')
  write_param('...', m_level, {75, 42})

  m_start = params:get('m_'..cursor..'_start')
  write_param('.-', m_start, {10, 52})

  m_length = params:get('m_'..cursor..'_length')
  write_param('-.', m_length, {75, 52})

  m_rate = params:get('m_'..cursor..'_rate')
  m_rate = string.format("%.1f", m_rate)
  write_param('--', m_rate, {10, 62})

  m_pan = params:get('m_'..cursor..'_pan')
  m_pan = string.format("%.1f", m_pan)
  write_param('.|.', m_pan, {75, 62})
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
  screen.pixel(2, 5 + 4 * cursor)

  -- Annotate selected cursors
  for c=1,#cursors do
    if cursors[c] then
      screen.pixel(8, 5 + 4 * c)
    end
  end

  -- Annotate where the position is (referencing the recording location)
  buffer_length = params:get('buffer_length')
  screen_position = util.linlin(0, buffer_length, 14, 114, position)
  screen.pixel(screen_position, 2)

  if alt_3 then
    screen.move(64, 35)
    min = math.floor(position / 60)
    sec = position % 60
    screen.text_center(min .. " : " .. sec)
  end

  -- Draw the recordings
  draw_clips()

  -- Draw moment lines
  for i = 1,4 do
    draw_moment(i)
  end

  screen.update()
end

function draw_clips()
  for i, r in pairs(recorded) do
    screen_start = util.linlin(0, buffer_length, 14, 114, r[1])
    screen_stop = util.linlin(0, buffer_length, 14, 114, r[2])
    screen.move(screen_start, 6)
    screen.line(screen_stop, 6)
    screen.level(15)
    screen.stroke()
  end
end

function enc(n, i)
  -- Select moment
  if n == 1 then
    if alt_3 then
      position = util.clamp(position + i, 0, params:get('buffer_length'))
    else
      cursor = util.clamp(cursor + i, 1, 4)
    end
  end

  -- For the current and toggled moments, adjust parameters
  for c_i, c_selected in pairs(cursors) do
    if c_i == cursor or c_selected then
      if n == 2 then
        if alt_2 then
          curr_level = params:get('m_'..c_i..'_level')
          params:set('m_'..c_i..'_level', curr_level + i)
        elseif alt_3 then
          curr_rate = params:get('m_'..c_i..'_rate')
          params:set('m_'..c_i..'_rate', curr_rate + i * 0.2)
        else
          curr_start = params:get('m_'..c_i..'_start')
          params:set('m_'..c_i..'_start', curr_start + i)
        end
      end
      if n == 3 then
        if alt_3 then
          curr_pan = params:get('m_'..c_i..'_pan')
          params:set('m_'..c_i..'_pan', curr_pan + i / 10)
        else
          curr_length = params:get('m_'..c_i..'_length')
          params:set('m_'..c_i..'_length', curr_length + i)
        end
      end
    end
  end

  redraw()
end

function toggle_recording()
  if not recording then
    start_recording()
  else
    stop_recording()
  end
end

function key(n, z)
  if n == 2 then
    if z == 1 then
      -- Toggle a moment
      cursors[cursor] = not cursors[cursor]
      alt_2 = true
      if alt_3 then
        toggle_recording()
      end
    else
      alt_2 = false
    end
  elseif n == 3 then
    if z == 1 then
      alt_3 = true
      if alt_2 then
        toggle_recording()
      end
    else
      alt_3 = false
    end
  end
  redraw()
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

function start_recording()
  recording = true
  start_position = position
  rec_position = position
  buffer_length = params:get('buffer_length')
  screen_start_position = util.linlin(0, buffer_length, 14, 114, start_position)

  -- Counting for recording
  time_unit = 0.1
  counter = metro.init(record, time_unit)
  counter:start()

  for i = 1,2 do
    softcut.level_input_cut(i,i,1)
    softcut.level_input_cut(i,i,1)
    softcut.rate_slew_time(i,0)  -- avoid recording slew sound
    softcut.level(i,1)
    softcut.rate(i,1)
    softcut.position(i,position)
    softcut.rec_level(i,1)
    softcut.pre_level(i,params:get('pre_level'))
    softcut.rec(i,1)
  end
end

function add_recording(start, stop)
  add_new = true
  
  -- Go through each recorded clip, and lengthen if need be
  for i,r in pairs(recorded) do
    -- Do we add to the end of a clip?
    if r[1] < start and start < r[2] and r[2] < stop then
      add_new = false
      recorded[i][2] = stop
      break
    -- Do we start a clip earlier?
    elseif start < r[1] and r[1] < stop and stop < r[2] then
      add_new = false
      recorded[i][1] = start
      break
    -- Is this a subset of another clip already?
    elseif r[1] < start and stop < r[2] then
      add_new = false
      break
    end
  end

  -- If this is an isolated recording, add a new clip
  if add_new then
    table.insert(recorded, {start, stop})
  end

end

function stop_recording()
  recording = false
  counter:stop()

  add_recording(start_position, rec_position)
  
  for i = 1,2 do
    softcut.rate_slew_time(i,1)
    softcut.rec(i,0)
  end

  redraw()
end

function record()
  rec_position = rec_position + time_unit

  if rec_position > params:get('buffer_length') then
    counter:stop()
    stop_recording()
  end

  -- Draw recording line
  screen_position = util.linlin(0, buffer_length, 14, 114, rec_position)
  screen.move(screen_start_position, 5)
  screen.line(screen_position, 5)
  screen.move(screen_start_position, 7)
  screen.line(screen_position, 7)
  screen.stroke()

  screen.update()
end

function whatsrecorded()
  for i=1,#recorded do
    print(i)
    tab.print(recorded[i]) 
  end
end
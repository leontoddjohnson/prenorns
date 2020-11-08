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

function add_samples()
  for i = 1,6 do
    params:add_separator('Sample '..i)

    params:add{
      type='number', id='s_'..i..'_start', name='Sample '..i..' Start', 
      min=0, max=file_length, default=0
    }

    params:add{
      type='number', id='s_'..i..'_length', name='Sample '..i..' Length', 
      min=0, max=file_length, default=0
    }

    params:add{
      type='number', id='s_'..i..'_level', name='Sample '..i..' Level', 
      max=0, default=0
    }

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

-- Draw the line for the sample beneath the main sample line
function draw_sample(i)
  line_start = params:get('s_'..i..'_start')
  line_start = math.floor((line_start / file_length) * 100)

  line_length = params:get('s_'..i..'_length')
  line_length = math.floor((line_length / file_length) * 100)

  -- Draw the line 4px below line above it
  screen.move(14 + line_start, 10 + 4 * i)

  line_end = util.clamp(14 + line_start + line_length, 14 + line_start, 114)
  screen.line(line_end, 10 + 4 * i)
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
    curr_start = params:get('s_'..cursor..'_start')
    params:set('s_'..cursor..'_start', curr_start + i)
  end

  if n == 3 then
    curr_length = params:get('s_'..cursor..'_length')
    params:set('s_'..cursor..'_length', curr_length + i)
  end

  redraw()
end

function rerun()
  norns.script.load(norns.state.script)
end
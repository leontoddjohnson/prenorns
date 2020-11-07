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

-- The start and end points for each sub-sample (in seconds)
samples = {
  {1, 200},
  {0, 0},
  {6, 300},
  {0, 0},
  {0, 0},
  {0, 0}
}

function draw_sample(i)
  line_start = samples[i][1]
  line_start = math.floor((line_start / file_length) * 100)

  line_end = samples[i][2]
  line_end = math.floor((line_end / file_length) * 100)

  -- Draw a line 4px below line above it
  screen.move(14 + line_start, 10 + 4 * i)
  screen.line(14 + line_end, 10 + 4 * i)
end

function redraw()
  screen.clear()

  -- Draw audio file line
  screen.move(14, 10)
  screen.line(114, 10)
  screen.stroke()

  for i = 1, 6 do
    draw_sample(i)
  end

  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
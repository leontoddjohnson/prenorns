-- Just testing some stuff

function redraw()
  screen.clear()
  screen.move(10, 10)
  screen.text("Now, we're in business.")
  screen.update()
end

function rerun()
  norns.script.load(norns.state.script)
end
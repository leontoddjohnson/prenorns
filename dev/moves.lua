file = _path.dust .. "audio/tehn/whirl1.aif"

sc = softcut

sc.buffer_clear()

function init()
  -- audio.level_adc_cut(1)
  sc.buffer_read_stereo(file, 1, 1, -1)
  
  sc.enable(1,1)
  sc.buffer(1,2)
  sc.level(1,1.0)
  sc.loop(1,1)
  sc.loop_start(1,1)
  sc.loop_end(1,5)
  sc.position(1,1)
  sc.rate(1,1.0)
  sc.play(1,1)

end

-- function enc(n, k)
--   enc_name = 'pan'
--   enc_value = 
  
-- end

function key(n,z)
  if n == 2 and z == 1 then
    sc.play(1, 0)
  end
end

-- function redraw()
--   screen.clear()
--   screen.move(10, 30)
--   screen.text(thing .. ": ")
--   screen.move(118,30)
--   screen.text_right(string.format("%.2f", rate))
--   screen.move(10,40)
--   screen.text("loop_start: ")
--   screen.move(118,40)
--   screen.text_right(string.format("%.2f",loop_start))
--   screen.move(10,50)
--   screen.text("loop_end: ")
--   screen.move(118,50)
--   screen.text_right(string.format("%.2f",loop_end))
--   screen.update()
-- end

-- function cleanup()
--   -- deinitialization
-- end
# Initial Login

```bash
ssh we@norns.local

norns/build/maiden-repl/maiden-repl
```

## 


## Quick Links

- [Connection](https://monome.org/docs/norns/play/#network-connect)
- [File Share](https://monome.org/docs/norns/fileshare/)
- [Softcut Buffer Read](https://monome.org/norns/modules/softcut.html#buffer_read_mono)

Login: **we**
password: **sleep**

## Handy Code

- [Tutorial](https://github.com/neauoire/tutorial) *(already cloned on woog)*
- [Compass Manual](https://compass-manual.glitch.me/) *(Not sure how this sounds yet)*

## Debugging

### SSH

When connected to WiFi, use `ssh we@norns.local` with password above.

### `engine`

`tab.print(engine.names)` - Get the available engines

## Push

Just plug in the Push. Maybe push the "User" button. Run these lines.

```
m = midi.connect()  -- Connect to the Push
m.event = function(data) tab.print(midi.to_msg(data)) end  -- Print event
```

To turn lights on:

```
m:note_on(note, velocity, 1)  -- velocity controls the color
```

*No idea of the color map, but 50 is white.*

To turn lights off:

```
m:note_off(note)
```

The main board runs from note `36` to note `99`.

For the knobs, they are `cc` controls, where counter-clockwise outputs value `127` and clockwise `1`.

See [this](https://help.ableton.com/hc/en-us/articles/209071249-Push-1-2-User-Mode-for-custom-MIDI-mappings) article.

## Terminology

Term | Rough Definition
--- | ---
*slew* | Portamento, sort of "slur"
ADC | Analog to Digital Converter
*pre* | **Preserve** $\in[0, 1]$, level of buffer to preserve at next pass (i.e., overdub)
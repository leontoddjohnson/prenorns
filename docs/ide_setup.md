# VSCode + norns

Create a comfortable working environment with the Visual Studio Code IDE and norns. Basic idea:

- **Use VSCode for coding**
- **Use Maiden for testing**

## 1 Cloning `norns`

In Maiden (which is awesome), we have access to several pre-defined scripts on initialization (e.g., `audio`, and `tab`). To get the same kind of access in our IDE, we need to have a cloned version of the [norns](https://github.com/monome/norns) repository. Go ahead and clone it to your local computer, wherever you like. Later, you'll be referencing the *lua* folder in that repo.

## 2 WiFi, SSH, and Matron

First (after plugging in the WiFi hub into the norns), make sure your laptop and [norns](https://monome.org/docs/norns/wifi-files/#wifi-connect) are connected to the same WiFi network.

1. Create an [SMB connection to norns](https://monome.org/docs/norns/wifi-files/#macOS) for sharing files. This tends to go faster if you use a hotspot!

2. You'll also want to connect (via [SSH](https://monome.org/docs/norns/advanced-access/#ssh)) to the norns. You can save this profile in your `.ssh/config` file like this:

    ```bash
    Host norns
        HostName norns.local OR <ip_address>
        User we
    ```

3. Run commands in [matron](https://monome.org/docs/norns/maiden/#repl) at the bottom of the Maiden console.

## 3 VS Code Setup

Open up VS Code, and open the folder where you keep your development code (presumably — preferably — a Git repo on norns somewhere). 

1. Go to the marketplace and install [the sumneko.lua Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua). 
   
2. In your User (or Workplace) settings, you can either place the following in your *settings.json* file, or you can manually update the corresponding settings in the UI by typing **Cmd + ,** in VS Code, and finding the so-named items.

    ```json
        "Lua.workspace.library": [
            "path/to/norns/lua"
        ],
        "Lua.diagnostics.disable": [
            "lowercase-global"
        ]
    ```
    The `"path/to/norns"` is exactly the path to the *norns* directory we cloned above, and the *lua* folder is specifically that subdirectory. You can also add any other paths that contain scripts you want to reference in here, but likely you'll reference those by calling `require` in your script.

    As for the disabled `"lowercase-global"` diagnostic, I just do that because I don't like squiggly lines all over the place with lowercase function names.

Now we should have all the wonderful autocompletion tools that VS Code and the Lua extension have to offer! Sleep soundly.

*Note: Sometimes, for this to work, you may need to type `midi = require 'midi'` at the top of your script (for instance, if you're using `midi`). Save it, and then you can delete the line. VS code caches the relationship for as long as the script file is open.*

## 4 Running Scripts

Okay, now that we have a functioning connection with norns, a nice IDE landscape, and Matron, we need to get our scripts to run in the norns environment.

Now, I haven't quite figured out a smoother way to initiate this process, but the basic idea is this:

1. *In the norns*, navigate to the script you're working on, and activate it.

2. Open Matron in the SSH norns terminal (if you haven't already) using the instructions above, and run `norns.script.load(norns.state.script)`. That should basically "rerun" the script that's already loaded. *Note: After you do this for the first time, you probably won't need to do it again!*

3. Now, to automate the process of rerunning your script each time you make an update (and want to see the results), add the following code to the bottom of your script, and then each time you want to rerun the script, run `rerun()` in Matron.

    ```lua
    function rerun()
        norns.script.load(norns.state.script)
    end
    ```

# Caveats

Just a few things I found while troubleshooting this:

- Don't ever `git pull` norns from within the `/norns` directory in your norns ... That was a messy boo-boo on my part. Just do the typical *SYSTEM > UPDATE* as designed :) 
- If you're going to change the name of a directory in the norns, make sure that either (A) the currently loaded script is *not* in that directory or (B) no script is loaded, or the system script is cleared.

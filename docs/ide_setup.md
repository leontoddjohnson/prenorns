# VSCode + norns

Create a comfortable working environment with the Visual Studio Code IDE and norns. *I'm using a 13" Macbook Pro, 2017.*

## 1 Cloning `norns`

In Maiden (which is awesome), we have access to several pre-defined scripts on initialization (e.g., `audio`, and `tab`). To get the same kind of access in our IDE, we need to have a cloned version of the [norns](https://github.com/monome/norns) repository. Go ahead and clone it to your local computer, wherever you like. Later, you'll be referencing the *lua* folder in that repo.

## 2 WiFi, SSH, and Matron

First (after plugging in the WiFi hub into the norns), make sure your laptop and norns are connected to the same WiFi network.

1. Create an SMB connection to the norns using **Cmd + K**. Then click *smb://norns.local*. Use the username **we** and the password **sleep**. You should now see the *dust* directory in your finder window under the *norns.local* network location.

2. You'll also want to connect (via SSH) to the norns. Open a terminal, and type `ssh we@norns.local`. The password, again, is **sleep**.

3. Now, you can open Matron by running

    ```bash
    norns/build/maiden-repl/maiden-repl
    ```

    To quit Matron, type `q` and **Enter**.

We'll use Matron in a bit.

## 3 VS Code Setup

Open up VS Code, and open the folder where you keep your development code (presumably — preferably — on norns somewhere). 

1. Go to the marketplace and install [the sumneko.lua Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua). 
   
2. In your User (or Workplace) settings, you can either place the following in your *settings.json* file, or you can manually update the corresponding settings in the UI by typing **Cmd + ,** in VS Code, and finding the so-named items.

    ```json
        "Lua.workspace.library": {
            "path/to/norns/lua": true
        },
        "Lua.diagnostics.disable": [
            "lowercase-global"
        ]
    ```
    The `"path/to/norns"` is exactly the path to the *norns* directory we cloned above, and the *lua* folder is specifically that subdirectory.

    As for the disabled diagnostic, I just do that because I don't like squiggly lines all over the place with lowercase function names.

Now we should have all the wonderful autocompletion tools that VS Code and the Lua extension have to offer. Sleep soundly.

## 4 Running Scripts

Okay, now that we have a functioning connection with norns, a nice IDE landscape, and Matron, we need to get our scripts to run in the norns environment.

Now, I haven't quite figured out a smoother way to initiate this process, but the basic idea is this:

1. *In the norns*, navigate to the script you're working on, and activate it.

2. Open Matron in the terminal (if you haven't already) using the instructions above.

3. Run `norns.script.load(norns.state.script)`
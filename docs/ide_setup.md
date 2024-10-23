# VSCode + norns

Create a comfortable working environment with the Visual Studio Code IDE and norns. Basic idea:

- **Use VSCode for coding**
- **Use Maiden for testing**

## Cloning `norns`

In Maiden (which is awesome), we have access to several pre-defined scripts on initialization (e.g., `audio`, and `tab`). To get the same kind of access in our IDE, we need to have a cloned version of the [norns](https://github.com/monome/norns) repository. Go ahead and clone it to your local computer, wherever you like. Later, you'll be referencing the *lua* folder in that repo.

## VS Code Setup

Open up VS Code, and open the folder where you keep your development code (presumably — preferably — a Git repo). 

1. Go to the marketplace and install [the sumneko.lua Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua). 
   
2. In your User settings, you can either place the following in your *settings.json* file, or you can manually update the corresponding settings in the UI by typing **Cmd + ,** in VS Code, and finding the so-named items.

    ```json
        "Lua.workspace.library": [
            "path/to/norns/lua"
        ],
        "Lua.diagnostics.disable": [
            "lowercase-global"
        ],
        "Lua.runtime.special": {
            "include": "require"
        }
    ```
    The `"path/to/norns"` is exactly the path to the *norns* directory we cloned above, and the *lua* folder is specifically that subdirectory. You can also add any other paths that contain scripts you want to reference in here, but likely you'll reference those by calling `require` in your script.

    As for the disabled `"lowercase-global"` diagnostic, I just do that because I don't like squiggly lines all over the place with lowercase function names.

Now we should have all the wonderful autocompletion tools that VS Code and the Lua extension have to offer! Sleep soundly.

### Norns in a Terminal

1. First (after plugging in the WiFi hub into the norns), make sure your laptop and [norns](https://monome.org/docs/norns/wifi-files/#wifi-connect) are connected to the same WiFi network.
2. Open up a new terminal in VSCode
3. Then, connect (via [SSH](https://monome.org/docs/norns/advanced-access/#ssh)) to the norns. You can save this profile in your `.ssh/config` file (on your computer, not norns) like this:

```bash
Host norns
    HostName norns.local OR <ip_address>
    User we
```

## Development

### Version Control

- Store (or fork) code in GitHub repositories.
- Clone those repositories (using HTTPS) onto Norns as well as on your computer.
- Use VSCode to amend code, and GitHub Desktop to commit/push.
- Pull updated code (and discard unstaged changes) on norns via SSH.

### Environment

I find it best to have two "screens" or "half-screens" next to one another:

| VSCode        | Maiden (browser)                                             |
| ------------- | ------------------------------------------------------------ |
| Writing Code* | Testing scripts                                              |
| SSH to norns  | Debugging in [matron](https://monome.org/docs/norns/maiden/#repl) |

*\*In addition to normal code writing, see Xeus-Lua below.*

## Xeus-Lua

Install [xeus-lua](https://github.com/jupyter-xeus/xeus-lua?tab=readme-ov-file#installation) with a few caveats:

- Replace `mamba` with `conda` to create environment, and also use `conda` to activate environment
- Only install `xeus-lua` with `conda install xeus-lua -c conda-forge` (i.e., no need to install jupyter lab)
- Install the [Jupyter extension for VS Code](https://marketplace.visualstudio.com/items?itemName=ms-toolsai.jupyter)

Open a scratch .ipynb notebook in VS Code, and select the "XLua" Kernel from the "Jupyter kernels" list. Use this as a "scratchbook" for trying out different Lua code. **This should also have access to the same norns system environment from above.**

# Caveats

Just a few things I found while troubleshooting this:

- **Don't try to `push` from norns.** Only `pull`; do the pushing locally on VSCode/GitHub Desktop.  
- If you're going to change the name of a directory in the norns, make sure that either (A) the currently loaded script is *not* in that directory or (B) no script is loaded, or the system script is cleared.
- Always refer to the norns docs over what's here.

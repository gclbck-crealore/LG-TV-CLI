<p align="center">
  <img src="assets/hero.jpg" alt="A laptop terminal running `tv netflix` next to a smart TV in a cozy living room" width="100%">
</p>

<h1 align="center">LG-TV-CLI</h1>

<p align="center">
  <b>Control your LG webOS TV from the terminal — or just ask Claude or ChatGPT.</b>
</p>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="Python 3.11+" src="https://img.shields.io/badge/python-3.11%2B-3776AB.svg">
  <img alt="MCP server" src="https://img.shields.io/badge/MCP-server-8A2BE2.svg">
  <img alt="macOS" src="https://img.shields.io/badge/tested%20on-macOS-lightgrey.svg">
</p>

```console
$ tv netflix
Opening Netflix.
$ tv volume 20
Volume: 20
$ tv notify "Dinner is ready!"
Notification shown.
```

- **One-word commands** for apps, volume, mute, HDMI inputs, on-screen messages and power off
- **Finds your TV automatically** on the local network and follows it if its IP address changes
- **Works with AI assistants** through a built-in [MCP](https://modelcontextprotocol.io) server: Claude Desktop, Claude Code, Codex and ChatGPT
- **Single file, zero setup pain**: `uv` installs the Python dependencies on first run

## Requirements

- An LG TV running **webOS**, on the same network as your computer
- On the TV: **Settings → Network → LG Connect Apps** turned **on** (this is what allows remote control over the network; the menu name can differ slightly between webOS versions)
- [`uv`](https://docs.astral.sh/uv/) — the installer offers to install it for you
- macOS (tested) or Linux

## Install

```sh
git clone https://github.com/gclbck-crealore/LG-TV-CLI.git
cd LG-TV-CLI
./install.sh
```

The installer:

1. checks for `uv` and offers to install it,
2. links the `tv` command into `~/.local/bin`,
3. **searches your network for LG TVs and lets you pick one**,
4. pairs with it — **accept the prompt on the TV screen with your remote** (one time only),
5. prints ready-to-paste configuration for Claude and Codex.

You can re-run discovery and pairing at any time with `tv setup`.

## Usage

| Command | What it does |
|---|---|
| `tv netflix` · `prime` · `youtube` · `blutv` · `exxen` | Open an app |
| `tv settings` | Open the TV settings menu |
| `tv live` | Go back to live TV |
| `tv volume` | Show the current volume |
| `tv volume 20` | Set the volume (0–100) |
| `tv volume +` / `tv volume -` | Volume up / down one step |
| `tv mute` | Toggle mute |
| `tv hdmi 2` | Switch to an HDMI input (1–4) |
| `tv notify "text"` | Show a notification on the TV screen |
| `tv off` | Turn the TV off |
| `tv status` | Show the TV model, what is on screen, and the volume |
| `tv apps` | List the IDs of every installed app |
| `tv discover` | Search the network for LG TVs |
| `tv setup` | Pick a TV, save it and pair |

Turkish aliases also work: `ayarlar`, `canli`, `ses`, `sessiz`, `mesaj`, `kapat`, `durum`, `uygulamalar`, `bul`, `kur`.

## Use it from Claude or ChatGPT

`tv mcp` runs LG-TV-CLI as an MCP server, so an AI assistant can control the TV when you ask it to (*"put on YouTube and turn the volume down a bit"*). Run `tv mcp-config` to print the exact commands for your machine — it uses absolute paths, because desktop apps do not see your shell's `PATH`.

Pair the TV with `tv setup` **before** connecting an assistant: the MCP server never starts a pairing prompt on its own.

**Tools the assistant gets:** `get_tv_status`, `open_tv_app`, `set_tv_volume`, `step_tv_volume`, `set_tv_mute`, `switch_tv_hdmi`, `show_tv_notification`, `turn_tv_off`.

### Claude Desktop

Add the block printed by `tv mcp-config` to `~/Library/Application Support/Claude/claude_desktop_config.json`, then restart Claude Desktop. It looks like this:

```json
{
  "mcpServers": {
    "lg-tv": {
      "command": "/Users/you/.local/bin/uv",
      "args": ["run", "--quiet", "--script", "/Users/you/LG-TV-CLI/tv", "mcp"]
    }
  }
}
```

### Claude Code and Codex CLI

```sh
claude mcp add lg-tv -- /Users/you/.local/bin/uv run --quiet --script /Users/you/LG-TV-CLI/tv mcp
codex mcp add lg-tv -- /Users/you/.local/bin/uv run --quiet --script /Users/you/LG-TV-CLI/tv mcp
```

### ChatGPT

ChatGPT connects to MCP servers over the internet, so it needs a public HTTPS address:

1. Start the HTTP server:
   ```sh
   tv mcp --http            # default port 8765, change with --port
   ```
   It prints a local URL like `http://127.0.0.1:8765/mcp/<secret>`.
2. Expose it with a tunnel, for example [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/trycloudflare/):
   ```sh
   cloudflared tunnel --url http://127.0.0.1:8765
   ```
3. In ChatGPT, turn on developer mode and add a custom connector (MCP server) with the tunnel URL **plus the same secret path**, e.g. `https://example.trycloudflare.com/mcp/<secret>`. The exact menu names in ChatGPT change over time; look for *Developer mode* and *Connectors*.

> **Security:** the secret path is the only thing protecting your TV. Anyone with the full URL can control it while the server and the tunnel are running. Don't share it. Stop the tunnel when you're done. To get a new secret, delete `~/.config/lgtv/mcp_token`.

## How it works

- **Discovery:** SSDP search for `urn:lge-com:service:webos-second-screen:1`. Every TV that answers is listed with its name and UUID.
- **Control:** the webOS second-screen WebSocket API (the one the LG mobile app uses), via [`aiowebostv`](https://github.com/home-assistant-libs/aiowebostv).
- **IP changes:** if the saved address stops answering, `tv` searches again for the saved UUID and updates the config.
- **MCP:** the official [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk). It speaks stdio for local assistants and streamable HTTP for ChatGPT.

## Configuration

| Path / variable | Purpose |
|---|---|
| `~/.config/lgtv/config.json` | Selected TV: address, name, UUID |
| `~/.config/lgtv/client_key` | Pairing key (permissions `600`) |
| `~/.config/lgtv/mcp_token` | Secret path for `tv mcp --http` (permissions `600`) |
| `LGTV_HOST` | Overrides the saved TV address |

## Troubleshooting

| Problem | Fix |
|---|---|
| `Could not connect to the TV` | Make sure the TV is on and LG Connect Apps is enabled. Run `tv setup` again. |
| `tv discover` finds nothing | Your computer and the TV must be on the same network. Some guest networks and mesh setups block discovery. Type the IP address manually in `tv setup`. |
| An app says it is not installed | Run `tv apps` to see the real app IDs on your TV. |
| The assistant says the TV is not paired | Run `tv setup` in a terminal first. |

## Limitations

- **Cannot turn the TV on.** When the TV is off, its network API is off too. Wake-on-LAN over Wi-Fi was tested and did not work on the test TV.
- Turning off only the screen is not supported on older webOS versions.
- Tested on an **LG 55UF8507 (2015, webOS 2.0)** over Wi-Fi. Newer webOS versions use the same API and are expected to work, but have not been tested yet.

## License

[MIT](LICENSE)

*LG and webOS are trademarks of LG Electronics. This project is not affiliated with or endorsed by LG Electronics.*

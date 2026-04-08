# @keenmate/pure-admin-icons-mcp

MCP server for searching 16,000+ open-source SVG icons from [icons.pureadmin.io](https://icons.pureadmin.io).

Search across **FluentUI**, **Font Awesome**, **Heroicons**, **Lucide**, and **Tabler** icon sets with a single tool. Get platform identifiers for iOS, Android, React, Vue, and Svelte.

## Tools

| Tool | Description |
|------|-------------|
| `get_usage_guide` | Read first if unsure how to use the server. Returns icon set overview, workflow, and tips. |
| `search_icons` | Search icons by name with filters for set, style, size. Returns names + SVG URLs. |
| `get_icon_detail` | Get full metadata for an icon: all sizes, platform identifiers, color method, phrases. |
| `get_icon_svg` | Fetch raw SVG content from a URL. |
| `list_icon_sets` | List all icon sets with styles, sizes, color methods, and counts. |

## Quick Start

### Claude Desktop

Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "icons": {
      "command": "npx",
      "args": ["-y", "@keenmate/pure-admin-icons-mcp"]
    }
  }
}
```

### Claude Code

```bash
claude mcp add icons -- npx -y @keenmate/pure-admin-icons-mcp
```

## Example Queries

Once connected, ask Claude:

- "Search for calendar icons"
- "Find arrow icons from Heroicons"
- "Show me Font Awesome brand icons for social media"
- "Get the SVG for a pen icon in outline style"
- "What icon sets are available?"
- "Find a 16px solid checkmark icon"

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `ICONS_API` | `https://icons.pureadmin.io` | API base URL |

## API Endpoints Used

- `GET /api/icons/search` — Search with filters (q, set, style, size, limit, format)
- `GET /api/icons/:id` — Icon detail with metadata
- `GET /api/icon-sets` — List icon sets
- `GET /icons/:set/:style/:filename` — SVG files
- `GET /llms.txt` — API documentation for LLMs

## Development

```bash
npm install
npm run dev     # Watch mode
npm run build   # Build
npm start       # Run locally
```

## License

MIT. Icon SVGs retain their original licenses.

Built by [KeenMate](https://keenmate.com).

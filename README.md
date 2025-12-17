# Workday MCP Atlassian

> **Internal Workday Fork** of [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)

Model Context Protocol (MCP) server for Atlassian products (Confluence and Jira). This integration supports both Confluence & Jira Cloud and Server/Data Center deployments.

## 📦 Docker Image

```
docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest
```

## Example Usage

Ask your AI assistant to:

- **📝 Automatic Jira Updates** - "Update Jira from our meeting notes"
- **🔍 AI-Powered Confluence Search** - "Find our OKR guide in Confluence and summarize it"
- **🐛 Smart Jira Issue Filtering** - "Show me urgent bugs in PROJ project from last week"
- **📄 Content Creation & Management** - "Create a tech design doc for XYZ feature"

### Compatibility

| Product        | Deployment Type    | Support Status              |
|----------------|--------------------|-----------------------------|
| **Confluence** | Cloud              | ✅ Fully supported           |
| **Confluence** | Server/Data Center | ✅ Supported (version 6.0+)  |
| **Jira**       | Cloud              | ✅ Fully supported           |
| **Jira**       | Server/Data Center | ✅ Supported (version 8.14+) |

## Quick Start Guide

### 🔐 1. Authentication Setup

MCP Atlassian supports three authentication methods:

#### A. API Token Authentication (Cloud) - **Recommended**

1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click **Create API token**, name it
3. Copy the token immediately

#### B. Personal Access Token (Server/Data Center)

1. Go to your profile (avatar) → **Profile** → **Personal Access Tokens**
2. Click **Create token**, name it, set expiry
3. Copy the token immediately

### 📦 2. Installation

#### Pull from Workday Artifactory

```bash
# Login to Artifactory (if not already logged in)
docker login docker-dev-artifactory.workday.com

# Pull the image
docker pull docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest
```

## 🛠️ IDE Integration (Cursor)

### Step 1: Open Cursor MCP Settings

1. Open **Cursor Settings** (⌘ + , on Mac)
2. Navigate to **Features** → **MCP**
3. Click **+ Add new global MCP server**

Or directly edit: `~/.cursor/mcp.json`

### Step 2: Add Configuration

#### For Atlassian Cloud (API Token):

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "JIRA_URL",
        "-e", "JIRA_USERNAME",
        "-e", "JIRA_API_TOKEN",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_USERNAME",
        "-e", "CONFLUENCE_API_TOKEN",
        "docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest"
      ],
      "env": {
        "JIRA_URL": "https://your-company.atlassian.net",
        "JIRA_USERNAME": "your.email@workday.com",
        "JIRA_API_TOKEN": "your_jira_api_token",
        "CONFLUENCE_URL": "https://your-company.atlassian.net/wiki",
        "CONFLUENCE_USERNAME": "your.email@workday.com",
        "CONFLUENCE_API_TOKEN": "your_confluence_api_token"
      }
    }
  }
}
```

#### For Server/Data Center (Personal Access Token):

```json
{
  "mcpServers": {
    "mcp-atlassian": {
      "command": "docker",
      "args": [
        "run",
        "--rm",
        "-i",
        "-e", "JIRA_URL",
        "-e", "JIRA_PERSONAL_TOKEN",
        "-e", "CONFLUENCE_URL",
        "-e", "CONFLUENCE_PERSONAL_TOKEN",
        "docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest"
      ],
      "env": {
        "JIRA_URL": "https://jira.workday.com",
        "JIRA_PERSONAL_TOKEN": "your_jira_pat",
        "CONFLUENCE_URL": "https://confluence.workday.com",
        "CONFLUENCE_PERSONAL_TOKEN": "your_confluence_pat"
      }
    }
  }
}
```

### Step 3: Restart Cursor

After saving the configuration, restart Cursor for the MCP server to load.

## ⚙️ Configuration Options

### Common Environment Variables

| Variable | Description |
|----------|-------------|
| `JIRA_URL` | Jira instance URL |
| `JIRA_USERNAME` | Jira username/email (Cloud) |
| `JIRA_API_TOKEN` | Jira API token (Cloud) |
| `JIRA_PERSONAL_TOKEN` | Jira PAT (Server/DC) |
| `CONFLUENCE_URL` | Confluence instance URL |
| `CONFLUENCE_USERNAME` | Confluence username/email (Cloud) |
| `CONFLUENCE_API_TOKEN` | Confluence API token (Cloud) |
| `CONFLUENCE_PERSONAL_TOKEN` | Confluence PAT (Server/DC) |
| `JIRA_PROJECTS_FILTER` | Comma-separated project keys to filter |
| `CONFLUENCE_SPACES_FILTER` | Comma-separated space keys to filter |
| `READ_ONLY_MODE` | Set to "true" to disable write operations |
| `JIRA_SSL_VERIFY` | Set to "false" for self-signed certs |
| `CONFLUENCE_SSL_VERIFY` | Set to "false" for self-signed certs |

### Read-Only Mode

For safer production use, enable read-only mode:

```json
"args": [
  "run", "--rm", "-i",
  "-e", "JIRA_URL",
  "-e", "JIRA_PERSONAL_TOKEN",
  "-e", "READ_ONLY_MODE",
  "docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest"
],
"env": {
  "READ_ONLY_MODE": "true",
  ...
}
```

### Filter to Specific Projects/Spaces

```json
"env": {
  "JIRA_PROJECTS_FILTER": "PROJ1,PROJ2",
  "CONFLUENCE_SPACES_FILTER": "TEAM,DOCS",
  ...
}
```

### Skip SSL Verification (for self-signed certs)

```json
"env": {
  "JIRA_SSL_VERIFY": "false",
  "CONFLUENCE_SSL_VERIFY": "false",
  ...
}
```

## 🔧 Tools

### Jira Tools

| Tool | Description |
|------|-------------|
| `jira_get_issue` | Get details of a specific issue |
| `jira_search` | Search issues using JQL |
| `jira_create_issue` | Create a new issue |
| `jira_update_issue` | Update an existing issue |
| `jira_transition_issue` | Transition an issue to a new status |
| `jira_add_comment` | Add a comment to an issue |
| `jira_get_all_projects` | List all accessible projects |
| `jira_get_project_issues` | Get issues for a project |
| `jira_get_transitions` | Get available status transitions |
| `jira_get_agile_boards` | Get agile boards |
| `jira_get_sprints_from_board` | Get sprints from a board |
| `jira_get_sprint_issues` | Get issues in a sprint |

### Confluence Tools

| Tool | Description |
|------|-------------|
| `confluence_search` | Search Confluence content using CQL |
| `confluence_get_page` | Get content of a specific page |
| `confluence_create_page` | Create a new page |
| `confluence_update_page` | Update an existing page |
| `confluence_get_page_children` | Get child pages |
| `confluence_get_comments` | Get page comments |
| `confluence_add_comment` | Add a comment to a page |

## 🔍 Troubleshooting

### Common Issues

- **Authentication Failures**:
  - For Cloud: Check your API tokens (not your account password)
  - For Server/Data Center: Verify your personal access token is valid and not expired

- **SSL Certificate Issues**: 
  - If using Server/Data Center and encounter SSL errors, set `JIRA_SSL_VERIFY=false` or `CONFLUENCE_SSL_VERIFY=false`

- **Permission Errors**: 
  - Ensure your Atlassian account has sufficient permissions to access the spaces/projects

- **Docker Image Not Found**:
  - Make sure you're logged into Artifactory: `docker login docker-dev-artifactory.workday.com`

### Enable Verbose Logging

Add `-v` or `-vv` flag for more detailed logs:

```json
"args": [
  "run", "--rm", "-i",
  "-e", "JIRA_URL",
  "-e", "JIRA_PERSONAL_TOKEN",
  "docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest",
  "-v"
]
```

## 🏗️ Building Locally

For development or customization:

```bash
# Clone the repo
git clone <this-repo>
cd wd-mcp-atlassian

# Build locally
docker build -t mcp-atlassian:local .

# Test locally
docker run --rm mcp-atlassian:local --help
```

### Publishing to Artifactory

```bash
# Login
docker login docker-dev-artifactory.workday.com

# Tag
docker tag mcp-atlassian:local docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest
docker tag mcp-atlassian:local docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:X.Y.Z

# Push
docker push docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:latest
docker push docker-dev-artifactory.workday.com/docker-public-repos/workday-mcp-atlassian:X.Y.Z
```

## 🔒 Security

- Never share API tokens or Personal Access Tokens
- Keep .env files secure and private
- Use `READ_ONLY_MODE=true` when write access is not needed
- See [SECURITY.md](SECURITY.md) for best practices

## 📄 License

Licensed under MIT - see [LICENSE](LICENSE) file.

---

**Upstream**: This is a fork of [sooperset/mcp-atlassian](https://github.com/sooperset/mcp-atlassian)

# ============================================================
# Claude Code Full Setup - Windows PowerShell
# One-liner: irm https://gist.githubusercontent.com/RAW_URL | iex
# ============================================================

param(
  [switch]$SkipNode,
  [switch]$SkipOMC,
  [string]$MacSCP
)

$ErrorActionPreference = "Continue"
$H = $env:USERPROFILE

function Write-Step($num, $total, $msg) {
  Write-Host "`n=== [$num/$total] $msg ===" -ForegroundColor Cyan
}

Write-Host @"
   _____ _                 _         ____       _
  / ____| |               | |       / ___|  ___| |_ _   _ _ __
 | |    | | __ _ _   _  __| | ___  \___ \ / _ \ __| | | | '_ \
 | |____| |/ _` | | | |/ _` |/ _ \  ___) |  __/ |_| |_| | |_) |
  \_____|_|\__,_|\__,_|\__,_|\___| |____/ \___|\__|\__,_| .__/
                                                         |_|
  Claude Code + OMC + Claude-Flow + 36 Skills
"@ -ForegroundColor Magenta

$totalSteps = 8

# --- Step 1: Node.js ---
Write-Step 1 $totalSteps "Node.js pruefen"
if (!$SkipNode -and !(Get-Command node -ErrorAction SilentlyContinue)) {
  Write-Host "  Node.js nicht gefunden. Installiere via winget..." -ForegroundColor Yellow
  winget install OpenJS.NodeJS.LTS --accept-source-agreements --accept-package-agreements
  $env:PATH = "$env:ProgramFiles\nodejs;$env:PATH"
  Write-Host "  WICHTIG: PowerShell neu starten falls 'node' nicht erkannt wird!" -ForegroundColor Yellow
} else {
  Write-Host "  Node $(node -v) | npm $(npm -v)" -ForegroundColor Green
}

# --- Step 2: npm packages ---
Write-Step 2 $totalSteps "Claude Code + OMC + Claude-Flow installieren"
$packages = @("@anthropic-ai/claude-code", "oh-my-claude-sisyphus", "@claude-flow/cli@latest")
foreach ($pkg in $packages) {
  Write-Host "  npm i -g $pkg" -ForegroundColor DarkGray
  npm install -g $pkg 2>&1 | Out-Null
}
Write-Host "  3 Pakete installiert" -ForegroundColor Green

# --- Step 3: Directory structure ---
Write-Step 3 $totalSteps "Verzeichnisse anlegen"
$dirs = @(
  "$H\.claude",
  "$H\.claude\skills",
  "$H\.claude\skills\prompt-library",
  "$H\.claude\skills\prompt-library\scripts",
  "$H\.claude\plugins\marketplaces",
  "$H\.agents\skills",
  "$H\.omc\state",
  "$H\.omc\plans",
  "$H\.omc\research",
  "$H\.omc\logs"
)
foreach ($d in $dirs) {
  New-Item -ItemType Directory -Force -Path $d | Out-Null
}
Write-Host "  $($dirs.Count) Verzeichnisse erstellt" -ForegroundColor Green

# --- Step 4: OMC Plugin junction ---
Write-Step 4 $totalSteps "OMC Plugin verlinken"
if (!$SkipOMC) {
  $omcGlobal = Join-Path (npm root -g).Trim() "oh-my-claude-sisyphus"
  $omcTarget = "$H\.claude\plugins\marketplaces\omc"
  if (Test-Path $omcGlobal) {
    if (!(Test-Path $omcTarget)) {
      New-Item -ItemType Junction -Path $omcTarget -Target $omcGlobal | Out-Null
    }
    Write-Host "  OMC -> $omcGlobal" -ForegroundColor Green
  } else {
    Write-Host "  WARNUNG: OMC Paket nicht unter npm root gefunden" -ForegroundColor Yellow
    Write-Host "  Manuell: New-Item -ItemType Junction -Path '$omcTarget' -Target (npm root -g)\oh-my-claude-sisyphus" -ForegroundColor Yellow
  }
}

# --- Step 5: Vercel-Labs Skills ---
Write-Step 5 $totalSteps "Vercel-Labs Skills (GitHub)"
$agentsDir = "$H\.agents\skills-repo"
if (!(Test-Path "$agentsDir\.git")) {
  Write-Host "  Klone vercel-labs/skills..." -ForegroundColor DarkGray
  git clone --depth 1 https://github.com/vercel-labs/skills.git $agentsDir 2>&1 | Out-Null
}
$vercelSkills = @(
  "find-skills",
  "code-review-excellence",
  "frontend-code-review",
  "webapp-testing",
  "create-beads-orchestration",
  "agent-orchestration-improve-agent",
  "agent-orchestration-multi-agent-optimize"
)
$linked = 0
foreach ($s in $vercelSkills) {
  $src = "$agentsDir\skills\$s"
  $dst = "$H\.claude\skills\$s"
  if ((Test-Path $src) -and !(Test-Path $dst)) {
    New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
    $linked++
  }
}
Write-Host "  $linked Skills verlinkt" -ForegroundColor Green

# --- Step 6: Claude-Flow Skills (SKILL.md stubs) ---
Write-Step 6 $totalSteps "Claude-Flow v3 Skills erstellen"
$cfSkills = @(
  @{n="agentdb-advanced";           d="Advanced AgentDB: QUIC sync, multi-DB, custom metrics"},
  @{n="agentdb-learning";           d="AI learning plugins with 9 RL algorithms"},
  @{n="agentdb-memory-patterns";    d="Persistent memory patterns for AI agents"},
  @{n="agentdb-optimization";       d="AgentDB performance: quantization, HNSW indexing"},
  @{n="agentdb-vector-search";      d="Semantic vector search with AgentDB"},
  @{n="github-code-review";         d="GitHub code review with AI swarm coordination"},
  @{n="github-multi-repo";          d="Multi-repository coordination and sync"},
  @{n="github-project-management";  d="GitHub project management with swarm coordination"},
  @{n="github-release-management";  d="GitHub release orchestration with AI swarms"},
  @{n="github-workflow-automation";  d="GitHub Actions workflow automation"},
  @{n="hooks-automation";           d="Automated coordination via Claude Code hooks"},
  @{n="pair-programming";           d="AI-assisted pair programming (driver/navigator)"},
  @{n="reasoningbank-agentdb";      d="ReasoningBank adaptive learning with AgentDB"},
  @{n="reasoningbank-intelligence"; d="Pattern recognition and strategy optimization"},
  @{n="skill-builder";              d="Create Claude Code Skills with YAML frontmatter"},
  @{n="sparc-methodology";          d="SPARC development with multi-agent orchestration"},
  @{n="stream-chain";               d="Stream-JSON chaining for multi-agent pipelines"},
  @{n="swarm-advanced";             d="Advanced swarm orchestration patterns"},
  @{n="swarm-orchestration";        d="Multi-agent swarms with agentic-flow"},
  @{n="v3-cli-modernization";       d="CLI modernization and hooks for v3"},
  @{n="v3-core-implementation";     d="Core DDD modules for claude-flow v3"},
  @{n="v3-ddd-architecture";        d="Domain-Driven Design architecture for v3"},
  @{n="v3-integration-deep";        d="Deep agentic-flow integration (ADR-001)"},
  @{n="v3-mcp-optimization";        d="MCP server and transport optimization"},
  @{n="v3-memory-unification";      d="Unified memory with HNSW (150x-12500x faster)"},
  @{n="v3-performance-optimization";d="Flash Attention 2.49x-7.47x speedup"},
  @{n="v3-security-overhaul";       d="Security architecture overhaul for v3"},
  @{n="v3-swarm-coordination";      d="15-agent hierarchical mesh coordination"},
  @{n="verification-quality";       d="Truth scoring and code quality verification"}
)
$created = 0
foreach ($skill in $cfSkills) {
  $dir = "$H\.claude\skills\$($skill.n)"
  if (!(Test-Path $dir)) {
    New-Item -ItemType Directory -Force -Path $dir | Out-Null
    @"
---
name: "$($skill.n)"
description: "$($skill.d)"
---

# $($skill.n)

$($skill.d)
"@ | Out-File -Encoding utf8 "$dir\SKILL.md"
    $created++
  }
}
Write-Host "  $created Skills erstellt" -ForegroundColor Green

# --- Step 7: Claude-Flow MCP ---
Write-Step 7 $totalSteps "Claude-Flow MCP Server registrieren"
try {
  claude mcp add claude-flow -- npx -y @claude-flow/cli@latest 2>&1 | Out-Null
  Write-Host "  MCP 'claude-flow' registriert" -ForegroundColor Green
} catch {
  Write-Host "  WARNUNG: MCP Registrierung fehlgeschlagen. Manuell: claude mcp add claude-flow -- npx -y @claude-flow/cli@latest" -ForegroundColor Yellow
}

# --- Step 8: CLAUDE.md ---
Write-Step 8 $totalSteps "CLAUDE.md einrichten"
$claudeMd = "$H\.claude\CLAUDE.md"
if ($MacSCP) {
  Write-Host "  Kopiere CLAUDE.md von $MacSCP ..." -ForegroundColor DarkGray
  scp "${MacSCP}:~/.claude/CLAUDE.md" $claudeMd 2>&1
} elseif (Test-Path $claudeMd) {
  Copy-Item $claudeMd "$claudeMd.bak" -Force
  Write-Host "  Bestehende CLAUDE.md gesichert -> CLAUDE.md.bak" -ForegroundColor Green
} else {
  Write-Host "  Keine CLAUDE.md gefunden." -ForegroundColor Yellow
  Write-Host "  Kopiere sie von deinem Mac:" -ForegroundColor Yellow
  Write-Host "    scp user@mac-ip:~/.claude/CLAUDE.md $claudeMd" -ForegroundColor White
}

# --- Summary ---
$skillCount = (Get-ChildItem "$H\.claude\skills" -Directory -ErrorAction SilentlyContinue).Count

Write-Host @"

  ============================================
       SETUP ABGESCHLOSSEN!
  ============================================

    Claude Code   installiert
    OMC           oh-my-claude-sisyphus
    Claude-Flow   MCP registriert
    Skills        $skillCount installiert

    Starte Claude Code:   claude
    OMC einrichten:       setup omc

  ============================================
"@ -ForegroundColor Green

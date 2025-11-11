# Documentation Index

Welcome to the comprehensive documentation for the 1453 WSL Bash Script project. This directory contains all documentation necessary for understanding, maintaining, and contributing to the project.

## 📚 Documentation Structure

### For LLM Coding Agents

#### 🎯 **[LLM_CODING_GUIDE.md](LLM_CODING_GUIDE.md)** - START HERE
**Purpose**: Quick-start guide for LLM coding agents to understand the project

**Contents**:
- Project type and purpose
- Critical file structure
- Execution methods
- Architecture patterns
- Common code patterns
- Adding new features
- Testing procedures

**Read this first if you're an LLM agent working with this codebase.**

---

### For Human Developers

#### 📖 **[PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md)**
**Purpose**: Comprehensive project documentation for human developers

**Contents**:
- Project purpose and goals
- Complete architecture breakdown
- Installation and deployment methods
- Technology stack details
- Module-by-module explanation
- Version history
- Troubleshooting guide
- Usage examples

**Best for**: Understanding the project holistically, architecture decisions, learning the system

---

#### 🔧 **[API_REFERENCE.md](API_REFERENCE.md)**
**Purpose**: Complete function and API reference

**Contents**:
- All public functions organized by module
- Function signatures and parameters
- Return values and exit codes
- Usage examples
- Dependencies and requirements
- Cross-references between functions

**Best for**: Looking up specific functions, understanding function behavior, implementation details

---

### For End Users

#### 📄 **[/workspace/1453-wsl-bash-script/README.md](/workspace/1453-wsl-bash-script/README.md)** (in parent directory)
**Purpose**: User guide and installation instructions

**Contents**:
- Quick installation guide
- Feature list
- Menu options
- Troubleshooting
- Credits and license

**Best for**: End users wanting to install and use the script

---

## 🗺️ Documentation Map

```
1453 WSL Bash Script Documentation

├── For LLM Agents
│   └── LLM_CODING_GUIDE.md ⭐ START HERE
│       ├── Quick start for AI agents
│       ├── Architecture patterns
│       ├── Code examples
│       └── How to add features
│
├── For Human Developers
│   ├── PROJECT_OVERVIEW.md
│   │   ├── Complete architecture
│   │   ├── Module details
│   │   └── Technology stack
│   │
│   └── API_REFERENCE.md
│       ├── All functions documented
│       ├── Parameters and returns
│       └── Usage examples
│
└── For End Users
    └── README.md (parent dir)
        ├── Installation guide
        └── User instructions
```

## 🎯 Which Document to Read?

| Your Role | Start With | Then Read |
|-----------|------------|-----------|
| **LLM Coding Agent** | LLM_CODING_GUIDE.md | API_REFERENCE.md |
| **New Developer** | PROJECT_OVERVIEW.md | API_REFERENCE.md |
| **Maintainer** | LLM_CODING_GUIDE.md | PROJECT_OVERVIEW.md |
| **Contributor** | PROJECT_OVERVIEW.md | API_REFERENCE.md |
| **End User** | README.md | (that's it!) |

## 📋 Quick Reference

### Common Tasks

**Installing the script:**
```bash
curl -fsSL https://raw.githubusercontent.com/altudev/1453-wsl-bash-script/master/install.sh | bash
```

**Running after installation:**
```bash
~/.1453-wsl-setup/1453-setup
```

**Checking syntax:**
```bash
bash -n src/linux-ai-setup-script.sh
```

**Finding a function:**
```bash
grep -n "^install_" src/modules/*.sh
```

### File Locations

| File | Purpose |
|------|---------|
| `src/linux-ai-setup-script.sh` | Main entry point |
| `install.sh` | One-line installer |
| `src/lib/` | Core libraries |
| `src/config/` | Configuration files |
| `src/modules/` | Feature modules |
| `fix-crlf.sh` | Windows line ending fixer |

### Key Functions

| Function | Purpose | Module |
|----------|---------|--------|
| `detect_package_manager()` | Auto-detect package manager | package-manager.sh |
| `reload_shell_configs()` | Update shell PATH | common.sh |
| `install_python()` | Install Python ecosystem | python.sh |
| `install_nvm()` | Install Node.js | javascript.sh |
| `install_php_version()` | Install PHP | php.sh |
| `install_claude_code()` | Install AI CLI | ai-cli.sh |
| `install_ai_frameworks_menu()` | Install AI frameworks | ai-frameworks.sh |

## 🔍 Navigation Tips

### Finding Functions
```bash
# List all functions
grep -h "^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*()" src/{lib,config,modules}/*.sh | sort

# Find function definition
grep -n "^install_python()" src/modules/python.sh

# Find where function is called
grep -r "install_python" src/ --include="*.sh"
```

### Understanding Module Dependencies
```bash
# See loading order
head -50 src/linux-ai-setup-script.sh

# Check what a module exports
grep "export -f" src/modules/*.sh
```

### Viewing Configuration
```bash
# See PHP versions supported
cat src/config/php-versions.sh

# See color codes
cat src/config/colors.sh
```

## 🛠️ Development Workflow

### 1. Understanding the Code
1. Read `LLM_CODING_GUIDE.md` for quick understanding
2. Review `PROJECT_OVERVIEW.md` for architecture
3. Use `API_REFERENCE.md` for function details

### 2. Making Changes
1. Identify correct module for your change
2. Follow loading order (see `src/linux-ai-setup-script.sh`)
3. Add `export -f` at end of module if creating new function
4. Update menu if adding user-facing feature
5. Test syntax with `bash -n`

### 3. Testing Changes
```bash
# Test main script
bash -n src/linux-ai-setup-script.sh

# Test all modules
for file in src/{lib,config,modules}/*.sh; do
    bash -n "$file" || echo "Error in $file"
done
```

### 4. Documentation Updates
After making changes:
1. Update `API_REFERENCE.md` if adding/changing functions
2. Update `PROJECT_OVERVIEW.md` if changing architecture
3. Update this index if adding new documentation files

## 📝 Writing Documentation

### For Functions
When documenting a function, include:
```markdown
### `function_name(param1, param2)`

**File**: `src/module/file.sh:LINE`

**Purpose**: What this function does

**Parameters**:
- `param1` (type): Description
- `param2` (type, optional): Description

**Returns**: Description of return value

**Usage Example**:
```bash
function_name "arg1" "arg2"
```

**Notes**:
- Important implementation details
- Dependencies
- Side effects
```

### For Modules
When documenting a module, include:
```markdown
## Module Name (`src/modules/module.sh`)

**Purpose**: What this module provides

**Dependencies**: Other files this module requires

**Functions**:
- `function1()` - Brief description
- `function2()` - Brief description

**Configuration**: Any config files or environment variables

**Usage**: How to use this module
```

## 🔗 External Links

- **Repository**: https://github.com/altudev/1453-wsl-bash-script
- **Issues**: https://github.com/altudev/1453-wsl-bash-script/issues
- **License**: MIT (see LICENSE.md)

## 📊 Documentation Statistics

- **Total Documentation Files**: 4
- **Total Lines of Documentation**: ~3,500
- **Functions Documented**: 50+
- **Modules Documented**: 14
- **Languages**: English (dev docs), Turkish (user docs)

## ✅ Checklist for Contributors

When contributing to this project:

- [ ] Read relevant documentation (LLM_CODING_GUIDE.md or PROJECT_OVERVIEW.md)
- [ ] Check API_REFERENCE.md for existing functions
- [ ] Make changes to appropriate module
- [ ] Test syntax: `bash -n src/...`
- [ ] Update documentation if needed
- [ ] Follow Turkish interface for user-facing text
- [ ] Use color codes (RED, GREEN, YELLOW, BLUE, CYAN, NC)
- [ ] Export new functions with `export -f`
- [ ] Reload shell configs after installing tools
- [ ] Handle PEP 668 for Python packages
- [ ] Auto-detect package manager (APT/DNF/YUM/Pacman)

## 🎓 Learning Path

### For New Developers
1. Start with `PROJECT_OVERVIEW.md`
2. Read `src/linux-ai-setup-script.sh` to understand loading order
3. Explore each module file to see implementation patterns
4. Check `API_REFERENCE.md` for function details
5. Make a small change (e.g., add a new tool) to practice

### For LLM Agents
1. Start with `LLM_CODING_GUIDE.md`
2. Focus on architecture patterns and common code patterns
3. Use `API_REFERENCE.md` for quick function lookups
4. Review `fix-crlf.sh` to understand self-healing mechanism

### For End Users
1. Read `/workspace/1453-wsl-bash-script/README.md`
2. Run installer: `curl -fsSL ... | bash`
3. Execute: `~/.1453-wsl-setup/1453-setup`

---

## 📞 Getting Help

If you need help with this project:

1. **Check the documentation** in this directory
2. **Search existing issues** at https://github.com/altudev/1453-wsl-bash-script/issues
3. **Create a new issue** if problem persists
4. **Review code** in relevant module files

---

**Note**: This documentation is stored in the `claudedocs/` directory to keep the main repository clean and focused on the script itself.

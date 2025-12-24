# TypeScript LSP Configuration

This document explains the TypeScript Language Server setup in this Neovim configuration and how to switch between different TypeScript LSP implementations.

## Quick Reference

**Switch LSP:**

```vim
:TSLspSwitch    " Interactive menu to switch between ts_ls and tsgo
```

**Check availability:**

```vim
:TSLspCheck     " See which LSPs are installed
```

**Update tsgo:**

```bash
pnpm update -g @typescript/native-preview
```

## Current Setup

This configuration uses **tsgo** (TypeScript 7 native port) instead of the traditional `typescript-language-server` (ts_ls) for TypeScript and JavaScript files.

### Why tsgo?

- **Faster performance**: Native Go implementation provides better speed, especially on large projects
- **TypeScript 7 features**: Access to the latest TypeScript 7 preview features
- **Same accuracy**: Produces identical type checking results as TypeScript 5.9

### Supported Features

- Type checking and diagnostics
- Code completion
- Go to definition/references
- Hover information
- Rename refactoring
- Code actions
- Formatting
- Signature help

## Installation

tsgo is installed globally via pnpm:

```bash
pnpm add -g @typescript/native-preview
```

Verify installation:

```bash
tsgo --version
# Should show: Version 7.0.0-dev.YYYYMMDD.X
```

## Updating tsgo

To get the latest version of tsgo:

```bash
# Update to the latest preview version
pnpm update -g @typescript/native-preview

# Verify the new version
tsgo --version

# Restart Neovim to use the updated version
```

The TypeScript team releases new preview versions frequently. Check the [microsoft/typescript-go](https://github.com/microsoft/typescript-go) repository for updates.

## Switching Between ts_ls and tsgo

### Interactive Switcher (Recommended)

This configuration includes a built-in interactive tool to switch between TypeScript LSP implementations.

**Commands:**

```vim
:TSLspSwitch    " Opens a menu to select and switch LSP
:TSLspCheck     " Check which LSPs are available on your system
```

**Usage:**

1. Open any TypeScript or JavaScript file
2. Run `:TSLspSwitch`
3. Select your preferred LSP from the menu
4. The LSP will automatically restart with the new implementation

The switcher will:

- Stop the current TypeScript LSP
- Configure and start the selected LSP
- Reload all TypeScript/JavaScript buffers
- Remember your preference for future sessions

### Manual Configuration

If you prefer to manually configure the LSP:

#### Switching to ts_ls (Traditional TypeScript Language Server)

1. **Install typescript-language-server** via Mason or globally:

   ```vim
   :Mason
   " Search for and install: typescript-language-server
   ```

2. **Update ts-lsp-switcher.lua** or set preference:

   In Neovim, run:

   ```vim
   :lua vim.g.ts_lsp_preference = "ts_ls"
   ```

   Then restart Neovim.

#### Switching Back to tsgo

1. **Ensure tsgo is installed**:

   ```bash
   pnpm add -g @typescript/native-preview
   ```

2. **Set preference**:

   ```vim
   :lua vim.g.ts_lsp_preference = "tsgo"
   ```

3. **Restart Neovim**

## Troubleshooting

### tsgo not attaching to TypeScript files

1. **Check if tsgo is in PATH**:

   ```bash
   which tsgo
   # Should show: /Users/[username]/Library/pnpm/tsgo
   ```

2. **Verify PNPM_HOME is in PATH**:

   ```bash
   echo $PNPM_HOME
   # Should show: /Users/[username]/Library/pnpm
   ```

3. **Check LSP status in Neovim**:

   ```vim
   :LspInfo
   ```

   Should show "Client: tsgo" attached to TypeScript files

4. **Check LSP logs**:
   ```vim
   :lua vim.cmd('e ' .. vim.lsp.get_log_path())
   ```
   Look for tsgo initialization errors

### Conflicting Language Servers

If you see multiple TypeScript LSPs (ts_ls, vtsls, tsgo) attaching:

1. **Remove conflicting servers from Mason**:

   ```bash
   rm -rf ~/.local/share/nvim/mason/packages/{typescript-language-server,vtsls}
   rm -rf ~/.local/share/nvim/mason/bin/{typescript-language-server,vtsls}
   ```

2. **Ensure only one TypeScript server is configured** in lsp.lua

3. **Clear Neovim cache** (optional):

   ```bash
   rm -rf ~/.local/state/nvim/
   rm -rf ~/.cache/nvim/
   ```

4. **Restart Neovim completely**

### tsgo crashes or panics

tsgo is still in preview and may have bugs. If you encounter crashes:

1. **Check GitHub issues**: [microsoft/typescript-go/issues](https://github.com/microsoft/typescript-go/issues)
2. **Update to latest version**: `pnpm update -g @typescript/native-preview`
3. **Temporarily switch to ts_ls** while waiting for fixes
4. **Report the issue** if it's not already known

## Testing Your Setup

Create a test TypeScript file:

```typescript
// test.ts
interface Person {
  name: string;
  age: number;
}

const user: Person = {
  name: "John",
  age: "thirty", // This should show a type error
};
```

Open it in Neovim and verify:

- Error appears under `"thirty"` (type mismatch)
- `:LspInfo` shows tsgo is attached
- Hover (`K`) over `Person` shows type information
- Go to definition (`gd`) works

## Additional Resources

- [TypeScript Go Repository](https://github.com/microsoft/typescript-go)
- [TypeScript Go Announcement](https://devblogs.microsoft.com/typescript/typescript-native-port/)
- [@typescript/native-preview on npm](https://www.npmjs.com/package/@typescript/native-preview)

## Current Status

**Last Updated**: December 24, 2025  
**tsgo Version**: 7.0.0-dev.20251223.1  
**Status**: Preview/Beta - suitable for development but may have bugs

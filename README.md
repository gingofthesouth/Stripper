# Stripper

`stripper` is a fast, tree-sitter-powered command-line tool written in Swift that analyzes source code files and interactively (or automatically) strips out comments.

## ✨ Features

- Supports multiple programming languages via [SwiftTreeSitter](https://github.com/tree-sitter/swift-tree-sitter):
  - Swift
  - C/C++
  - JavaScript/TypeScript
  - Python
  - Ruby
  - Go
  - Rust
- Process single files or entire directories recursively
- Interactive or non-interactive comment removal
- Comment summary with line numbers
- Code context display around comments with syntax highlighting
- Language-aware comment detection using tree-sitter parsing
- Smart handling of whole-line vs inline comments
- Processing comments in reverse order to maintain accurate line numbers
- Automatic query file installation

## 🚀 Usage

```bash
stripper <path> [--non-interactive] [--context-lines <number>]
```

### Options

- `<path>`: Path to the file or directory to process
- `-n, --non-interactive`: Run in non-interactive mode (automatically remove all comments)
- `--context-lines`: Number of context lines to display before and after each comment (default: 3)
- `--help`: Show help information
- `--version`: Show the version

### Examples

Interactive mode on a single file (default):
```bash
stripper path/to/source.swift
```

Non-interactive mode on a single file:
```bash
stripper path/to/source.swift --non-interactive
```

Process an entire directory with custom context:
```bash
stripper path/to/project-directory --context-lines 5
```

## 🧪 Development

```bash
make build           # build CLI
make run             # run stripper with help
make test            # run tests
make clean           # clean build artifacts
make setup-queries   # manually create query files (if needed)
make clean-queries   # remove all query files
make reset-queries   # remove and recreate query files
```

## 📦 Installation

Clone and build manually:

```bash
git clone https://github.com/yourusername/stripper
cd stripper
make install
```

This will:
1. Install the `stripper` executable to `/usr/local/bin/stripper`
2. Automatically create necessary Tree-Sitter query files in `~/.stripper/queries/`

All required query files are set up automatically during installation, so you can start using the tool immediately.

## Troubleshooting

If you encounter issues with comment detection:

1. **Reset Query Files**: Try resetting the query files:
   ```bash
   make reset-queries
   ```

2. **Permission Issues**: Make sure your user has write access to the `~/.stripper/queries` directory.

3. **Fallback Mode**: For Swift files, the tool includes a fallback regex-based approach if tree-sitter parsing fails.

## How It Works

Stripper uses [SwiftTreeSitter](https://github.com/tree-sitter/swift-tree-sitter) to parse source code and identify comments accurately. When run in interactive mode, it provides a summary of all comments found in the file and allows you to:

1. View all comments with their line numbers
2. Choose whether to proceed with comment removal
3. Selectively remove comments one by one with syntax-highlighted code preview
4. See context lines before and after each comment for better understanding

The tool intelligently handles:
- Full-line comments (removes the entire line)
- Inline comments (preserves the code, removes only the comment)

When processing directories, Stripper recursively traverses all subdirectories and processes each supported file, providing a summary at the end with the number of successfully processed files and any errors encountered.

### Directory Processing

When a directory is provided as input, Stripper will:
1. Recursively scan all subdirectories
2. Process only files with supported extensions
3. Display progress information for each file
4. Provide a summary at the end with statistics on processed and failed files

### Syntax Highlighting

Code context is displayed with language-specific syntax highlighting to make it easier to understand the code around comments. Different elements are color-coded:
- Keywords: Cyan
- Strings: Red
- Numbers: Blue
- Types: Green (Swift)
- Comments: Yellow (with the current comment highlighted in bold)

### To Do

1. Add testing. Normally I would have up front but this morphed from a personal tool I was making on the fly to deciding to refactor and release it for others to use.
2. Add support for more languages.

## 🔒 License

MIT © Ernest Cunningham

# Markdown to PDF Renderer

This toolkit provides an automated pipeline to convert Markdown files into PDF documents. It features automatic rendering of Mermaid diagrams, rich LaTeX-based syntax highlighting, and native support for GitHub-style callouts.

## Features

* **PDF Generation**: Converts Markdown to PDF using Pandoc and the XeLaTeX engine.
* **Mermaid Diagrams**: Automatically scans your Markdown for Mermaid code blocks and renders them using a Python script and Mermaid CLI.
* **GitHub-Style Callouts**: Converts standard Markdown blockquotes into beautifully styled LaTeX `tcolorbox` elements.
* **Advanced Syntax Highlighting**: Uses the LaTeX `listings` package with custom color profiles and UTF-8 character support.
* **Dynamic Tagging**: Optionally stamps your generated PDF with a randomized "Copy ID" in the footer and appends it to the filename.
* **Workspace Cleanup**: Includes a built-in command to quickly clean up generated image directories.

## Prerequisites & Setup

To use this script seamlessly, you must have the required dependencies installed on your system.

### 1. Install Dependencies

* **Pandoc**: The core document converter. Install from `https://pandoc.org/installing.html`.
* **Python**: Required to run the Mermaid diagram extraction script.
* **Mermaid CLI**: Required to generate the diagram images. Install via Node.js: `npm install -g @mermaid-js/mermaid-cli`.
* **LaTeX Distribution**: You need a LaTeX engine installed and added to your PATH because the script uses the `xelatex` engine.
    * *Required LaTeX Packages:* Your LaTeX distribution must support `fontawesome5`, `tcolorbox`, `float`, and `fancyhdr`.

### 2. File & Directory Structure

Since you have added the script's directory to your system's PATH, ensure the files are organized exactly like this so the batch script can reliably locate its resources:

```text
/
+-- render_md.bat
+-- generate_diagrams.py
+-- callout.lua
+-- mermaid-swap.lua
+-- resources/
    +-- tex/
        +-- listings-2.tex
```

 
*Note: If `listings-2.tex` is missing from the `resources\tex` directory, the script will throw an error and abort.*

## Usage Instructions

### Standard Conversion
To convert a Markdown file into a PDF:
```cmd
render_md my_document.md
```
This will generate the PDF in the same directory.

### Conversion with Dynamic Tagging
To append a randomized Copy ID to the filename and embed it in the PDF footer:
```cmd
render_md my_document.md /tag
```
* **Output:** Appends a dynamic Copy ID (e.g., `_12345-67890.pdf`) to the output file.
* **Effect:** Injects a custom LaTeX header/footer setup (`\pagestyle{fancy}`) that displays `ID Copie : <Random_ID> - Page \thepage` on every page.

### Cleanup Generated Images
The rendering process creates an `image` folder relative to your Markdown file to store the generated Mermaid diagrams. To delete this folder:
```cmd
render_md clean my_document.md
```
This will securely remove the `image` directory and its contents.

## Markdown Formatting Guide

### Mermaid Diagrams
For the `generate_diagrams.py` script to detect and render your diagrams, you **must** include an `image="..."` attribute inside the curly braces next to the mermaid declaration.

```markdown
` ` `mermaid { image="image/my_architecture.png" }
graph TD;
    A-->B;
` ` `
```
*(Note: Remove the spaces between the backticks in your actual markdown file)*

### Callouts (Admonitions)
The `callout.lua` filter natively converts GitHub callout syntax into LaTeX boxes. 

```markdown
> [!NOTE]
> This is a standard note.

> [!WARNING]
> This generates an orange warning box.

> [!IMPORTANT]
> This generates a red exclamation box.

> [!TIP]
> This generates a green lightbulb box.
```

### Code Blocks
Standard Markdown code blocks are styled using the `listings-2.tex` configuration. It automatically applies custom syntax highlighting colors and safely maps UTF-8 characters like `é`, `à`, `→`, and `—` to prevent LaTeX compilation errors.

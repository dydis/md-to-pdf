import re
import subprocess
import os
import sys
import shutil

# Get the markdown file from command line argument
if len(sys.argv) < 2:
    print("Error: No input file provided to generator script.")
    sys.exit(1)

MARKDOWN_FILE = sys.argv[1]
# Get the absolute path to the folder containing the markdown file
BASE_DIR = os.path.dirname(os.path.abspath(MARKDOWN_FILE))
# The temp file will be created in that same folder
TEMP_MMD_FILE = os.path.join(BASE_DIR, "temp_diagram.mmd")

# Configuration for mmdc
SCALE_FACTOR = "4"  # 1 is default (low quality). 4 is high quality (approx 300 DPI).
MMDC_CMD = "mmdc" # If 'mmdc' is not in PATH, put the full path here (e.g. "C:\\Users\\You\\...\\mmdc.cmd")

def generate_mermaid_images():
    print(f"🔍 Scanning {MARKDOWN_FILE} for Mermaid diagrams...")
    print(f"   Working Directory: {BASE_DIR}")
    
    # Check if mmdc is actually callable before scanning
    if shutil.which(MMDC_CMD) is None:
         print(f"❌ CRITICAL ERROR: The command '{MMDC_CMD}' was not found in your system PATH.")
         print("   Please run 'npm install -g @mermaid-js/mermaid-cli' or add it to your PATH.")
         sys.exit(1)

    try:
        with open(MARKDOWN_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
    except Exception as e:
        print(f"❌ Error reading markdown file: {e}")
        return

    # Regex looks for: ```mermaid { ... image="filename.png" ... }
    pattern = re.compile(r'```mermaid\s+\{.*?image="(.*?)".*?\}\n(.*?)```', re.DOTALL)
    matches = pattern.findall(content)

    if not matches:
        print("   No diagrams with 'image' attributes found.")
        return

    print(f"   Found {len(matches)} diagrams. Processing...")

    for output_filename, mermaid_code in matches:
        # Resolve absolute path for the output image
        output_path = os.path.join(BASE_DIR, output_filename)
        
        # 1. Save code to temp file
        try:
            with open(TEMP_MMD_FILE, "w", encoding='utf-8') as f:
                f.write(mermaid_code.strip())
        except IOError as e:
             print(f"❌ Error writing temp file: {e}")
             continue

        # 2. Run Mermaid CLI
        # We assume shell=True for Windows compatibility with .cmd files
        cmd = [MMDC_CMD, "-i", TEMP_MMD_FILE, "-o", output_path, "-b", "transparent", "-s", SCALE_FACTOR]
        
        print(f"   ⚙️  Generating: {output_filename}")
        
        try:
            # Capture output instead of suppressing it
            result = subprocess.run(
                cmd, 
                check=True, 
                shell=True, 
                capture_output=True, 
                text=True
            )
            # Optional: Print mmdc stdout if needed for success debugging
            # print(result.stdout) 

        except subprocess.CalledProcessError as e:
            print(f"\n❌ ERROR generating {output_filename}")
            print(f"   ---------------- DEBUG INFO ----------------")
            print(f"   Exit Code: {e.returncode}")
            print(f"   Command:   {' '.join(cmd)}")
            print(f"   STDOUT:    {e.stdout}")
            print(f"   STDERR:    {e.stderr}")
            print(f"   --------------------------------------------\n")
        except Exception as e:
             print(f"❌ Unexpected Python error: {e}")

    # Cleanup
    if os.path.exists(TEMP_MMD_FILE):
        try:
            os.remove(TEMP_MMD_FILE)
        except:
            pass
    
    print("✅ Process complete.")

if __name__ == "__main__":
    generate_mermaid_images()
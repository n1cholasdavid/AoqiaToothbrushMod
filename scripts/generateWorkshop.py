import fnmatch
import os
import shutil

SRC = "../"
DEST = "../dist/"

EXCLUDE_PATTERNS = [
    "*.py",
    "*.code-workspace",
    ".gitignore",
    ".luarc.json",
    "TODO.md",
    "README.md",
    "CHANGELOG.md",
    "*.clip",
    "*.fbx",
    "*.blend1",
]
EXCLUDED_DIRS = [".git", ".vscode", "dist", "scripts"]

print("Generating workshop files...")

if not os.path.exists(DEST):
    os.makedirs(DEST)

for dirpath, dirnames, filenames in os.walk(SRC):
    for excluded_dir in EXCLUDED_DIRS:
        if excluded_dir in dirpath:
            print("Matched directory\t", excluded_dir)
            break
    else:  # No excluded directory found
        for filename in filenames:
            for pattern in EXCLUDE_PATTERNS:
                if fnmatch.fnmatch(filename, pattern):
                    print("Matched pattern\t", pattern)
                    break
            else:
                src_file = os.path.join(dirpath, filename)
                dest_file = os.path.join(DEST, src_file[3:])
                os.makedirs(os.path.dirname(dest_file), exist_ok=True)
                shutil.copy2(src_file, dest_file)

print("Workshop files generated successfully.")

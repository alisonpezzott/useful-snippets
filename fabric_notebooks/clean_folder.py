# Snippet to clean the folder forced

from notebookutils import mssparkutils

base_path = "Files/"
all_files = mssparkutils.fs.ls(base_path)

for file in all_files:
    mssparkutils.fs.rm(file.path)
    print(f"✅ Deleted: {file.path}")

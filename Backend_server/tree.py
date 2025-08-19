import os

def generate_tree(directory, prefix="", excluded_dirs={"node_modules", ".git", "__pycache__"}):
    file_tree = ""
    files = sorted(os.listdir(directory))
    files = [f for f in files if not f.startswith('.')]  # Ẩn file/dir ẩn

    for index, file in enumerate(files):
        path = os.path.join(directory, file)

        if os.path.isdir(path) and file in excluded_dirs:
            continue  # Bỏ qua thư mục không mong muốn

        connector = "┗━ " if index == len(files) - 1 else "┣━ "
        file_tree += prefix + connector + file + "\n"

        if os.path.isdir(path):
            extension = "    " if index == len(files) - 1 else "┃   "
            file_tree += generate_tree(path, prefix + extension, excluded_dirs)
    return file_tree

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="Generate folder tree structure.")
    parser.add_argument("path", nargs="?", default=".", help="Path to root folder (default: current directory)")
    parser.add_argument("-o", "--output", help="Output file name (e.g., tree.txt)")

    args = parser.parse_args()
    result = generate_tree(args.path)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(result)
        print(f"✅ Đã lưu cây thư mục vào: {args.output}")
    else:
        print(result)

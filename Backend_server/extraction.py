import os
from pathlib import Path

# --- CẤU HÌNH ---
# 1. Đổi tên file output nếu bạn muốn
output_filename = "all_js_files.txt"

# 2. Thêm tên các thư mục hoặc file bạn muốn LOẠI TRỪ vào danh sách này
# Script sẽ bỏ qua bất kỳ file .js nào nằm trong các thư mục này
# hoặc có tên trùng với danh sách này.
exclusions = {
    "node_modules",  # Thư mục phổ biến cần loại trừ
    ".git",          # Thư mục git
    "build",         # Thư mục build
    "dist",          # Thư mục dist
    "vendor",        # Thư mục chứa thư viện bên thứ ba
    "bundle.js",     # Tên một file cụ thể cần bỏ qua
    "webpack.config.js",
    "migrate-mongo-config.js",
    "migrations",
    "dump",
    "__tests__",
}
# --- KẾT THÚC CẤU HÌNH ---

def should_exclude(path, exclusion_set, root_dir):
    """Kiểm tra xem một đường dẫn có nên bị loại trừ hay không."""
    try:
        # Lấy các phần của đường dẫn tương đối (ví dụ: ['src', 'component', 'main.js'])
        relative_parts = path.relative_to(root_dir).parts
        # Nếu bất kỳ phần nào của đường dẫn nằm trong danh sách loại trừ, trả về True
        return not exclusion_set.isdisjoint(relative_parts)
    except ValueError:
        return False

# Lấy đường dẫn thư mục hiện tại
current_directory = Path.cwd()
files_processed = 0
files_skipped = 0

try:
    with open(output_filename, "w", encoding="utf-8") as outfile:
        print("Bắt đầu quét các file .js...")
        
        # Tìm tất cả các file .js trong thư mục hiện tại và các thư mục con
        for js_file_path in current_directory.rglob("*.js"):
            # Kiểm tra xem file có nên bị loại trừ không
            if should_exclude(js_file_path, exclusions, current_directory):
                files_skipped += 1
                continue  # Bỏ qua file này và tiếp tục vòng lặp

            try:
                # Ghi header chứa đường dẫn file
                outfile.write("=" * 80 + "\n")
                outfile.write(f"// FILE PATH: {js_file_path.relative_to(current_directory)}\n")
                outfile.write("=" * 80 + "\n\n")

                # Đọc nội dung file và ghi ra output
                content = js_file_path.read_text(encoding="utf-8")
                outfile.write(content)
                outfile.write("\n\n")
                files_processed += 1
            
            except Exception as e:
                error_message = f"!!! Lỗi khi đọc file {js_file_path}: {e} !!!"
                outfile.write(error_message + "\n\n")
                print(error_message)

    print("-" * 30)
    print(f"✅ Hoàn thành!")
    print(f"📄 Đã xử lý và ghi: {files_processed} file.")
    print(f"🚫 Đã bỏ qua: {files_skipped} file (do nằm trong danh sách loại trừ).")
    print(f"💾 Toàn bộ nội dung đã được lưu vào file '{output_filename}'")

except Exception as e:
    print(f"❌ Đã xảy ra lỗi không mong muốn trong quá trình thực thi: {e}")
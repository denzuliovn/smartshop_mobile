import os
from pathlib import Path

# Tên file output
output_filename = "all_dart_files.txt"

# Lấy đường dẫn thư mục hiện tại nơi script được chạy
current_directory = Path.cwd()

try:
    # Mở file output để ghi, sử dụng encoding utf-8 để hỗ trợ ký tự đặc biệt
    with open(output_filename, "w", encoding="utf-8") as outfile:
        # Sử dụng pathlib để tìm tất cả file .dart một cách đệ quy
        # rglob('*.dart') sẽ tìm tất cả file khớp với mẫu *.dart trong thư mục hiện tại và các thư mục con
        dart_files = list(current_directory.rglob("*.dart"))
        
        print(f"Đã tìm thấy {len(dart_files)} file .dart. Bắt đầu ghi vào '{output_filename}'...")

        for dart_file_path in dart_files:
            try:
                # Ghi header chứa đường dẫn file
                outfile.write("=" * 80 + "\n")
                outfile.write(f"// FILE PATH: {dart_file_path.relative_to(current_directory)}\n")
                outfile.write("=" * 80 + "\n\n")

                # Đọc nội dung của file .dart và ghi vào file output
                content = dart_file_path.read_text(encoding="utf-8")
                outfile.write(content)
                outfile.write("\n\n")
            
            except Exception as e:
                # Ghi lỗi nếu không thể đọc được một file nào đó
                error_message = f"!!! Lỗi khi đọc file {dart_file_path}: {e} !!!"
                outfile.write(error_message + "\n\n")
                print(error_message)

    print(f"✅ Hoàn thành! Toàn bộ nội dung đã được lưu vào file '{output_filename}'")

except Exception as e:
    print(f"❌ Đã xảy ra lỗi không mong muốn: {e}")
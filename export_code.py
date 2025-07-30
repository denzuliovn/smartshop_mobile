import os
import datetime

# --- CẤU HÌNH ---
PROJECT_NAME = "SmartShop Mobile"
OUTPUT_FILENAME = "project_summary_for_ai.txt"

# Danh sách các file và thư mục cần lấy code
# Đường dẫn tương đối từ thư mục gốc của dự án Flutter
PATHS_TO_EXPORT = [
    "pubspec.yaml",
    "lib/main.dart",
    "lib/router.dart",
    "lib/core/",
    "lib/features/"
]

# Các file hoặc thư mục không cần lấy (ví dụ: file cache, file generated)
EXCLUDE_PATTERNS = [
    ".g.dart",      # Bỏ qua các file generated của build_runner
    ".freezed.dart",# Bỏ qua các file generated của freezed
    "__pycache__"   # Bỏ qua cache của Python
]
# --- KẾT THÚC CẤU HÌNH ---


def should_exclude(path):
    """Kiểm tra xem một đường dẫn có nên bị loại bỏ hay không."""
    for pattern in EXCLUDE_PATTERNS:
        if pattern in path:
            return True
    return False

def get_file_content(filepath):
    """Đọc nội dung của một file."""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            return f.read()
    except Exception as e:
        return f"--- Lỗi khi đọc file: {e} ---"

def generate_summary():
    """Tạo ra file tóm tắt dự án."""
    full_summary = []

    # --- Header ---
    full_summary.append("="*80)
    full_summary.append(f"TÓM TẮT DỰ ÁN FLUTTER - {PROJECT_NAME.upper()}")
    full_summary.append("="*80)
    full_summary.append(f"Tạo lúc: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
    full_summary.append("Dưới đây là toàn bộ code cần thiết của dự án. Hãy phân tích và chuẩn bị để tiếp tục hướng dẫn tôi.\n")
    
    # --- Prompt cho AI ---
    prompt = """
Bối cảnh: Tôi đang phát triển một ứng dụng di động thương mại điện tử tên là "SmartShop" bằng Flutter. Bạn sẽ đóng vai trò là chuyên gia lập trình Flutter, tiếp tục hướng dẫn tôi hoàn thành dự án này. Dự án được xây dựng dựa trên mã nguồn của một website hiện có với backend là Node.js/GraphQL. Toàn bộ giao diện và các luồng chức năng cơ bản đã được xây dựng, và chúng ta đang trong giai đoạn kết nối giao diện với API thật.

Nhiệm vụ của bạn: Hướng dẫn tôi từng bước để hoàn thành các tính năng còn lại, gỡ lỗi và tối ưu hóa ứng dụng. Hãy duy trì cách làm việc tương tác: bạn đưa ra hướng dẫn cho một bước, tôi thực hiện, và sau đó tôi sẽ nói "tiếp tục" để bạn hướng dẫn bước tiếp theo.

Dưới đây là toàn bộ thông tin về dự án tính đến thời điểm hiện tại.

---

### I. CHECKLIST TIẾN ĐỘ DỰ ÁN

- ✅ **Phase 1 & 2:** Nền tảng và Giao diện (Đã hoàn thành)
- ⏳ **Phase 3:** Kết nối Backend (Đang thực hiện)
  - ✅ **3.1 - 3.4:** Xác thực, Sản phẩm, Giỏ hàng, Đơn hàng (Đã hoàn thành)
  - ⬜ **3.5:** Kết nối các Tính năng Phụ (Bước tiếp theo)
- ⬜ **Phase 4:** Hoàn thiện & Tối ưu (Chưa bắt đầu)

---

### II. TOÀN BỘ CODE CỦA DỰ ÁN
"""
    full_summary.append(prompt)

    # --- Lấy nội dung các file ---
    for path in PATHS_TO_EXPORT:
        if os.path.isfile(path):
            if not should_exclude(path):
                content = get_file_content(path)
                full_summary.append("="*80)
                full_summary.append(f"FILE: {path.replace(os.sep, '/')}")
                full_summary.append("="*80)
                full_summary.append(content)
                full_summary.append("\n" + "="*80)
                full_summary.append(f"END OF FILE: {path.replace(os.sep, '/')}")
                full_summary.append("="*80 + "\n")
        elif os.path.isdir(path):
            for root, _, files in os.walk(path):
                for filename in sorted(files):
                    filepath = os.path.join(root, filename)
                    if not should_exclude(filepath) and filename.endswith('.dart'):
                        content = get_file_content(filepath)
                        full_summary.append("="*80)
                        full_summary.append(f"FILE: {filepath.replace(os.sep, '/')}")
                        full_summary.append("="*80)
                        full_summary.append(content)
                        full_summary.append("\n" + "="*80)
                        full_summary.append(f"END OF FILE: {filepath.replace(os.sep, '/')}")
                        full_summary.append("="*80 + "\n")

    # --- Footer ---
    full_summary.append("="*80)
    full_summary.append("KẾT THÚC TÓM TẮT DỰ ÁN")
    full_summary.append("="*80)

    # --- Ghi ra file ---
    try:
        with open(OUTPUT_FILENAME, 'w', encoding='utf-8') as f:
            f.write("\n".join(full_summary))
        print(f"\n✅ Thành công! Đã tạo file tóm tắt dự án tại: {os.path.abspath(OUTPUT_FILENAME)}")
        print("Bây giờ bạn có thể copy toàn bộ nội dung của file đó và gửi cho AI mới.")
    except Exception as e:
        print(f"\n❌ Lỗi khi ghi file: {e}")

if __name__ == "__main__":
    generate_summary()
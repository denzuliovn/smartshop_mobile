def tim_dong_khac_biet(file_a, file_b):
    """
    Tìm và in ra những dòng có trong file_a nhưng không có trong file_b.

    Args:
        file_a (str): Đường dẫn đến tệp thứ nhất.
        file_b (str): Đường dẫn đến tệp thứ hai.
    """
    try:
        with open(file_a, 'r', encoding='utf-8') as f_a:
            # Đọc tất cả các dòng và loại bỏ ký tự xuống dòng ở cuối
            lines_a = set(line.strip() for line in f_a)

        with open(file_b, 'r', encoding='utf-8') as f_b:
            lines_b = set(line.strip() for line in f_b)

        # Tìm những dòng có trong set A nhưng không có trong set B
        dong_khac_biet = lines_a - lines_b

        if dong_khac_biet:
            print(f"\n✨ Những dòng chỉ có trong '{file_a}':")
            for dong in sorted(list(dong_khac_biet)): # Sắp xếp để dễ theo dõi
                print(dong)
        else:
            print("\n✅ Không có dòng nào khác biệt. Mọi dòng trong file A đều có trong file B.")

    except FileNotFoundError as e:
        print(f"Lỗi: Không tìm thấy tệp '{e.filename}'. Vui lòng kiểm tra lại đường dẫn.")
    except Exception as e:
        print(f"Đã có lỗi xảy ra: {e}")

if __name__ == "__main__":
    # Yêu cầu người dùng nhập tên file
    ten_file_a = "D:\\GitHub\\server\\server\\graphql\\carts.js"
    ten_file_b = "D:\\GitHub\\mobile-smart-shop\\Server\\graphql\\carts.js"

    # Gọi hàm để xử lý
    tim_dong_khac_biet(ten_file_a, ten_file_b)
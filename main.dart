import 'dart:convert';
import 'dart:io';

class Product {
  int id;
  String name;
  int quantity;
  double price;
  String size;
  bool status;
  DateTime importDate;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.size,
    required this.status,
    required this.importDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'price': price,
        'size': size,
        'status': status,
        'importDate': importDate.toIso8601String(),
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'],
        name: json['name'],
        quantity: json['quantity'],
        price: json['price'],
        size: json['size'],
        status: json['status'],
        importDate: DateTime.parse(json['importDate']),
      );

  void display() {
    print(
        'ID: $id | Tên: $name | SL: $quantity | Giá: \$${price.toStringAsFixed(2)} | Size: $size | Tình trạng: ${status ? "Mới" : "Cũ"} | Ngày: ${importDate.day}/${importDate.month}/${importDate.year}');
  }
}

List<Product> productList = [];
int nextId = 1;

void main() async {
  while (true) {
    print('\n====== MENU ======');
    print('1. Thêm sản phẩm');
    print('2. Sửa sản phẩm');
    print('3. Xóa sản phẩm');
    print('4. Duyệt danh sách sản phẩm');
    print('5. Lưu vào file');
    print('6. Mở file');
    print('7. Thoát');
    stdout.write('Chọn: ');
    var choice = stdin.readLineSync();

    switch (choice) {
      case '1':
        addProduct();
        break;
      case '2':
        editProduct();
        break;
      case '3':
        deleteProduct();
        break;
      case '4':
        viewAllProducts();
        break;
      case '5':
        await saveToFile();
        break;
      case '6':
        await loadFromFile();
        break;
      case '7':
        return;
      default:
        print('❌ Lựa chọn không hợp lệ!');
    }
  }
}

void addProduct() {
  stdout.write('Tên sản phẩm: ');
  String name = stdin.readLineSync() ?? '';
  if (name.length < 2 || name.length > 32) {
    print('❌ Tên phải từ 2-32 ký tự!');
    return;
  }

  stdout.write('Số lượng: ');
  int quantity = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (quantity < 0) {
    print('❌ Số lượng không hợp lệ!');
    return;
  }

  stdout.write('Đơn giá: ');
  double price = double.tryParse(stdin.readLineSync() ?? '') ?? -1;
  if (price < 0) {
    print('❌ Đơn giá không hợp lệ!');
    return;
  }

  stdout.write('Kích cỡ (S, M, L, X): ');
  String size = stdin.readLineSync() ?? '';
  if (!['S', 'M', 'L', 'X'].contains(size)) {
    print('❌ Kích cỡ không hợp lệ!');
    return;
  }

  stdout.write('Tình trạng (true=mới, false=cũ): ');
  bool status = stdin.readLineSync()?.toLowerCase() == 'true';

  stdout.write('Ngày nhập (dd/MM/yyyy): ');
  String dateInput = stdin.readLineSync() ?? '';
  DateTime? date;
  try {
    List<String> parts = dateInput.split('/');
    if (parts.length != 3) throw FormatException();
    int day = int.parse(parts[0]);
    int month = int.parse(parts[1]);
    int year = int.parse(parts[2]);
    date = DateTime(year, month, day);
  } catch (e) {
    print('❌ Ngày nhập không hợp lệ! Định dạng đúng là dd/MM/yyyy (VD: 20/06/2025)');
    return;
  }

  productList.add(Product(
    id: nextId++,
    name: name,
    quantity: quantity,
    price: price,
    size: size,
    status: status,
    importDate: date,
  ));
  print('✅ Đã thêm sản phẩm.');
}

void editProduct() {
  stdout.write('Nhập ID sản phẩm cần sửa: ');
  int id = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  var index = productList.indexWhere((p) => p.id == id);
  if (index == -1) {
    print('❌ Không tìm thấy sản phẩm!');
    return;
  }

  var product = productList[index];

  print('Sửa thông tin (bỏ trống nếu không đổi):');
  stdout.write('Tên mới: ');
  String newName = stdin.readLineSync() ?? '';
  if (newName.isNotEmpty) product.name = newName;

  stdout.write('Số lượng mới: ');
  String? qtyInput = stdin.readLineSync();
  if (qtyInput != null && qtyInput.isNotEmpty)
    product.quantity = int.tryParse(qtyInput) ?? product.quantity;

  stdout.write('Giá mới: ');
  String? priceInput = stdin.readLineSync();
  if (priceInput != null && priceInput.isNotEmpty)
    product.price = double.tryParse(priceInput) ?? product.price;
    stdout.write('Kích cỡ mới (S, M, L, X): ');
    String? sizeInput = stdin.readLineSync();
    if (sizeInput != null && sizeInput.isNotEmpty) {
        if (['S', 'M', 'L', 'X'].contains(sizeInput)) {
            product.size = sizeInput;
        } else {
            print('❌ Kích cỡ không hợp lệ!');
            return;
        }
        }
    stdout.write('Tình trạng mới (true=mới, false=cũ): ');
    String? statusInput = stdin.readLineSync();
    if (statusInput != null && statusInput.isNotEmpty) {
        product.status = statusInput.toLowerCase() == 'true';
    }
    stdout.write('Ngày nhập mới (dd/MM/yyyy): ');
    String? dateInput = stdin.readLineSync();
    if (dateInput != null && dateInput.isNotEmpty) {
        try {
            List<String> parts = dateInput.split('/');
            if (parts.length != 3) throw FormatException();
            int day = int.parse(parts[0]);
            int month = int.parse(parts[1]);
            int year = int.parse(parts[2]);
            product.importDate = DateTime(year, month, day);
        } catch (e) {
            print('❌ Ngày nhập không hợp lệ! Định dạng đúng là dd/MM/yyyy (VD: 20/06/2025)');
            return;
        }
    }
    productList[index] = product;
  print('✅ Đã cập nhật.');
}

void deleteProduct() {
  stdout.write('Nhập ID sản phẩm cần xóa: ');
  int id = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
  int before = productList.length;
  productList.removeWhere((p) => p.id == id);
  if (productList.length < before) {
    print('✅ Đã xóa sản phẩm.');
  } else {
    print('❌ Không tìm thấy sản phẩm!');
  }
}

void viewAllProducts() {
  if (productList.isEmpty) {
    print('📦 Danh sách sản phẩm rỗng.');
  } else {
    print('📋 Danh sách sản phẩm:');
    for (var p in productList) {
      p.display();
    }
  }
}

Future<void> saveToFile() async {
  File file = File('products.json');
  String jsonData = jsonEncode(productList.map((p) => p.toJson()).toList());
  await file.writeAsString(jsonData);
  print('✅ Đã lưu vào file.');
}

Future<void> loadFromFile() async {
  File file = File('products.json');
  if (!await file.exists()) {
    print('❌ File không tồn tại.');
    return;
  }
  String jsonData = await file.readAsString();
  List<dynamic> jsonList = jsonDecode(jsonData);
  productList = jsonList.map((e) => Product.fromJson(e)).toList();

  // Tính lại ID tiếp theo (nếu có dữ liệu)
  if (productList.isNotEmpty) {
    nextId = productList.map((p) => p.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  print('✅ Đã đọc dữ liệu từ file.');
  productList.forEach((p) => p.display());
}

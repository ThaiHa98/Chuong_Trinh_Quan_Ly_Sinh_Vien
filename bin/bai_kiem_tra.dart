import 'dart:convert';
import 'dart:io';

// Đọc dữ liệu từ file JSON
Future<List<dynamic>> readStudents() async {
  final file = File('Student.json');

  // Kiểm tra xem file có tồn tại không
  if (!await file.exists()) {
    // Tạo file mới với nội dung rỗng nếu file không tồn tại
    await file.writeAsString('[]');
    return []; // Trả về danh sách rỗng
  }

  final contents = await file.readAsString();
  if (contents.isEmpty) {
    return []; // Trả về danh sách rỗng nếu nội dung file rỗng
  }

  return jsonDecode(contents); // Giải mã nội dung JSON thành danh sách
}

// Ghi dữ liệu vào file JSON
Future<void> writeStudents(List<dynamic> students) async {
  final file = File('Student.json');
  final jsonString = jsonEncode(students);
  await file.writeAsString(jsonString); // Ghi dữ liệu vào file
}

// Hiển thị toàn bộ sinh viên
Future<void> displayStudents() async {
  final students = await readStudents();
  for (var student in students) {
    print('ID: ${student['id']}, Name: ${student['name']}, DOB: ${student['dob']}');
    for (var subject in student['subjects']) {
      print('  Subject: ${subject['subject']}, Marks: ${subject['marks']}');
    }
  }
}

// Thêm sinh viên
Future<void> addStudent() async {
  final students = await readStudents(); // Đọc danh sách sinh viên từ file

  print('Nhập ID của sinh viên:');
  final id = stdin.readLineSync() ?? '';
  
  print('Nhập tên của sinh viên:');
  final name = stdin.readLineSync() ?? '';
  
  print('Nhập ngày sinh (DD/MM/YYYY):');
  final dob = stdin.readLineSync() ?? '';
  
  print('Nhập số lượng môn học:');
  final numSubjects = int.parse(stdin.readLineSync() ?? '0'); // Nhập số lượng môn học

  final subjects = <Map<String, dynamic>>[];

  for (var i = 0; i < numSubjects; i++) {
    print('Nhập tên môn học $i:');
    final subjectName = stdin.readLineSync() ?? '';

    print('Nhập điểm môn học $i (các điểm cách nhau bởi dấu phẩy):');
    final marks = stdin.readLineSync()?.split(',').map(int.parse).toList() ?? [];

    subjects.add({
      "subject": subjectName,
      "marks": marks,
    });
  }

  final newStudent = {
    "id": id,
    "name": name,
    "dob": dob,
    "subjects": subjects, // Gán danh sách môn học vào đối tượng sinh viên
  };

  students.add(newStudent); // Thêm sinh viên mới vào danh sách
  await writeStudents(students); // Ghi lại danh sách sinh viên vào file JSON
  print('Student added successfully.');
}


// Sửa thông tin sinh viên
Future<void> editStudent() async {
  final students = await readStudents();

  print('Nhập ID của sinh viên cần sửa:');
  final studentId = stdin.readLineSync() ?? ''; // Nhập ID của sinh viên cần sửa

  for (var student in students) {
    if (student['id'] == studentId) {
      print('Nhập tên mới cho sinh viên:');
      student['name'] = stdin.readLineSync() ?? ''; // Nhập tên mới cho sinh viên
      
      print('Nhập ngày sinh mới (DD/MM/YYYY):');
      student['dob'] = stdin.readLineSync() ?? ''; // Nhập ngày sinh mới

      print('Nhập số lượng môn học mới:');
      final numSubjects = int.parse(stdin.readLineSync() ?? '0'); // Nhập số lượng môn học
      student['subjects'] = []; // Khởi tạo lại danh sách môn học

      for (var i = 0; i < numSubjects; i++) {
        print('Nhập tên môn học thứ ${i + 1}:');
        final subjectName = stdin.readLineSync() ?? ''; // Nhập tên môn học mới
        
        print('Nhập điểm môn học thứ ${i + 1} (các điểm cách nhau bởi dấu phẩy):');
        final marks = stdin.readLineSync()?.split(',').map(int.parse).toList() ?? []; // Nhập điểm mới của môn học

        student['subjects']!.add({
          "subject": subjectName,
          "marks": marks,
        });
      }

      await writeStudents(students); // Ghi lại danh sách sinh viên sau khi chỉnh sửa vào file JSON
      print('Student information updated successfully.');
      return;
    }
  }

  print('Student not found.');
}

// Tìm kiếm sinh viên
void searchStudent(List<dynamic> students) {
  final searchTerm = stdin.readLineSync() ?? ''; // Nhập tên hoặc ID cần tìm
  bool found = false;
  for (var student in students) {
    if (student['id'] == searchTerm ||
        student['name']?.contains(searchTerm) == true) {
      print(
          'ID: ${student['id']}, Name: ${student['name']}, DOB: ${student['dob']}');
      for (var subject in student['subjects']) {
        print('  Subject: ${subject['subject']}, Marks: ${subject['marks']}');
      }
      found = true; // Đánh dấu đã tìm thấy sinh viên
    }
  }
  if (!found) {
    print(
        'No student found with the given criteria.'); // Thông báo nếu không tìm thấy sinh viên
  }
}

// Hàm chính của chương trình
void main(List<String> arguments) async {
  while (true) {
    print('Chương Trình Quản Lý Sinh Viên');
    print('1. Hiển thị toàn bộ sinh viên');
    print('2. Thêm sinh viên');
    print('3. Sửa thông tin sinh viên');
    print('4. Tìm kiếm sinh viên');
    print('5. Thoát');
    print('Chọn một tùy chọn: ');

    final choice = stdin.readLineSync() ?? '';

    switch (choice) {
      case '1':
        await displayStudents();
        break;
      case '2':
        await addStudent();
        break;
      case '3':
        await editStudent();
        break;
      case '4':
        final students = await readStudents();
        searchStudent(students);
        break;
      case '5':
        print('Thoát chương trình.');
        exit(0);
      default:
        print('Lựa chọn không hợp lệ.');
    }
  }
}

# TokoKita - Aplikasi Manajemen Produk

## Deskripsi
Aplikasi mobile untuk manajemen produk toko yang dibangun menggunakan Flutter. Aplikasi ini memungkinkan pengguna untuk melakukan operasi CRUD (Create, Read, Update, Delete) pada data produk dengan sistem autentikasi berbasis token.

---

## Struktur Aplikasi

### Entry Point
- **main.dart**: Entry point aplikasi yang mengatur routing awal berdasarkan status login user

### Model
| File | Deskripsi |
|------|-----------|
| `model/produk.dart` | Model data produk (id, kodeProduk, namaProduk, hargaProduk) |
| `model/login.dart` | Model autentikasi (code, status, token, userID, userEmail) |
| `model/registrasi.dart` | Model response registrasi (code, status, data) |

### Helpers
| File | Deskripsi |
|------|-----------|
| `helpers/user_info.dart` | Manajemen session dengan SharedPreferences |
| `helpers/api.dart` | HTTP client (GET, POST, PUT, DELETE) |
| `helpers/api_url.dart` | Konfigurasi endpoint API |
| `helpers/app_exception.dart` | Custom exception handling |

### BLoC (Business Logic Component)
| File | Deskripsi |
|------|-----------|
| `bloc/login_bloc.dart` | Logic proses login |
| `bloc/logout_bloc.dart` | Logic proses logout |
| `bloc/registrasi_bloc.dart` | Logic proses registrasi |
| `bloc/produk_bloc.dart` | Logic operasi CRUD produk |

### UI Pages
| File | Deskripsi |
|------|-----------|
| `ui/login_page.dart` | Halaman login |
| `ui/registrasi_page.dart` | Halaman registrasi |
| `ui/produk_page.dart` | Halaman list produk |
| `ui/produk_detail.dart` | Halaman detail produk |
| `ui/produk_form.dart` | Form tambah/edit produk |

---

## Proses dan Alur Aplikasi

### 1. Proses Auto-Login (Splash)

Saat aplikasi dibuka, sistem akan mengecek apakah user sudah login sebelumnya.

**Kode `main.dart`:**
```dart
class _MyAppState extends State<MyApp> {
  Widget page = const CircularProgressIndicator();
  
  @override
  void initState() {
    super.initState();
    isLogin();
  }

  void isLogin() async {
    var token = await UserInfo().getToken();
    if (token != null) {
      setState(() {
        page = const ProdukPage();  // Token ada → ke halaman produk
      });
    } else {
      setState(() {
        page = const LoginPage();   // Token tidak ada → ke halaman login
      });
    }
  }
}
```

**Alur:**
```
Aplikasi Dibuka → Cek Token di SharedPreferences
    ├── Token Ada → Langsung ke ProdukPage
    └── Token Tidak Ada → Ke LoginPage
```

---

### 2. Proses Registrasi

#### a. Tampilan Form Registrasi

<img width="300" alt="image" src="https://github.com/user-attachments/assets/12a9bd34-5785-499f-920d-5639b67fc0b6" />

User mengisi data registrasi dengan validasi:
| Field | Validasi |
|-------|----------|
| Nama | Minimal 3 karakter |
| Email | Format email valid |
| Password | Minimal 6 karakter |
| Konfirmasi Password | Harus sama dengan password |

#### b. Mengisi Form Registrasi
<img width="300" alt="image" src="https://github.com/user-attachments/assets/ce81c837-13d0-4f72-9d70-cf40509533b2" />

**Kode Validasi:**
```dart
// Validasi Nama
validator: (value) {
  if (value!.length < 3) {
    return "Nama harus diisi minimal 3 karakter";
  }
  return null;
}

// Validasi Email
validator: (value) {
  if (value!.isEmpty) {
    return 'Email harus diisi';
  }
  Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern.toString());
  if (!regex.hasMatch(value)) {
    return "Email tidak valid";
  }
  return null;
}

// Validasi Password
validator: (value) {
  if (value!.length < 6) {
    return "Password harus diisi minimal 6 karakter";
  }
  return null;
}

// Validasi Konfirmasi Password
validator: (value) {
  if (value != _passwordTextboxController.text) {
    return "Konfirmasi Password tidak sama";
  }
  return null;
}
```

#### c. Registrasi Berhasil

<img width="300" alt="image" src="https://github.com/user-attachments/assets/18c28761-38a2-4b2d-b8d4-62228b43862d" />

**Kode Proses Registrasi:**
```dart
RegistrasiBloc.registrasi(
  nama: _namaTextboxController.text,
  email: _emailTextboxController.text,
  password: _passwordTextboxController.text,
).then((value) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => SuccessDialog(
      description: "Registrasi berhasil, silahkan login",
      okClick: () {
        Navigator.pop(context);
      },
    ),
  );
});
```

#### d. Registrasi Gagal

<!-- Tambahkan screenshot dialog registrasi gagal -->
<img width="300" alt="Registrasi Gagal" src="" />

```dart
onError: (error) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const WarningDialog(
      description: "Registrasi gagal, silahkan coba lagi",
    ),
  );
}
```

---

### 3. Proses Login

#### a. Tampilan Form Login

<img width="300" alt="image" src="https://github.com/user-attachments/assets/6a180945-162d-4085-bb3c-7ce72e1a9757" />

Form login terdiri dari:
- Email (wajib diisi)
- Password (wajib diisi)
- Tombol Login
- Link ke halaman Registrasi

#### b. Mengisi Form Login

<img width="300" alt="image" src="https://github.com/user-attachments/assets/161f2384-d980-42d2-9183-732cb85e35ee" />

**Kode Form Login:**
```dart
// Textbox Email
Widget _emailTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Email"),
    keyboardType: TextInputType.emailAddress,
    controller: _emailTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return 'Email harus diisi';
      }
      return null;
    },
  );
}

// Textbox Password
Widget _passwordTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Password"),
    obscureText: true,
    controller: _passwordTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Password harus diisi";
      }
      return null;
    },
  );
}
```

#### c. Login Berhasil
Setelah login berhasil, langsung diarahkan ke halaman produk

<img width="300" alt="image" src="https://github.com/user-attachments/assets/41e474a9-3a18-4a48-a233-a2328719838f" />

**Kode Proses Login:**
```dart
void _submit() {
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });
  
  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text,
  ).then((value) async {
    if (value.code == 200) {
      // Simpan token dan userID ke SharedPreferences
      await UserInfo().setToken(value.token.toString());
      await UserInfo().setUserID(int.parse(value.userID.toString()));
      
      // Navigasi ke halaman produk
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProdukPage()),
      );
    } else {
      // Tampilkan warning dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => const WarningDialog(
          description: "Login gagal, silahkan coba lagi",
        ),
      );
    }
  });
}
```

#### d. Login Gagal
<img width="300" alt="image" src="https://github.com/user-attachments/assets/2f4b55b0-c808-47af-81ba-22514c701df7" />

```dart
onError: (error) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) => const WarningDialog(
      description: "Login gagal, silahkan coba lagi",
    ),
  );
}
```

---

### 4. Proses Menampilkan List Produk (Read)

#### a. Tampilan List Produk

<img width="300" alt="image" src="https://github.com/user-attachments/assets/41e474a9-3a18-4a48-a233-a2328719838f" />

**Kode Menampilkan List:**
```dart
body: FutureBuilder<List>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    if (snapshot.hasError) print(snapshot.error);
    return snapshot.hasData
        ? ListProduk(list: snapshot.data)
        : const Center(child: CircularProgressIndicator());
  },
),
```

**Kode Bloc Get Produks:**
```dart
static Future<List<Produk>> getProduks() async {
  String apiUrl = ApiUrl.listProduk;
  var response = await Api().get(apiUrl);
  var jsonObj = json.decode(response.body);
  List<dynamic> listProduk = (jsonObj as Map<String, dynamic>)['data'];
  List<Produk> produks = [];
  for (int i = 0; i < listProduk.length; i++) {
    produks.add(Produk.fromJson(listProduk[i]));
  }
  return produks;
}
```

#### b. Item Produk

**Kode Item Produk:**
```dart
class ItemProduk extends StatelessWidget {
  final Produk produk;
  const ItemProduk({Key? key, required this.produk}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDetail(produk: produk),
          ),
        );
      },
      child: Card(
        child: ListTile(
          title: Text(produk.namaProduk!),
          subtitle: Text(produk.hargaProduk.toString()),
        ),
      ),
    );
  }
}
```

---

### 5. Proses Tambah Produk (Create)

#### a. Klik Tombol Tambah (+)

**Kode Navigasi ke Form Tambah:**
```dart
actions: [
  Padding(
    padding: const EdgeInsets.only(right: 20.0),
    child: GestureDetector(
      child: const Icon(Icons.add, size: 26.0),
      onTap: () async {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProdukForm()),
        );
      },
    ),
  ),
],
```

#### b. Tampilan Form Tambah Produk

<img width="300" alt="image" src="https://github.com/user-attachments/assets/0a11113b-acd2-49d2-a504-05977e97deda" />

Form tambah produk terdiri dari:
| Field | Tipe Input |
|-------|------------|
| Kode Produk | Text |
| Nama Produk | Text |
| Harga | Number |

#### c. Mengisi Form Tambah Produk

<img width="300" alt="image" src="https://github.com/user-attachments/assets/6abb4714-59c7-43c2-a559-6d960156d194" />

**Kode Validasi Form:**
```dart
// Kode Produk
Widget _kodeProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Kode Produk"),
    keyboardType: TextInputType.text,
    controller: _kodeProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Kode Produk harus diisi";
      }
      return null;
    },
  );
}

// Nama Produk
Widget _namaProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Nama Produk"),
    keyboardType: TextInputType.text,
    controller: _namaProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Nama Produk harus diisi";
      }
      return null;
    },
  );
}

// Harga Produk
Widget _hargaProdukTextField() {
  return TextFormField(
    decoration: const InputDecoration(labelText: "Harga"),
    keyboardType: TextInputType.number,
    controller: _hargaProdukTextboxController,
    validator: (value) {
      if (value!.isEmpty) {
        return "Harga harus diisi";
      }
      return null;
    },
  );
}
```

#### d. Produk Berhasil Ditambahkan

<img width="300" alt="image" src="https://github.com/user-attachments/assets/c4a81810-50b2-4e96-892b-cd188c6e126e" />

**Kode Proses Simpan:**
```dart
simpan() {
  setState(() {
    _isLoading = true;
  });
  
  Produk createProduk = Produk(id: null);
  createProduk.kodeProduk = _kodeProdukTextboxController.text;
  createProduk.namaProduk = _namaProdukTextboxController.text;
  createProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  
  ProdukBloc.addProduk(produk: createProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => const ProdukPage(),
      ),
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const WarningDialog(
        description: "Simpan gagal, silahkan coba lagi",
      ),
    );
  });
}
```

**Kode Bloc Add Produk:**
```dart
static Future addProduk({Produk? produk}) async {
  String apiUrl = ApiUrl.createProduk;
  var body = {
    "kode_produk": produk!.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString(),
  };
  var response = await Api().post(apiUrl, body);
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```

---

### 6. Proses Lihat Detail Produk (Read Detail)

#### a. Klik Item Produk di List

#### b. Tampilan Detail Produk

<img width="300" alt="image" src="https://github.com/user-attachments/assets/a8b9d6b4-857d-4cdc-a7b6-6f909e32c69d" />

**Kode Tampilan Detail:**
```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Detail Produk')),
    body: Center(
      child: Column(
        children: [
          Text(
            "Kode : ${widget.produk!.kodeProduk}",
            style: const TextStyle(fontSize: 20.0),
          ),
          Text(
            "Nama : ${widget.produk!.namaProduk}",
            style: const TextStyle(fontSize: 18.0),
          ),
          Text(
            "Harga : Rp. ${widget.produk!.hargaProduk.toString()}",
            style: const TextStyle(fontSize: 18.0),
          ),
          _tombolHapusEdit(),
        ],
      ),
    ),
  );
}
```

---

### 7. Proses Edit Produk (Update)

#### a. Klik Tombol EDIT di Detail Produk

**Kode Navigasi ke Form Edit:**
```dart
OutlinedButton(
  child: const Text("EDIT"),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProdukForm(produk: widget.produk!),
      ),
    );
  },
),
```

#### b. Tampilan Form Edit (Data Terisi Otomatis)

<img width="300" alt="image" src="https://github.com/user-attachments/assets/f88c094a-e06a-4e3a-b7ba-a072254c7fbb" />

**Kode Inisialisasi Form Edit:**
```dart
isUpdate() {
  if (widget.produk != null) {
    setState(() {
      judul = "UBAH PRODUK";
      tombolSubmit = "UBAH";
      _kodeProdukTextboxController.text = widget.produk!.kodeProduk!;
      _namaProdukTextboxController.text = widget.produk!.namaProduk!;
      _hargaProdukTextboxController.text = widget.produk!.hargaProduk.toString();
    });
  } else {
    judul = "TAMBAH PRODUK";
    tombolSubmit = "SIMPAN";
  }
}
```

#### c. Mengubah Data Produk

#### d. Produk Berhasil Diubah

<img width="300" alt="image" src="https://github.com/user-attachments/assets/b015f8b9-624a-44cc-8d82-d9908ad6e0d7" />

**Kode Proses Update:**
```dart
ubah() {
  setState(() {
    _isLoading = true;
  });
  
  Produk updateProduk = Produk(id: widget.produk!.id!);
  updateProduk.kodeProduk = _kodeProdukTextboxController.text;
  updateProduk.namaProduk = _namaProdukTextboxController.text;
  updateProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);
  
  ProdukBloc.updateProduk(produk: updateProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => const ProdukPage(),
      ),
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const WarningDialog(
        description: "Permintaan ubah data gagal, silahkan coba lagi",
      ),
    );
  });
}
```

**Kode Bloc Update Produk:**
```dart
static Future updateProduk({required Produk produk}) async {
  String apiUrl = ApiUrl.updateProduk(int.parse(produk.id!));
  var body = {
    "kode_produk": produk.kodeProduk,
    "nama_produk": produk.namaProduk,
    "harga": produk.hargaProduk.toString(),
  };
  var response = await Api().put(apiUrl, jsonEncode(body));
  var jsonObj = json.decode(response.body);
  return jsonObj['status'];
}
```

---

### 8. Proses Hapus Produk (Delete)

#### a. Klik Tombol DELETE di Detail Produk

#### b. Dialog Konfirmasi Hapus

<img width="300" alt="image" src="https://github.com/user-attachments/assets/07f9306a-befa-4cc2-aadd-298f4df51bae" />

**Kode Dialog Konfirmasi:**
```dart
void confirmHapus() {
  AlertDialog alertDialog = AlertDialog(
    content: const Text("Yakin ingin menghapus data ini?"),
    actions: [
      // Tombol Ya
      OutlinedButton(
        child: const Text("Ya"),
        onPressed: () {
          ProdukBloc.deleteProduk(id: int.parse(widget.produk!.id!)).then(
            (value) => {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProdukPage()),
              ),
            },
            onError: (error) {
              showDialog(
                context: context,
                builder: (BuildContext context) => const WarningDialog(
                  description: "Hapus gagal, silahkan coba lagi",
                ),
              );
            },
          );
        },
      ),
      // Tombol Batal
      OutlinedButton(
        child: const Text("Batal"),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );
  showDialog(builder: (context) => alertDialog, context: context);
}
```

#### c. Produk Berhasil Dihapus

<img width="300" alt="image" src="https://github.com/user-attachments/assets/fbee9655-9cce-4735-bbc7-6432d2717f67" />

**Kode Bloc Delete Produk:**
```dart
static Future<bool> deleteProduk({int? id}) async {
  String apiUrl = ApiUrl.deleteProduk(id!);
  var response = await Api().delete(apiUrl);
  var jsonObj = json.decode(response.body);
  return (jsonObj as Map<String, dynamic>)['data'];
}
```

---

### 9. Proses Logout

#### a. Buka Drawer Menu

<img width="300" alt="image" src="https://github.com/user-attachments/assets/50f5ecfb-9e96-4102-8ab5-a8cef13d0d18" />

#### b. Klik Menu Logout

**Kode Logout:**
```dart
drawer: Drawer(
  child: ListView(
    children: [
      ListTile(
        title: const Text('Logout'),
        trailing: const Icon(Icons.logout),
        onTap: () async {
          await LogoutBloc.logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (route) => false,
            ),
          });
        },
      ),
    ],
  ),
),
```

#### c. Kembali ke Halaman Login

**Kode Bloc Logout:**
```dart
class LogoutBloc {
  static Future logout() async {
    await UserInfo().logout();
  }
}

// Di user_info.dart
Future logout() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  pref.clear();  // Hapus semua data session
}
```

---

## API Endpoints

| Method | Endpoint | Deskripsi |
|--------|----------|-----------|
| POST | `/registrasi` | Registrasi user baru |
| POST | `/login` | Login user |
| GET | `/produk` | Mendapatkan list produk |
| POST | `/produk` | Menambah produk baru |
| PUT | `/produk/{id}` | Update produk |
| DELETE | `/produk/{id}` | Hapus produk |

---

## Fitur Validasi
- ✅ Form validation menggunakan `GlobalKey<FormState>`
- ✅ Loading state untuk operasi async
- ✅ Dialog konfirmasi untuk aksi delete
- ✅ Warning dialog untuk error handling
- ✅ Success dialog untuk notifikasi berhasil
- ✅ Auto-login check saat aplikasi dibuka

---

## Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^latest
  shared_preferences: ^latest
```

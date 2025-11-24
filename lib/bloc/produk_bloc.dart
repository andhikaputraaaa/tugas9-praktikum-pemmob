class ProdukBloc {
  static Future<bool> deleteProduk({required int id}) async {
    await Future.delayed(const Duration(seconds: 1));
    return true;
  }
}
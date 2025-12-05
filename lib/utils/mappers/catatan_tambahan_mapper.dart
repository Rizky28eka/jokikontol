class CatatanTambahanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> data) {
    final result = <String, dynamic>{};
    
    if (data['tanggal_catatan'] != null) result['tanggal_catatan'] = data['tanggal_catatan'];
    if (data['waktu_catatan'] != null) result['waktu_catatan'] = data['waktu_catatan'];
    if (data['kategori'] != null) result['kategori'] = data['kategori'];
    
    if (data['catatan'] != null) {
      if (data['catatan'] is Map) {
        result['catatan'] = data['catatan']['isi_catatan'] ?? '';
      } else {
        result['catatan'] = data['catatan'];
      }
    }
    
    if (data['tindak_lanjut'] != null) {
      if (data['tindak_lanjut'] is Map) {
        result['tindak_lanjut'] = data['tindak_lanjut']['renpra'] ?? '';
      } else {
        result['tindak_lanjut'] = data['tindak_lanjut'];
      }
    }
    
    if (data['isi_catatan'] != null) result['catatan'] = data['isi_catatan'];
    if (data['renpra'] != null) result['tindak_lanjut'] = data['renpra'];
    
    return result;
  }
}

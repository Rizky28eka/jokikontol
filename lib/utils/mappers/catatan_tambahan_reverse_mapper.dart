class CatatanTambahanReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    final catatan = data['catatan'] ?? data;
    final renpra = catatan['renpra'] ?? {};

    List<int> parseIntervensi(dynamic value) {
      if (value is List) return value.cast<int>();
      if (value is String) {
        return value
            .split(',')
            .map((e) => int.tryParse(e.trim()))
            .where((e) => e != null)
            .cast<int>()
            .toList();
      }
      return [];
    }

    DateTime? parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    return {
      'tanggal_catatan': parseDate(catatan['tanggal_catatan']),
      'waktu_catatan': catatan['waktu_catatan'],
      'kategori': catatan['kategori'] ?? 'Perkembangan',
      'isi_catatan': catatan['isi_catatan'] ?? catatan['catatan'],
      'tindak_lanjut': catatan['tindak_lanjut'],
      'diagnosis': renpra['diagnosis'],
      'intervensi': parseIntervensi(renpra['intervensi']),
      'tujuan': renpra['tujuan'],
      'kriteria': renpra['kriteria'],
      'rasional': renpra['rasional'],
    };
  }
}

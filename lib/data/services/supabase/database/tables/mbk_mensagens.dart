import '../database.dart';

class MbkMensagensTable extends SupabaseTable<MbkMensagensRow> {
  @override
  String get tableName => 'mbk_mensagens';

  @override
  MbkMensagensRow createRow(Map<String, dynamic> data) => MbkMensagensRow(data);
}

class MbkMensagensRow extends SupabaseDataRow {
  MbkMensagensRow(super.data);

  @override
  SupabaseTable get table => MbkMensagensTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get mensagem => getField<String>('mensagem')!;
  set mensagem(String value) => setField<String>('mensagem', value);

  String? get embedding => getField<String>('embedding');
  set embedding(String? value) => setField<String>('embedding', value);
}

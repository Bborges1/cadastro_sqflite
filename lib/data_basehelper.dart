import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';


class DatabaseHelper {
  static final _databaseName = "ExemploDB.db";
  static final _databaseVersion = 1;
  static final table = 'contato';
  static final columnId = 'id';
  static final columnNome = 'nome';
  static final columnIdade = 'idade';

//torna essa classe singleton
DatabaseHelper._privateConstructor();
static final DatabaseHelper instance = 
     DatabaseHelper._privateConstructor();

//tem somente uma preferencia ao banco de dados
static Database?_database;  

Future<Database> get database async =>
      _database ??= await _initDatabase();

//abre o banco de dados e o cria se ele nao existir
_initDatabase() async {
   Directory documentsDirectory = await
       getApplicationDocumentsDirectory();
String path = join(documentsDirectory.path, _databaseName);
return await openDatabase(path,
     version: _databaseVersion,
     onCreate: _onCreate);
}     
//codigo SQL para criar o banco de dados e a tabela
Future _onCreate(Database db, int version) async{
  await db.execute('''
        CREATE TABLE $table(
          $columnId INTEGER PRIMARY KEY,
          $columnNome TEXT NOT NULL,
          $columnIdade INTEGER NOT NULL
)
''');
}
//METODOS HELPER
//........................................................................
//Insere uma linha no banco de dados onde cada chave no Map e um nome de coluna 
//e o valor é o valor de coluna.
// O valor de retorno  é o id da linha inserida.
Future<int> insert(Map<String, dynamic> row) async {
   Database db = await instance.database;
   return await db.insert(table, row);
}
// Toadas as linhas sao retornadas como uma lista de mapas, omde cada casa
// mapa e uma lista de valores-chave de colunas
Future<List<Map<String, dynamic>>> queryAllRows() async {
  Database db = await instance.database;
  return await db.query(table);
}
//Todos os metodos : inserir, consultar, atualizar e executar
//tambem podem ser feitos usando comandos SQL brutos.
//Esse metodo usa uma consulta bruta pra fornecer a contagem de linhas 
Future<int?> queryRowCount() async {
  Database db = await instance.database;
  return Sqflite.firstIntValue(
    await db.rawQuery('SELECT COUNT(*) FROM $table')
  );
}
//Assumimos aqui que a coluna id no mapa esta definida. Os outros 
//valores da colunas serão usados para atualizar a linha. 
Future<int> updated (Map<String, dynamic> row) async {
  Database db = await instance.database;
  int id = row[columnId];
  return await db.update(table, row,where: '$columnId = ?',
      whereArgs: [id]);
}
//Exclui a linnha especificada pelo id. O numero de linhas afetadas e retornada.
//Isso deve ser igual a 1, contando que a linha exista. 
Future<int> delete(int id) async {
  Database db = await instance.database;
  return
      await db.delete(table, where: '$columnId = ?',
            whereArgs: [id]
      );
}
}
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Nome das colunas da tabela
final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";


class ContactHelper{

  //Instancia single, que pode ser acessada de qualquee lugar.

  // Esse constrututor é chamando internamente
  // Quando declaro essa classe eu chamo um objeto dela mesmo
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  // Banco de dados
  Database _db;

  Future<Database> get db async {
    // Se o banco de dados for null, não existir, eu crio um banco de dados
    if(_db != null){
      return _db;
    }else {
      _db = await initDb();
      return  _db;
    }
  }

  Future<Database> initDb() async {
    // Local onde vou armazenar o banco de dados
    final databasePath = await getDatabasesPath();
    // Pegar o arquivo
    final path = join(databasePath, "contactsnew.db");

    // Abrir o banco, informando o local, versão, função que vai criar pela primeira vez o banco
    return await openDatabase(path, version: 1, onCreate:(Database db, int newerVersion) async {
      // Criar tabela que contem as colunas
      await db.execute(
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database dbContact = await db;
    // Quando salvar ele retornar o id dele
    contact.id = await dbContact.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database dbContact = await db;
    List<Map> maps = await dbContact.query(contactTable,
      // Colunas que quero obter 
      columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
      // Regra para pegar os dados
      where: "$idColumn = ?",
      // Coloquei o ? e passei o valor no whereArgs
      whereArgs: [id]);
      // Verifica se realmente retornou o contato
    if(maps.length > 0){
      // Pega o primeio elemento
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }  
  }

  Future<int> deleteContact(int id) async {
     Database dbContact = await db;
     return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<int> updateContact(Contact contact) async {
    Database dbContact = await db;
    return await dbContact.update(
      contactTable, 
      // Passa o contato para atualizar
      contact.toMap(), 
      where: "$idColumn = ?", 
      whereArgs: [contact.id]);
  }

  Future<List> getAllContacts() async {
    Database dbContact = await db;
    // Lista de todos os dados
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    // Instanciando uma lista de contatos
    List<Contact> listContact = List();
    // Mapeia os dados para uma list de contatos
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  // Retorna a quantidade de contatos da tabela
  Future<int> getNumber() async{
    Database dbContact = await db;
    int quantidadeDeContatos = Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) $contactTable"));
    return quantidadeDeContatos; 
  }

  // Fecha o banco de dados
  Future close() async {
     Database dbContact = await db;
     dbContact.close();
  }
}

class Contact {
  int id;
  String name;
  String email;
  String phone;
  String img;

  Contact();

  // Tranforma o map em contato;
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img = map[imgColumn];
  }

  // Transforma os dodos em um mapa
  Map toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Contact(id: $id, name: $name, $email, phone: $phone, img: $img)";
  }

}
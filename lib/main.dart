import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; //posso richiamare semplicemente http
import 'dart:convert';
import 'libro.dart';
import 'libroScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BooksTime',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LibriScreen(),
    );
  }
}

class LibriScreen extends StatefulWidget {
  const LibriScreen({Key? key}) : super(key: key);

  @override
  State<LibriScreen> createState() => _LibriScreenState();
}

class _LibriScreenState extends State<LibriScreen> {
  Icon icona = Icon(Icons.search);
  Widget widgetRicerca = Text('Libri');
  String risultato = '';
  List<Libro> libri = []; //elenco di oggetti Libro
  @override
  void initState() {
    cercaLibri('Una vita come tante');
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: widgetRicerca, actions: [
        IconButton(
            icon: icona,
            onPressed: () {
              setState(() {
                if (this.icona.icon == Icons.search) {
                  this.icona = Icon(Icons.cancel);
                  this.widgetRicerca = TextField(
                    textInputAction: TextInputAction.search,
                    onSubmitted: (testoRicerca) => cercaLibri(testoRicerca),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  );
                } else {
                  setState(() {
                    this.icona = Icon(Icons.search);
                    this.widgetRicerca = Text('Libri');
                  });
                }
              });
            })
      ]),
      body: ListView.builder(
          itemCount: libri.length, //lunghezza lista libri
          itemBuilder: ((BuildContext context, int posizione) {
            //interfaccia grafica ListView
            return Card(
              elevation: 3,
              child: ListTile(
                  onTap: () {
                    MaterialPageRoute route = MaterialPageRoute(
                        builder: (_) => LibroScreen(libri[posizione]));
                    Navigator.push(context, route);
                  },
                  leading: libri[posizione].immagineCopertina.isEmpty
                      ? Icon(Icons.home)
                      : Image.network(libri[posizione].immagineCopertina),
                  title: Text(libri[posizione].titolo),
                  subtitle: Text(libri[posizione].autori)),
            );
          })),
    );
  }

  Future cercaLibri(String ricerca) async {
    //nuovo metodo che restituisce una "ricevuta" (asincrono)
    final String dominio = 'www.googleapis.com';
    final String percorso = '/books/v1/volumes';
    Map<String, dynamic> parametri = {'q': ricerca};
    final Uri url = Uri.https(dominio, percorso, parametri);
    try {
      http.get(url).then((res) {
        //richiamo il metodo http.get passando l'url dove recuperare i dati e passo i dati a res
        final resJson = json.decode(res.body); //dichiaro variabile che prende il contenuto del risultato della richiesta del metodo GET e la decodifica
        final libriMap = resJson['items']; //mette il contenuto della chiava items nella variabile libriMap
        libri = libriMap.map<Libro>((mappa) => Libro.fromMap(mappa)).toList(); //il metodo Map permette di scorrere ciascun elemento all'interno di un insieme e per ciascuno elemento all'interno dell'insieme libriMap prendiamo un oggetto (mappa) e per ciascuna mappa restituiamo un oggetto di tipo libro
        setState(() {
          risultato = res.body; //modifico la variabile di stato risultato
          libri = libri;
        });
      });
    } catch (errore) {
      setState(() {
        risultato = '';
      });
    }
    setState(() {
      risultato = 'Richiesta in corso';
    });
  }
}

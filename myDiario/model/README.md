#  DOCUMENTAZIONE

## Schema impostazioni:
### UserDeaults info: 
Per richiedere: *UserDefaults.standard.type(forKey: "[key]") ?? [error assign]*
Per settare: *UserDefaults.standard.set([value], forKey: "[key]")*
Usare funzione *isKeyPresentInUserDefaults(key: "[key]")* da API

Info sugli id:
 - modalità celle  skeleton o bubbly: key = **"skeleton"** -> Bool
 - materie: key = **"materieKey"** -> [String]
 - tipi: key = **"tipiKey"** -> [String]
 
## General API
### Global vars
- *selectedDateInCalendar = Date()*
### Date Formatting
-  formattare una data *it_IT* con format da input e data *Date*, restituzione di stringa
    - **formatDate**(format: String, date: Date) -> String
-  restituire una data *it_IT* da una stringa 
    - **dateFromString**(format: String, date: String)->Date
-  restituire una data *it_IT* da una stringa 
    - **dateFromString**(format: String, date: String)->Date
- ritorna il nome di un giorno da input *Date*, output è per esempio *"Oggi"*, *"Domani"* o data prescisa, restituisce stringa
    - **getDateOutput**(date: Date, format: String)-> String
### Funzioni CoreData Impegni
 - filtrare un array di Impegni di input in base alla data, *withLimit* indica se ci sia un limite sotto al quale non carica date (es oggi in Impegni imminenti) e *limitingFrom* ne indica il limite. Restituzione dell'array filtrato
    - **sortImpArrayByDate**(imp : [Impegno], withLimit: Bool, limitingFrom: Date)->[Impegno]
#### class EventoDiario
Una classe che dscrive un evento e lo gestisce. Parametri: *tipo, data, descrizione, materia, id*, tutto *public*. Sintassi *nomeClasse.funzione*
- inizializzo i parametri
    - **init**(id: String, tipo: String, data: String, descrizione: String, materia: String)
- inizializzo con default values
    - **init()**
- update di elementi particolari dell' impegno, elementi descritti nell'enum *tipiDiAggiornamentoEventoDiario* (tipo, data, descrizione)
    - **update(type** : tipiDiAggiornamentoEventoDiario, id: String, testoDiUpdate: String)
- update generale, alle info dell'impegno vengono assegnati parametri della classe, utile quando si cambiano direttamente i parametri senza passare per l'update specifico
    - **update()**
### gestione UserDefaults
- capire se una chiave è presente in UserDefaults, input key come String, restituisce Bool
    - **isKeyPresentInUserDefaults**(key: String) -> Bool
### UITableViewCell models
Modelli che aiutano nel setUp delle rispettive celle, esempio:
*var model: nomeModel!{
    didSet{
        [labelCell].text! = model.[parametro] }}*
così nel CellForRow at IndexPath assegnando valori al model li assegno anche alla cella, diminuendo linee di codice nel VC
- **class skeletonModel**
    - per cella skeleton, parametri: *descrizione, tipo, materia, data*
- **class bubblyModel**
    - per cella bubbly, parametri: *descrizione, tipo, materia, data, done*
### estensioni
- String
    - **capitalizingFirstLetter() -> String** *uppercase() solo alla prima lettera* identico a **capitalizeFirstLetter() -> String**
## CoreDataController
#### Gestione di core data da parte della classe *CoreDataController* per chiamare i metodi: *CoreDataController.shared.nomeFunzione()*
### Impegno
- carica tutti gli impegni, privata, da NON usare
    - *private* **loadImpegniFromFetchRequest** -> [Impegno]
- crea un nuovo impegno
    - **newImpegno**(materia: String, completato: Bool, tipo: String, descrizione: String, perData: String, id : String, colore: String)
- restituisce tutti gli impegni in memoria
    - **caricaTuttiGliImpegni()** -> [Impegno]
- completa un impegno
    - **completaImpegno**(id : String, completato : Bool)
- restituisce impegni per singolo id
    - **ImpegniPerId**(Id: String)
- cancella un impegno in base alll'id
    - **cancellaImpegno**(id: String)
### OrarioD
- carica tutti gli orari, privata, da NON usare
   - *private* **loadOrarioFromFetchRequest** -> [OrarioD]
- crea un nuovo orario
    - **newOrario**(materia: String, descrizione: String, from: String, to: String, giorno: String, colore : String, id : String)
- restituisce tutti gli orari
    - **caricaTuttiGliOrari()** -> [OrarioD]
- restituisce l'orario con specifico id
    - **OrariPerId**(Id: String) -> OrarioD
- restituisce tutti gli orari per un giorno specifico (input stringa)
    - **OrarPerGiorno(gio: String)** -> [OrarioD]
- cancella l'orario con un id specifico
    - **cancellaOrario**(id: String)
- cancella tutti gli orari
    - **cancellaTuttiGliOrari()**
### BulletList
 - carica tutti i bullet, privata, da NON usare
    - *private* **loadBulletFromFetchRequest** -> [BulletList]  
- crea un nuovo bullet
    - **newBullet**(date: String, idOfBullet: UUID, content: String)
- restituisce tutti i bullet
    - **caricaTuttiIBullet()** -> [BulletList]

### Immagini
 - carica tutte le immagini, privata, da NON usare
    - *private* **loadImmaginiFromFetchRequest** -> [Immagini]
- crea una nuova immagine
    - **newImage**(forImpegnoId: String, forMateria: String, ImageString: String, ImageID: String, data: String, descrizione: String)
- restituisce l'immagine per la specifica materia
    - **ImmaginiPerMateria**(materia: String)-> [Immagini]
- restituisce l'immagine con uno specifico id
    - **ImmaginiPerId(Id: String)** -> Immagini
- cancella specifica immagine da id
    - **cancellaImmagine**(id: String)
    


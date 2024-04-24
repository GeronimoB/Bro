import 'package:bro_app_to/utils/notification_model.dart';

String fcmToken = "";
List<NotificationModel> currentNotifications = [];
Map<String, dynamic>? translations;
Map<String, dynamic> nationalCategories = {
  translations!['male']: ['U15', 'U17', 'U19', 'U21'],
  translations!['female']: ['U17', 'U20']
};
List<String> alturas = List.generate(211 - 150, (index) => '${index + 150} cm');
List<String> anos =
    List.generate(125, (index) => '${index + 1900}').reversed.toList();
List<String> selecciones = [
  "Masculina",
  "Femenina",
];
List<String> piesDominantes = [
  "Zurdo",
  "Derecho",
  "Ambidiestro",
];
List<String> countries = [
  'España',
  'United States',
  'France',
  'Italia',
  'Deutschland'
];
List<String> categorias = [
  'PreBenjamín',
  'Benjamín',
  'Infantil',
  'Cadete',
  'Juvenil',
  'Sub-23',
  'Senior',
];
List<String> posiciones = [
  "Portero",
  "Lateral Derecho",
  "Lateral Izquierdo",
  "Defensa Central Derecho",
  "Defensa Central Izquierdo",
  "Mediocampista Defensivo",
  "Mediocampista Derecho",
  "Mediocampista Central",
  "Delantero Centro",
  "Mediocampista Ofensivo",
  "Extremo Izquierdo",
];
Map<String, dynamic> provincesByCountry = {
  'España': [
    'A Coruña',
    'Álava',
    'Albacete',
    'Alicante',
    'Almería',
    'Asturias',
    'Ávila',
    'Badajoz',
    'Baleares',
    'Barcelona',
    'Burgos',
    'Cáceres',
    'Cádiz',
    'Cantabria',
    'Castellón',
    'Ceuta',
    'Ciudad Real',
    'Córdoba',
    'Cuenca',
    'Girona',
    'Granada',
    'Guadalajara',
    'Gipuzkoa',
    'Huelva',
    'Huesca',
    'Jaén',
    'La Rioja',
    'Las Palmas',
    'León',
    'Lleida',
    'Lugo',
    'Madrid',
    'Málaga',
    'Melilla',
    'Murcia',
    'Navarra',
    'Ourense',
    'Palencia',
    'Pontevedra',
    'Salamanca',
    'Segovia',
    'Sevilla',
    'Soria',
    'Tarragona',
    'Santa Cruz de Tenerife',
    'Teruel',
    'Toledo',
    'Valencia',
    'Valladolid',
    'Vizcaya',
    'Zamora',
    'Zaragoza'
  ],
  'United States': [
    'Alabama',
    'Alaska',
    'Arizona',
    'Arkansas',
    'California',
    'Colorado',
    'Connecticut',
    'Delaware',
    'District of Columbia',
    'Florida',
    'Georgia',
    'Hawaii',
    'Idaho',
    'Illinois',
    'Indiana',
    'Iowa',
    'Kansas',
    'Kentucky',
    'Louisiana',
    'Maine',
    'Maryland',
    'Massachusetts',
    'Michigan',
    'Minnesota',
    'Mississippi',
    'Missouri',
    'Montana',
    'Nebraska',
    'Nevada',
    'New Hampshire',
    'New Jersey',
    'New Mexico',
    'New York',
    'North Carolina',
    'North Dakota',
    'Ohio',
    'Oklahoma',
    'Oregon',
    'Pennsylvania',
    'Rhode Island',
    'South Carolina',
    'South Dakota',
    'Tennessee',
    'Texas',
    'Utah',
    'Vermont',
    'Virginia',
    'Washington',
    'West Virginia',
    'Wisconsin',
    'Wyoming'
  ],
  'France': [
    'Ain',
    'Aisne',
    'Allier',
    'Alpes-de-Haute-Provence',
    'Hautes-Alpes',
    'Alpes-Maritimes',
    'Ardèche',
    'Ardennes',
    'Ariège',
    'Aube',
    'Aude',
    'Aveyron',
    'Bouches-du-Rhône',
    'Calvados',
    'Cantal',
    'Charente',
    'Charente-Maritime',
    'Cher',
    'Corrèze',
    'Côte-d\'Or',
    'Côtes-d\'Armor',
    'Creuse',
    'Dordogne',
    'Doubs',
    'Drôme',
    'Eure',
    'Eure-et-Loir',
    'Finistère',
    'Corse-du-Sud',
    'Haute-Corse',
    'Gard',
    'Haute-Garonne',
    'Gers',
    'Gironde',
    'Hérault',
    'Ille-et-Vilaine',
    'Indre',
    'Indre-et-Loire',
    'Isère',
    'Jura',
    'Landes',
    'Loir-et-Cher',
    'Loire',
    'Haute-Loire',
    'Loire-Atlantique',
    'Loiret',
    'Lot',
    'Lot-et-Garonne',
    'Lozère',
    'Maine-et-Loire',
    'Manche',
    'Marne',
    'Haute-Marne',
    'Mayenne',
    'Meurthe-et-Moselle',
    'Meuse',
    'Morbihan',
    'Moselle',
    'Nièvre',
    'Nord',
    'Oise',
    'Orne',
    'Pas-de-Calais',
    'Puy-de-Dôme',
    'Pyrénées-Atlantiques',
    'Hautes-Pyrénées',
    'Pyrénées-Orientales',
    'Bas-Rhin',
    'Haut-Rhin',
    'Rhône',
    'Haute-Saône',
    'Saône-et-Loire',
    'Sarthe',
    'Savoie',
    'Haute-Savoie',
    'Paris',
    'Seine-Maritime',
    'Seine-et-Marne',
    'Yvelines',
    'Deux-Sèvres',
    'Somme',
    'Tarn',
    'Tarn-et-Garonne',
    'Var',
    'Vaucluse',
    'Vendée',
    'Vienne',
    'Haute-Vienne',
    'Vosges',
    'Yonne',
    'Territoire de Belfort',
    'Essonne',
    'Hauts-de-Seine',
    'Seine-Saint-Denis',
    'Val-de-Marne',
    'Val-d\'Oise'
  ],
  'Italia': [
    'Agrigento',
    'Alessandria',
    'Ancona',
    'Aosta',
    'Arezzo',
    'Ascoli Piceno',
    'Asti',
    'Avellino',
    'Bari',
    'Barletta-Andria-Trani',
    'Belluno',
    'Benevento',
    'Bergamo',
    'Biella',
    'Bologna',
    'Bolzano',
    'Brescia',
    'Brindisi',
    'Cagliari',
    'Caltanissetta',
    'Campobasso',
    'Carbonia-Iglesias',
    'Caserta',
    'Catania',
    'Catanzaro',
    'Chieti',
    'Como',
    'Cosenza',
    'Cremona',
    'Crotone',
    'Cuneo',
    'Enna',
    'Fermo',
    'Ferrara',
    'Firenze',
    'Foggia',
    'Forlì-Cesena',
    'Frosinone',
    'Genova',
    'Gorizia',
    'Grosseto',
    'Imperia',
    'Isernia',
    'La Spezia',
    'L\'Aquila',
    'Latina',
    'Lecce',
    'Lecco',
    'Livorno',
    'Lodi',
    'Lucca',
    'Macerata',
    'Mantova',
    'Massa-Carrara',
    'Matera',
    'Medio Campidano',
    'Messina',
    'Milano',
    'Modena',
    'Monza e della Brianza',
    'Napoli',
    'Novara',
    'Nuoro',
    'Ogliastra',
    'Olbia-Tempio',
    'Oristano',
    'Padova',
    'Palermo',
    'Parma',
    'Pavia',
    'Perugia',
    'Pesaro e Urbino',
    'Pescara',
    'Piacenza',
    'Pisa',
    'Pistoia',
    'Pordenone',
    'Potenza',
    'Prato',
    'Ragusa',
    'Ravenna',
    'Reggio Calabria',
    'Reggio Emilia',
    'Rieti',
    'Rimini',
    'Roma',
    'Rovigo',
    'Salerno',
    'Sassari',
    'Savona',
    'Siena',
    'Siracusa',
    'Sondrio',
    'Taranto',
    'Teramo',
    'Terni',
    'Torino',
    'Trapani',
    'Trento',
    'Treviso',
    'Trieste',
    'Udine',
    'Varese',
    'Venezia',
    'Verbano-Cusio-Ossola',
    'Vercelli',
    'Verona',
    'Vibo Valentia',
    'Vicenza',
    'Viterbo'
  ],
  'Deutschland': [  
    'Baden-Württemberg',
    'Bavaria',
    'Berlin',
    'Brandenburg',
    'Bremen',
    'Hamburg',
    'Hesse',
    'Lower Saxony',
    'Mecklenburg-Vorpommern',
    'North Rhine-Westphalia',
    'Rhineland-Palatinate',
    'Saarland',
    'Saxony',
    'Saxony-Anhalt',
    'Schleswig-Holstein',
    'Thuringia'
  ],
};

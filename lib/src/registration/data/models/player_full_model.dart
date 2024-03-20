import 'package:bro_app_to/src/registration/domain/entities/player_full_entity.dart';
import 'package:flutter/material.dart';

@immutable
class PlayerFullModel extends PlayerFullEntity {
  const PlayerFullModel({
    final String? uid,
    final String? name,
    final String? lastName,
    final String? email,
    final String? referralCode,
    final bool? isAgent,
    final DateTime? birthDate,
    final String? dni,
    final String? pais,
    final String? provincia,
    final String? altura,
    final String? categoria,
    final String? club,
    final String? logrosIndividuales,
    final String? pieDominante,
    final String? seleccionNacional,
    final String? categoriaSeleccion,
    final DateTime? dateCreated,
    final DateTime? dateUpdated,
    final String? userImage,
  }) : super(
          uid: uid,
          name: name,
          lastName: lastName,
          email: email,
          referralCode: referralCode,
          isAgent: isAgent,
          birthDate: birthDate,
          dni: dni,
          pais: pais,
          provincia: provincia,
          altura: altura,
          categoria: categoria,
          club: club,
          logrosIndividuales: logrosIndividuales,
          pieDominante: pieDominante,
          seleccionNacional: seleccionNacional,
          categoriaSeleccion: categoriaSeleccion,
          dateCreated: dateCreated,
          dateUpdated: dateUpdated,
          userImage: userImage,
        );

  @override
  PlayerFullModel copyWith({
    String? uid,
    String? name,
    String? lastName,
    String? email,
    String? referralCode,
    bool? isAgent,
    DateTime? birthDate,
    String? dni,
    String? pais,
    String? provincia,
    String? altura,
    String? categoria,
    String? club,
    String? logrosIndividuales,
    String? pieDominante,
    String? seleccionNacional,
    String? categoriaSeleccion,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    String? userImage,
  }) {
    return PlayerFullModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      referralCode: referralCode ?? this.referralCode,
      isAgent: isAgent ?? this.isAgent,
      birthDate: birthDate ?? this.birthDate,
      dni: dni ?? this.dni,
      pais: pais ?? this.pais,
      provincia: provincia ?? this.provincia,
      altura: altura ?? this.altura,
      categoria: categoria ?? this.categoria,
      club: club ?? this.club,
      logrosIndividuales: logrosIndividuales ?? this.logrosIndividuales,
      pieDominante: pieDominante ?? this.pieDominante,
      seleccionNacional: seleccionNacional ?? this.seleccionNacional,
      categoriaSeleccion: categoriaSeleccion ?? this.categoriaSeleccion,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      userImage: userImage ?? this.userImage,
    );
  }

  factory PlayerFullModel.fromJson(Map<String, dynamic> json) {
    return PlayerFullModel(
      uid: json['uid'],
      name: json['name'] ?? '',
      lastName: json['lastname'] ?? '',
      email: json['email'] ?? '',
      referralCode: json['referral_code'] ?? '',
      isAgent: json['isAgent'] ?? false,
      //birthDate: json['birthday'] != null ? json['birthday'].toDate() : null,
      dni: json['DNI'] ?? '',
      pais: json['pais'] ?? '',
      provincia: json['provincia'] ?? '',
      altura: json['altura'] ?? '',
      categoria: json['categoria'] ?? '',
      club: json['club'] ?? '',
      logrosIndividuales: json['logros_individuales'] ?? '',
      pieDominante: json['pie_ominante'] ?? '',
      seleccionNacional: json['seleccion_nacional'] ?? '',
      categoriaSeleccion: json['categoria_seleccion'] ?? '',
      dateCreated:
          json['dateCreated'] != null ? json['dateCreated'].toDate() : null,
      dateUpdated:
          json['dateUpdated'] != null ? json['dateUpdated'].toDate() : null,
      userImage:
          "https://tmssl.akamaized.net/images/foto/galerie/ngolo-kante-fc-chelsea-2020-21-1621596438-63083.jpg?lm=1621596451",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "lastName": lastName,
      "email": email,
      "referralCode": referralCode,
      "isAgent": isAgent,
      "birthDate": birthDate,
      "dni": dni,
      "pais": pais,
      "provincia": provincia,
      "altura": altura,
      "categoria": categoria,
      "club": club,
      "logrosIndividuales": logrosIndividuales,
      "pieDominante": pieDominante,
      "seleccionNacional": seleccionNacional,
      "categoriaSeleccion": categoriaSeleccion,
      "dateCreated": dateCreated,
      "dateUpdated": dateUpdated,
      "userImage": userImage,
    };
  }
}

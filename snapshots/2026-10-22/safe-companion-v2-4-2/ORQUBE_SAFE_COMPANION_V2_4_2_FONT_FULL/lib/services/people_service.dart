import '../utils/audience_selection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PersonConnection {
  final String uid, connectionId, name, relation, status;
  final bool incoming;
  const PersonConnection({required this.uid, required this.connectionId, required this.name,
    required this.relation, required this.status, required this.incoming});
}
class PeopleService {
  static final db = FirebaseFirestore.instance;
  static String get uid => FirebaseAuth.instance.currentUser!.uid;
  static CollectionReference<Map<String,dynamic>> get contacts => db.collection('companion_contacts').doc(uid).collection('people');
  static CollectionReference<Map<String,dynamic>> get groups => db.collection('companion_contacts').doc(uid).collection('groups');
  static const relations = {'family':'가족','friend':'친구','guardian':'보호자','teammate':'산행 동료'};
  static Future<List<PersonConnection>> load() async {
    final me = uid;
    final rows = await Future.wait([
      db.collection('companion_connections').where('fromUid', isEqualTo: me).get(const GetOptions(source: Source.server)),
      db.collection('companion_connections').where('toUid', isEqualTo: me).get(const GetOptions(source: Source.server)),
      contacts.get(const GetOptions(source: Source.server)),
    ]).timeout(const Duration(seconds: 10));
    if (uid != me) throw StateError('Account changed');
    final metadata = {for (final row in rows[2].docs) row.id: row.data()};
    final result = <String,PersonConnection>{};
    // Prefer a new pending/accepted connection to older rejected/revoked ones.
    for (final row in [...rows[0].docs,...rows[1].docs]) {
      final data = row.data(); final incoming = data['toUid'] == me;
      final peer = (incoming ? data['fromUid'] : data['toUid']) as String;
      final state = data['status'] as String;
      if (state != 'accepted' && state != 'pending') continue;
      final meta = metadata[peer];
      final candidate = PersonConnection(uid: peer, connectionId: row.id,
        name: meta?['name'] as String? ?? (incoming ? data['fromName'] as String? : null) ?? peer,
        relation: meta?['relation'] as String? ?? 'family', status: state, incoming: incoming);
      if (result[peer]?.status != 'accepted') result[peer] = candidate;
    }
    return result.values.toList()..sort((a,b) => a.name.compareTo(b.name));
  }
  static Future<void> invite(String peer, String name, String relation) async {
    if (peer.isEmpty || peer == uid || peer.contains('/') || peer.length > 128) throw StateError('Invalid ID');
    final existing = (await load()).where((p) => p.uid == peer).toList();
    final ref = existing.isEmpty ? db.collection('companion_connections').doc() : db.collection('companion_connections').doc(existing.first.connectionId);
    if (existing.isEmpty) {
      final fromName = FirebaseAuth.instance.currentUser?.displayName ?? 'ORQUBE';
      await ref.set({'fromUid': uid, 'toUid': peer, 'fromName': fromName, 'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp()}).timeout(const Duration(seconds: 8));
    }
    await saveMetadata(peer, ref.id, name, relation);
  }
  static Future<void> saveMetadata(String peer, String connectionId, String name, String relation) => contacts.doc(peer).set({
    'peerUid': peer, 'connectionId': connectionId, 'name': name.trim().isEmpty ? peer : name.trim(),
    'relation': relation, 'updatedAt': FieldValue.serverTimestamp(),
  }).timeout(const Duration(seconds: 8));
  static Future<void> accept(PersonConnection person, String name, String relation) async {
    await db.collection('companion_connections').doc(person.connectionId).update({'status':'accepted','updatedAt':FieldValue.serverTimestamp()}).timeout(const Duration(seconds: 8));
    await saveMetadata(person.uid, person.connectionId, name, relation);
  }
  static Future<void> disconnect(PersonConnection person) async {
    // Revocation is the authoritative access stop for BOTH directions.
    final all = await Future.wait([
      db.collection('companion_connections').where('fromUid',isEqualTo:uid).get(const GetOptions(source:Source.server)),
      db.collection('companion_connections').where('toUid',isEqualTo:uid).get(const GetOptions(source:Source.server)),
    ]);
    final related = [...all[0].docs,...all[1].docs].where((r) => r.data()['fromUid']==person.uid || r.data()['toUid']==person.uid).toList();
    for (var i=0;i<related.length;i+=400) {
      final batch=db.batch();
      for(final row in related.skip(i).take(400)) { batch.update(row.reference,{'status':'revoked','updatedAt':FieldValue.serverTimestamp()}); }
      await batch.commit().timeout(const Duration(seconds:8));
    }
    await contacts.doc(person.uid).delete().timeout(const Duration(seconds: 8));
    final share = db.collection('safety_shares').doc(uid);
    await share.set({'ownerUid':uid,'viewerUids':FieldValue.arrayRemove([person.uid]),'searchViewerUids':FieldValue.arrayRemove([person.uid])},SetOptions(merge:true)).timeout(const Duration(seconds:8));
  }
  static Future<void> removeFromCurrentShare(String peer) => db.collection('safety_shares').doc(uid).set({
    'ownerUid':uid,'viewerUids':FieldValue.arrayRemove([peer]),'searchViewerUids':FieldValue.arrayRemove([peer]),
  },SetOptions(merge:true)).timeout(const Duration(seconds:8));
  static Future<void> setAudience(Set<String> live, Set<String> search) async {
    final people = await load();
    final allowed = people.where((p) => p.status == 'accepted').map((p) => p.uid).toSet();
    if (!validAudience(live,search,allowed)) throw StateError('Connections changed');
    // Metadata is owned by each side. Ensure this side has a path for server authorization.
    for (final p in people.where((p) => live.contains(p.uid))) {
      await saveMetadata(p.uid,p.connectionId,p.name,p.relation);
    }
    await db.collection('safety_shares').doc(uid).set({'ownerUid':uid,'viewerUids':live.toList(),'searchViewerUids':search.toList()},SetOptions(merge:true)).timeout(const Duration(seconds:8));
  }
  static Future<void> saveGroup(String? id, String name, Set<String> members) => (id == null ? groups.doc() : groups.doc(id)).set({
    'name':name.trim(),'memberUids':members.toList(),'updatedAt':FieldValue.serverTimestamp(),
  }).timeout(const Duration(seconds:8));
}

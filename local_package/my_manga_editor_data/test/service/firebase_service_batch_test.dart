import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:my_manga_editor_data/service/firebase/firebase_service.dart';

@GenerateNiceMocks([
  MockSpec<FirebaseAuth>(),
  MockSpec<User>(),
])
import 'firebase_service_batch_test.mocks.dart';

/// カットのページ間移動で使う batch 操作が、commit した時点でまとめて
/// 実際のドキュメントに反映されることを確認する。
void main() {
  const mangaPath = 'users/uid/mangas/mid';

  late FakeFirebaseFirestore firestore;
  late FirebaseService service;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(user.uid).thenReturn('uid');
    when(auth.currentUser).thenReturn(user);

    service = FirebaseService(firestore: firestore, auth: auth);

    await firestore.doc('$mangaPath/pages/p1').set({'pageIndex': 0});
    await firestore.doc('$mangaPath/deltas/d1').set({'pageId': 'p1'});
    await firestore.doc('$mangaPath/deltas/d2').set({'pageId': 'p1'});
  });

  test('updateDelta / deleteDelta / deletePage は commit で反映される', () async {
    final batch = service.batch()
      ..updateDelta('mid', 'd1', {'pageId': 'p2'})
      ..deleteDelta('mid', 'd2')
      ..deletePage('mid', 'p1');

    expect((await firestore.doc('$mangaPath/deltas/d1').get())['pageId'], 'p1');

    await batch.commit();

    final d1 = await firestore.doc('$mangaPath/deltas/d1').get();
    expect(d1['pageId'], 'p2');
    expect(d1.data()!.containsKey('updatedAt'), isTrue);
    expect((await firestore.doc('$mangaPath/deltas/d2').get()).exists, isFalse);
    expect((await firestore.doc('$mangaPath/pages/p1').get()).exists, isFalse);
  });
}

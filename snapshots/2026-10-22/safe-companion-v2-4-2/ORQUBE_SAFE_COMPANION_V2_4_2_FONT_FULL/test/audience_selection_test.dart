import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_safe_hiking/utils/audience_selection.dart';
void main(){
  test('Private group membership cannot grant access to pending or removed people',(){
    expect(eligibleGroupMembers(['family','removed','pending','family'],{'family','friend'}),{'family'});
  });
  test('Search audience must be explicitly selected from connected live recipients',(){
    expect(validAudience({'family','friend'},{'family'},{'family','friend'}),true);
    expect(validAudience({'family'},{'friend'},{'family','friend'}),false);
    expect(validAudience({'unaccepted'},{},{'family'}),false);
    expect(validAudience({}, {}, {'family'}),true);
  });
  test('Audience is bounded for large hiking groups',(){
    final ids=Set<String>.from(List.generate(51,(i)=>'person$i'));
    expect(validAudience(ids,{},ids),false);
    expect(validAudience(ids.take(50).toSet(),{},ids),true);
  });
}

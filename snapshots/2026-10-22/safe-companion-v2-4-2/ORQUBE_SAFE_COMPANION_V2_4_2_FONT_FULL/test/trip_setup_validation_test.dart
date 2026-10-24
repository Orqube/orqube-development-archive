import 'package:flutter_test/flutter_test.dart';
import 'package:orqube_safe_hiking/utils/trip_setup_validation.dart';
void main(){
  bool ready(int step,{bool understood=true,bool privacy=true,bool location=true,bool gps=true,
    bool hiking=true,bool destination=true,bool routeOnly=false,bool future=true,bool share=false,bool recipients=false}) => tripStepReady(
      step:step,understood:understood,privacy:privacy,locationConsent:location,hasPosition:gps,hiking:hiking,
      hasDestination:destination,routeOnly:routeOnly,futureReturn:future,share:share,hasRecipients:recipients);
  test('Explanation, both consent choices and GPS fix gate the early steps',(){
    expect(ready(0,understood:false),false);
    expect(ready(1,privacy:false),false);
    expect(ready(1,location:false),false);
    expect(ready(1),true);
    expect(ready(2,gps:false),false);
  });
  test('Hiking can be route-only with a future return; return trips require a destination',(){
    expect(ready(3,destination:false,routeOnly:true),true);
    expect(ready(3,destination:false,routeOnly:true,future:false),false);
    expect(ready(3,hiking:false,destination:false,routeOnly:true),false);
    expect(ready(3,hiking:false,destination:true),true);
  });
  test('Local-only trips can proceed; sharing requires explicit recipients',(){
    expect(ready(4,share:false),true);
    expect(ready(4,share:true,recipients:false),false);
    expect(ready(4,share:true,recipients:true),true);
  });
}

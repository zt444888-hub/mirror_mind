---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: a1428f9e380f25ab60aa2f5b56bbe916_949f3d4b625c11f19f62525400d9a7a1
    ReservedCode1: tAMfIGmwMw7lwLx1hdOF7U0NGXHabYyA02j3SI8QMjk6d0LBzrXWQ6q8p+Rss0tLwV6RqpaS1dVL5x+48x1fL5e7JTPyLQCZ9sLprykDJxDsIme1mgTPLGXEeKvWgrlU+UbeeohjVpRAkltCxvRSQgCd5pl0FqARKnGXp6A4X3ewaMJLExIuas7WUfU=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: a1428f9e380f25ab60aa2f5b56bbe916_949f3d4b625c11f19f62525400d9a7a1
    ReservedCode2: tAMfIGmwMw7lwLx1hdOF7U0NGXHabYyA02j3SI8QMjk6d0LBzrXWQ6q8p+Rss0tLwV6RqpaS1dVL5x+48x1fL5e7JTPyLQCZ9sLprykDJxDsIme1mgTPLGXEeKvWgrlU+UbeeohjVpRAkltCxvRSQgCd5pl0FqARKnGXp6A4X3ewaMJLExIuas7WUfU=
---



# 蹇冮暅 MirrorMind

> 姣忓ぉ5鍒嗛挓锛岀粰鎯呯华鍋氫竴娆′綋妫€
>
> **椤圭洰鐘舵€侊細鍙紪璇戝彲杩愯 | 涓婃灦鍓嶆渶缁堝鏌ュ凡瀹屾垚锛圥0=0 P1=0 P2=0锛?*

## 椤圭洰绠€浠?

蹇冮暅鏄竴娆惧熀浜?Flutter 鐨?AI 鎯呯华鏃ヨ涓庡績鐞嗗仴搴?App銆傞€氳繃鏂囧瓧鎴栬闊宠褰曟瘡鏃ュ績鎯咃紝AI 鑷姩鍒嗘瀽鎯呯华瓒嬪娍锛屽苟鎻愪緵鍛煎惛缁冧範銆佽鐭ラ噸鏋勫崱鐗囥€佹劅鎭╂棩璁扮瓑鑷剤宸ュ叿锛屽府鍔╀綘寤虹珛鎯呯华绠＄悊涔犳儻銆?

## 鏍稿績鍔熻兘

- **鎯呯华璁板綍** 鈥?鏂囧瓧/璇煶杈撳叆锛孉I 鑷姩鍒嗘瀽鎯呯华绫诲瀷涓庤瘎鍒?
- **鎯呯华鏃ュ巻** 鈥?鏈堣鍥炬棩鍘嗭紝棰滆壊鏍囪姣忔棩蹇冩儏锛屼竴鐩簡鐒?
- **4-7-8 鍛煎惛缁冧範** 鈥?Canvas 鍔ㄧ敾鍛煎惛鐞冿紝绉戝缂撹В鐒﹁檻
- **璁ょ煡閲嶆瀯鍗＄墖** 鈥?20寮犲績鐞嗗鍗＄墖锛屾崲涓搴︾湅寰呮儏缁?
- **鎰熸仼涓変欢浜?* 鈥?姣忔棩璁板綍鎰熸仼锛屽煿鍏荤Н鏋佸績鎬?
- **鎯呯华鎬ユ晳鍖?* 鈥?鏍规嵁褰撳墠蹇冩儏鍗虫椂鎺ㄨ崘搴斿寤鸿
- **AI 鍛ㄦ姤** 鈥?鐢熸垚鏈懆鎯呯华浣撴鎶ュ憡锛岀簿缇庡崱鐗囧垎浜?
- **闅愮浼樺厛** 鈥?鎵€鏈夋暟鎹粎瀛樻湰鍦帮紝涓嶄笂浼犱换浣曟湇鍔″櫒

## 鎶€鏈爤

- Flutter 3.x + Dart
- Provider 鐘舵€佺鐞?
- sqflite 鏈湴鍔犲瘑瀛樺偍
- OpenAI 鍏煎 API锛堢敤鎴疯嚜琛岄厤缃級

## 蹇€熷紑濮?

### 鐜瑕佹眰

- Flutter SDK >= 3.0.0
- Android Studio / Xcode
- iOS 14.0+ / Android 7.0+

### 瀹夎杩愯

```bash
# 鍏嬮殕椤圭洰
cd mirror_mind

# 瀹夎渚濊禆
flutter pub get

# 杩愯
flutter run
```

### AI 閰嶇疆

鍦?App銆岃缃€嶉〉闈㈤厤缃細
- API Base URL锛堥粯璁?`https://api.openai.com/v1`锛?
- API Key
- 妯″瀷鍚嶇О锛堥粯璁?`gpt-4o-mini`锛?

鏀寔鎵€鏈?OpenAI 鍏煎鐨?API 绔偣銆?

## 椤圭洰缁撴瀯

```
lib/
鈹溾攢鈹€ main.dart              # 鍏ュ彛
鈹溾攢鈹€ app.dart               # 涓婚/璺敱
鈹溾攢鈹€ constants/             # 甯搁噺锛堥鑹?鎯呯华/鍗＄墖锛?
鈹溾攢鈹€ models/                # 鏁版嵁妯″瀷
鈹溾攢鈹€ services/              # 鏈嶅姟锛堟暟鎹簱/AI/璇煶锛?
鈹溾攢鈹€ providers/             # 鐘舵€佺鐞?
鈹溾攢鈹€ screens/               # 椤甸潰
鈹斺攢鈹€ widgets/               # 缁勪欢
```

## 闅愮

鎵€鏈夋儏缁褰曚粎瀛樺偍鍦ㄨ澶囨湰鍦帮紝AI 鍒嗘瀽閫氳繃 HTTPS 鍔犲瘑浼犺緭鍒颁綘鑷閰嶇疆鐨?API 绔偣銆備笉鏀堕泦浠讳綍涓汉淇℃伅銆?

## License

MIT

---

## 涓婃灦鍓嶆鏌ユ竻鍗?

鍙戝竷鍓嶉€愪竴纭浠ヤ笅鏉′欢锛?

### 浠ｇ爜璐ㄩ噺
- [x] 缂栬瘧妫€鏌ワ細0 P0锛堝叏閮?40 涓?.dart 鏂囦欢瀹℃煡閫氳繃锛?
- [x] 杩愯鏃舵鏌ワ細0 P1锛坉ispose/mounted 瀹堝崼宸插氨浣嶏級
- [x] 璺敱瀹屾暣鎬э細17 鏉¤矾鐢卞叏閮ㄦ敞鍐屼笖瀵瑰簲鏂囦欢瀛樺湪
- [x] 浠樿垂鍐呭锛? 绉嶅啣鎯虫ā寮?/ 68 寮犺鐭ュ崱鐗?/ 72 璇嶆儏缁瘝搴?/ 7 绉嶅績鎯呭崱鐗囨ā鏉?
- [x] Pro 闂ㄧ锛氬叏閮ㄩ珮闃跺姛鑳藉凡娣诲姞闂ㄧ妫€鏌?

### 涓婃灦鏉愭枡
- [x] STORE_LISTING.md锛氬惈骞撮緞鍒嗙骇锛?2+锛夊拰鍐呭鍒嗙骇锛圛ARC锛夊０鏄?
- [x] PRIVACY_POLICY.md锛氬惈闅愮鏀跨瓥 URL 寤鸿锛圙itHub Pages锛?
- [x] SCREENSHOTS_GUIDE.md锛? 鍦烘櫙鎴浘瑙勬牸瀹屾暣
- [x] BUILD_AND_DEPLOY.md锛氬惈鏋勫缓鍛戒护/绛惧悕閰嶇疆/鎻愬娴佺▼/IAP娌欑洅娴嬭瘯

### 鍘熺敓骞冲彴锛堥娆″彂甯冨墠蹇呴』瀹屾垚锛?
- [ ] 鎵ц `flutter create --project-name mirror_mind .` 閲嶅缓 android/ 鍜?ios/ 鐩綍
- [ ] Android 閰嶇疆锛歚applicationId`銆佺鍚嶅瘑閽ャ€乣AndroidManifest.xml` 鏉冮檺澹版槑
- [ ] iOS 閰嶇疆锛欱undle Identifier銆佺鍚嶅洟闃熴€乣Info.plist` 鏉冮檺鎻忚堪
- [ ] 搴旂敤鍥炬爣锛氬埗浣?1024脳1024 PNG锛堣帿鍏拌开鑹茬郴锛?
- [ ] IAP 浜у搧 ID `mirror_mind_pro` 鍦?App Store Connect 鍜?Google Play Console 鍒涘缓
- [ ] 闅愮鏀跨瓥 URL 鍙叕寮€璁块棶

### 娴嬭瘯
- [ ] `flutter analyze` 鏃犻敊璇?
- [ ] `flutter test` 鍏ㄩ儴閫氳繃
- [ ] iOS 鐪熸満鏋勫缓鎴愬姛
- [ ] Android 鐪熸満鏋勫缓鎴愬姛
- [ ] IAP 娌欑洅璐拱娴嬭瘯閫氳繃

---

## 蹇€熷惎鍔?

```bash
# 1. 妫€鏌ョ幆澧?
flutter doctor

# 2. 瀹夎渚濊禆
cd mirror_mind
flutter pub get

# 3. 杩愯锛堟ā鎷熷櫒/鐪熸満锛?
flutter run

# 4. 鏋勫缓鍙戝竷鍖?
# Android
flutter build appbundle --release
# iOS锛堜粎 macOS锛?
flutter build ipa

# 5. 濡傞渶閲嶅缓鍘熺敓骞冲彴宸ョ▼
flutter create --project-name mirror_mind .
```
*锛堝唴瀹圭敱AI鐢熸垚锛屼粎渚涘弬鑰冿級*
*锛堝唴瀹圭敱AI鐢熸垚锛屼粎渚涘弬鑰冿級*


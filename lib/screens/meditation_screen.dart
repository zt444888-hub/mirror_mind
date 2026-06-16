import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';

/// 鍐ユ兂寮曞椤碉細鏂囧瓧寮曞 + Canvas 璁℃椂鍣?+ 鏌斿拰鍔ㄧ敾
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with TickerProviderStateMixin {
  // 棰勮鏃堕暱閫夐」锛堢锛?
  bool _isPro = false;
  static const List<int> _durationOptions = [300, 600, 900, 1200, 1800]; // 5, 10, 15, 20, 30鍒嗛挓
  
  // Pro 涓撳睘妯″紡鍒楄〃
  static List<_MeditationMode> get _proModes => [
    const _MeditationMode(
      title: '鐒﹁檻缂撹В',
      description: '骞冲绱у紶鎯呯华',
      icon: Icons.wind_power,
      color: Color(0xFF6BB3A5),
      defaultDuration: 300,
      phrases: ['鎵句竴涓畨闈欑殑鍦版柟锛屽潗涓嬫垨韬轰笅', '灏嗘墜鏀惧湪鑵归儴锛屾劅鍙楀懠鍚哥殑璧蜂紡', '鍚告皵鏁扮锛屾劅鍙楄吂閮ㄥ儚姘旂悆涓€鏍烽紦璧?, '鍛兼皵鏁扮锛屾參鎱㈤噴鏀炬墍鏈夌殑绱у紶', '褰撶劍铏戝嚭鐜版椂锛屽彧鏄瀵熷畠锛屼笉璇勫垽', '鎯宠薄鐒﹁檻鍍忎竴鐗囦箤浜戯紝鎱㈡參椋樿蛋', '閲嶅锛氭垜姝ゅ埢鏄畨鍏ㄧ殑锛屼竴鍒囬兘浼氬ソ璧锋潵', '鎰熷彈鍙岃剼涓庡湴闈㈢殑杩炴帴锛屾壘鍥炵ǔ瀹氭劅', '缁х画娣卞懠鍚革紝璁╁钩闈欏厖婊″唴蹇?, '褰撳噯澶囧ソ鏃讹紝鎱㈡參鐫佸紑鐪肩潧'],
    ),
    const _MeditationMode(
      title: '鍘嬪姏閲婃斁',
      description: '鍗镐笅韬績璐熸媴',
      icon: Icons.anchor,
      color: Color(0xFF8FA8D0),
      defaultDuration: 600,
      phrases: ['浠ヨ垝閫傜殑濮垮娍鍧愪笅锛岄棴涓婄溂鐫?, '鍥炲繂浠婂ぉ鎴栨渶杩戣浣犳劅鍒板帇鍔涚殑浜嬫儏', '鎵胯杩欎簺鍘嬪姏鐨勫瓨鍦紝涓嶆姉鎷?, '鎯宠薄灏嗗帇鍔涘啓鍦ㄤ竴寮犵焊涓?, '鐜板湪锛屾妸杩欏紶绾告弶鎴愪竴鍥?, '鎯宠薄灏嗗畠鎵旇繘鍨冨溇妗讹紝褰诲簳鎵旀帀', '鎰熷彈韬綋鍙樺緱杞荤泩锛屽帇鍔涙鍦ㄧ寮€', '娣卞懠鍚革紝鍚稿叆骞抽潤锛屽懠鍑哄帇鍔?, '閲嶅鍑犳锛岀洿鍒版劅瑙夎交鏉句竴浜?, '鎰熻阿鑷繁閲婃斁浜嗚繖浜涜礋鎷?],
    ),
    const _MeditationMode(
      title: '鎰熸仼鍐ユ兂',
      description: '鍩瑰吇鎰熸仼涔嬪績',
      icon: Icons.favorite_outline,
      color: Color(0xFFC49B8C),
      defaultDuration: 600,
      phrases: ['浠ヨ垝閫傜殑濮垮娍鍧愪笅', '鍥炴兂浠婂ぉ鍊煎緱鎰熸仼鐨勪笁浠朵簨', '鎰熷彈姣忎竴娆″懠鍚稿甫鏉ョ殑鐢熷懡鑳介噺', '鎰熻阿鐢熷懡涓殑姣忎竴涓汉鍜屼簨', '鎶婃劅鎭╃殑鑳介噺浼犻€掔粰韬竟鐨勪汉', '娓╂煍鍦扮粨鏉熻繖娆″啣鎯?],
    ),
  ];

  /// 鑾峰彇褰撳墠鍙敤鐨勫啣鎯虫ā寮忓垪琛紙鏍规嵁 Pro 鐘舵€佽繃婊わ級
  static List<_MeditationMode> getModes(bool isPro) {
    if (isPro) return _modes + _proModes;
    return _modes;
  }

  // 鑾峰彇鏃堕暱鏄剧ず鏂囧瓧
  String _getDurationLabel(int seconds) {
    if (seconds < 60) return '$seconds 绉?;
    return '${seconds ~/ 60} 鍒嗛挓';
  }

  // 鍐ユ兂妯″紡瀹氫箟
  static final List<_MeditationMode> _modes = [
    const _MeditationMode(
      title: '鏅ㄩ棿鍞ら啋',
      description: '寮€鍚編濂戒竴澶?,
      icon: Icons.wb_sunny_outlined,
      color: Color(0xFFD4A574),
      defaultDuration: 180,
      phrases: [
        '闂笂鐪肩潧锛屾劅鍙楁竻鏅ㄧ殑姘旀伅',
        '鎰熸仼鏂扮殑涓€澶╋紝鐢熷懡涓殑绀肩墿',
        '璁惧畾浠婂ぉ鐨勬剰鍥撅紝浣犳兂瑕佹€庢牱鐨勪綋楠?,
        '娣卞懠鍚镐笁娆★紝璁╄兘閲忓厖婊″叏韬?,
        '鎰熷彈闃冲厜娓╂殩浣犵殑鑲岃偆',
        '鎱㈡參鐫佸紑鐪肩潧锛屽甫鐫€骞抽潤寮€濮嬫柊鐨勪竴澶?,
      ],
    ),
    const _MeditationMode(
      title: '鍗堥棿灏忔啯',
      description: '涓轰笅鍗堝厖鐢?,
      icon: Icons.wb_cloudy_outlined,
      color: MirrorColors.primary,
      defaultDuration: 300,
      phrases: [
        '鎵句竴涓垝閫傜殑濮垮娍锛岄棴涓婄溂鐫?,
        '鍏虫敞浣犵殑鍛煎惛锛岃嚜鐒剁殑鑺傚',
        '鍚告皵...鎰熷彈绌烘皵杩涘叆韬綋',
        '鍛兼皵...閲婃斁涓婂崍鐨勭柌鎯?,
        '浠庡ご鍒拌剼鍋氫竴娆¤韩浣撴壂鎻?,
        '鏀炬澗浣犵殑鑲╄唨锛屾斁涓嬬揣缁?,
        '鏀炬澗浣犵殑鑳岄儴锛岃垝灞曡剨妞?,
        '鎰熷彈姝ゅ埢鐨勫畞闈?,
        '璁╂€濈华鍍忎簯鏈典竴鏍烽杩?,
        '鎱㈡參鍦板洖鍒板綋涓嬶紝甯︾潃娓呴啋涓庤兘閲?,
      ],
    ),
    const _MeditationMode(
      title: '鐫″墠鏀炬澗',
      description: '娓╂煍鍏ョ潯',
      icon: Icons.nightlight_round,
      color: Color(0xFF7B8BA6),
      defaultDuration: 300,
      phrases: [
        '鏀炬參浣犵殑鍛煎惛鑺傚',
        '閲婃斁浠婂ぉ鎵€鏈夌殑鍘嬪姏涓庣柌鎯?,
        '鎰熷彈韬綋娓愭笎娌夊叆搴婂灚',
        '璁╂瘡涓€涓粏鑳為兘鏀炬澗涓嬫潵',
        '鍥為【浠婂ぉ鍊煎緱鎰熸仼鐨勪笁涓灛闂?,
        '鎰熻阿浠婂ぉ鐨勮嚜宸憋紝浣犲凡缁忚冻澶熷姫鍔?,
        '鏀句笅瀵规槑澶╃殑鎷呭咖',
        '鎯宠薄娓╂殩鐨勫厜鎷ユ姳浣犵殑鍏ㄨ韩',
        '姣忎竴娆″懠鍚搁兘甯︿綘鏇存繁鍦版斁鏉?,
        '瀹夊績鍦拌繘鍏ユⅵ涔?,
      ],
    ),
    const _MeditationMode(
      title: '鐒﹁檻缂撹В',
      description: '骞冲绱у紶鎯呯华',
      icon: Icons.wind_power,
      color: Color(0xFF6BB3A5),
      defaultDuration: 300,
      phrases: [
        '鎵句竴涓畨闈欑殑鍦版柟锛屽潗涓嬫垨韬轰笅',
        '灏嗘墜鏀惧湪鑵归儴锛屾劅鍙楀懠鍚哥殑璧蜂紡',
        '鍚告皵鏁扮锛屾劅鍙楄吂閮ㄥ儚姘旂悆涓€鏍烽紦璧?,
        '鍛兼皵鏁扮锛屾參鎱㈤噴鏀炬墍鏈夌殑绱у紶',
        '褰撶劍铏戝嚭鐜版椂锛屽彧鏄瀵熷畠锛屼笉璇勫垽',
        '鎯宠薄鐒﹁檻鍍忎竴鐗囦箤浜戯紝鎱㈡參椋樿蛋',
        '閲嶅锛氭垜姝ゅ埢鏄畨鍏ㄧ殑锛屼竴鍒囬兘浼氬ソ璧锋潵',
        '鎰熷彈鍙岃剼涓庡湴闈㈢殑杩炴帴锛屾壘鍥炵ǔ瀹氭劅',
        '缁х画娣卞懠鍚革紝璁╁钩闈欏厖婊″唴蹇?,
        '褰撳噯澶囧ソ鏃讹紝鎱㈡參鐫佸紑鐪肩潧',
      ],
    ),
    const _MeditationMode(
      title: '鍘嬪姏閲婃斁',
      description: '鍗镐笅韬績璐熸媴',
      icon: Icons.anchor,
      color: Color(0xFF8FA8D0),
      defaultDuration: 600,
      phrases: [
        '浠ヨ垝閫傜殑濮垮娍鍧愪笅锛岄棴涓婄溂鐫?,
        '鍥炲繂浠婂ぉ鎴栨渶杩戣浣犳劅鍒板帇鍔涚殑浜嬫儏',
        '鎵胯杩欎簺鍘嬪姏鐨勫瓨鍦紝涓嶆姉鎷?,
        '鎯宠薄灏嗗帇鍔涘啓鍦ㄤ竴寮犵焊涓?,
        '鐜板湪锛屾妸杩欏紶绾告弶鎴愪竴鍥?,
        '鎯宠薄灏嗗畠鎵旇繘鍨冨溇妗讹紝褰诲簳鎵旀帀',
        '鎰熷彈韬綋鍙樺緱杞荤泩锛屽帇鍔涙鍦ㄧ寮€',
        '娣卞懠鍚革紝鍚稿叆骞抽潤锛屽懠鍑哄帇鍔?,
        '閲嶅鍑犳锛岀洿鍒版劅瑙夎交鏉句竴浜?,
        '鎰熻阿鑷繁閲婃斁浜嗚繖浜涜礋鎷?,
      ],
    ),
    const _MeditationMode(
      title: '鎰熸仼鍐ユ兂',
      description: '鍩瑰吇鎰熸仼涔嬪績',
      icon: Icons.favorite_outline,
      color: Color(0xFFE8A8A8),
      defaultDuration: 300,
      phrases: [
        '闂笂鐪肩潧锛屽洖蹇嗕粖澶╁彂鐢熺殑缇庡ソ灏忎簨',
        '鎰熸仼闃冲厜銆佺┖姘斿拰姘达紝缁欎簣鐢熷懡婊嬪吇',
        '鎰熸仼韬竟鐨勪汉锛屼粬浠殑闄即鍜屾敮鎸?,
        '鎰熸仼鑷繁鐨勮韩浣擄紝瀹冧竴鐩村湪鍔姏宸ヤ綔',
        '鎰熸仼閬囧埌鐨勬寫鎴橈紝瀹冧滑璁╀綘鎴愰暱',
        '鎰熸仼姝ゅ埢鐨勫钩闈欙紝杩欐槸涓€浠界ぜ鐗?,
        '鍦ㄥ績閲岄粯蹇碉細璋㈣阿浣狅紝璋㈣阿浣狅紝璋㈣阿浣?,
        '鎰熷彈鎰熸仼涔嬫儏鍦ㄥ績涓崌璧?,
        '灏嗚繖浠芥劅鎭╀紶閫掔粰姣忎竴涓汉',
        '鎱㈡參鐫佸紑鐪肩潧锛屽甫鐫€鎰熸仼鐨勫績缁х画涓€澶?,
      ],
    ),
    // --- Pro 妯″紡 ---
    const _MeditationMode(
      title: '涓撴敞鍔涜缁?,
      description: '娣卞害鑱氱劍',
      icon: Icons.center_focus_strong,
      color: Color(0xFF5B8C85),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '鎵惧埌涓€涓垝閫傜殑鍧愬Э锛岃交杞婚棴涓婄溂鐫?,
        '鎶婃敞鎰忓姏甯﹀埌鑷劧鐨勫懠鍚镐笂锛屼笉瑕佹帶鍒跺畠',
        '寮€濮嬫暟鍛煎惛锛氬惛姘?..1...鍛兼皵...2...',
        '褰撴€濈华椋樿蛋鏃讹紝涓嶉渶瑕佽矗澶囪嚜宸?,
        '娓╂煍鍦版妸娉ㄦ剰鍔涘甫鍥炲懠鍚革紝閲嶆柊寮€濮嬫暟鏁?,
        '鎰熷彈姣忎竴娆″懠鍚稿甫鏉ョ殑瀹夊畾涓庡钩闈?,
        '缁х画鍏虫敞鍛煎惛鐨勮妭濂忥紝涓€鍛间竴鍚?,
        '濡傛灉鏁板埌10锛屼粠1閲嶆柊寮€濮?,
        '鎰熷彈涓撴敞鍔涘儚鑲岃倝涓€鏍峰湪閿荤偧涓彉寮?,
        '鎱㈡參鐫佸紑鐪肩潧锛屽甫鐫€杩欎唤娓呮槑鍥炲埌褰撲笅',
      ],
    ),
    const _MeditationMode(
      title: '韬綋鎵弿',
      description: '娣卞害鏀炬澗',
      icon: Icons.accessibility_new,
      color: Color(0xFF8B6F9E),
      defaultDuration: 900,
      isPro: true,
      phrases: [
        '骞宠汉鎴栬垝閫傚湴鍧愮潃锛岄棴涓婄溂鐫?,
        '鎶婃敞鎰忓姏甯﹀埌鍙岃剼锛屾劅鍙楄剼搴曚笌鍦伴潰鐨勬帴瑙?,
        '缂撶紦鍚戜笂绉诲姩娉ㄦ剰鍔涘埌鍙岃吙锛屾劅鍙楄吙閮ㄧ殑閲嶉噺',
        '鍏虫敞鑵归儴锛屾劅鍙楀懠鍚告椂鑵归儴鐨勮捣浼?,
        '鎶婃敞鎰忓姏甯﹀埌鑳搁儴锛屾劅鍙楀績璺崇殑鑺傚',
        '鏀炬澗鑲╄唨锛屾斁涓嬫墍鏈夌殑绱х环鍜屽帇鍔?,
        '鎰熷彈棰堥儴涓庡ご閮紝璁╂瘡涓€涓儴浣嶉兘鏀炬澗涓嬫潵',
        '浠庡ご鍒拌剼鍋氫竴娆″畬鏁寸殑鎵弿',
        '鎰熷彈韬綋浣滀负涓€涓暣浣撶殑杞绘澗涓庡拰璋?,
        '濡傛灉鏌愪釜閮ㄤ綅绱х环锛屾繁鍛煎惛鎶婃斁鏉惧甫鍒伴偅閲?,
        '鍐嶆鎵弿鍏ㄨ韩锛屾劅鍙楁斁鏉剧殑娣卞害',
        '鎱㈡參娲诲姩鎵嬫寚鑴氳毒锛屽甫鐫€瑙夊療鍥炲埌褰撲笅',
      ],
    ),
    const _MeditationMode(
      title: '鎱堟偛鍐ユ兂',
      description: '婊嬪吇蹇冪伒',
      icon: Icons.volunteer_activism,
      color: Color(0xFFC48793),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '鎵惧埌涓€涓垝閫傜殑濮垮娍锛岄棴涓婄溂鐫?,
        '鎶婃墜杞昏交鏀惧湪蹇冨彛锛屾劅鍙楀績鐨勬俯搴?,
        '榛樺康锛氭効鎴戝钩瀹夛紝鎰挎垜鍋ュ悍锛屾効鎴戝揩涔?,
        '鎯宠薄涓€涓綘娣辩埍鐨勪汉锛岄粯蹇碉細鎰夸綘骞冲畨锛屾効鎴戝仴搴凤紝鎰夸綘蹇箰',
        '鎯宠薄涓€涓櫘閫氱殑鏈嬪弸鎴栫啛浜猴紝鍚屾牱閫佸嚭绁濈',
        '鎯宠薄涓€涓笌浣犳湁鐭涚浘鐨勪汉锛屽皾璇曢€佸嚭鎱堟偛涓庣悊瑙?,
        '灏嗚繖浠芥厛鎮叉墿灞曞埌鎵€鏈夎璇嗙殑浜?,
        '鏈€鍚庯紝绁濇効涓栫晫涓婄殑姣忎竴涓汉骞冲畨銆佸仴搴枫€佸揩涔?,
        '鎰熷彈鎱堟偛浠庡績閲屾祦娣屽嚭鏉ワ紝娓╂殩浣犺嚜宸?,
        '鎱㈡參鐫佸紑鐪肩潧锛屽甫鐫€杩欎唤鎱堟偛鍥炲埌鏃ュ父',
      ],
    ),
    const _MeditationMode(
      title: '鑷垜鍏崇埍',
      description: '鎺ョ撼涓庡杽寰呰嚜宸?,
      icon: Icons.self_improvement,
      color: Color(0xFFD4A5B7),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '浠ユ俯鏌旂殑鏂瑰紡瀵瑰緟鑷繁锛屽儚瀵瑰緟濂芥湅鍙嬩竴鏍?,
        '鎵句竴涓畨闈欑殑绌洪棿锛岄棴涓婄溂鐫?,
        '鎶婃墜鏀惧湪蹇冨彛锛屾劅鍙楀績鑴忕殑璺冲姩',
        '榛樺康锛氭垜鍊煎緱琚埍锛屾垜瓒冲濂?,
        '鍥炲繂鑷繁鐨勪紭鐐瑰拰鎴愬氨锛岃偗瀹氳嚜宸?,
        '鍘熻皡鑷繁鐨勪笉瓒冲拰閿欒锛屽畠浠浣犳垚闀?,
        '鎯宠薄缁欒嚜宸变竴涓俯鏆栫殑鎷ユ姳',
        '鎰熷彈杩欎唤鑷垜鍏崇埍鐨勮兘閲?,
        '鎵胯姣忓ぉ閮借鍠勫緟鑷繁',
        '鎱㈡參鐫佸紑鐪肩潧锛屽甫鐫€杩欎唤鐖辩户缁墠琛?,
      ],
    ),
    const _MeditationMode(
      title: '姝ｅ康鍛煎惛',
      description: '娲诲湪褰撲笅',
      icon: Icons.air_outlined,
      color: Color(0xFF7AB893),
      defaultDuration: 600,
      isPro: true,
      phrases: [
        '浠ヨ垝閫傜殑濮垮娍鍧愪笅锛屾尯鐩磋叞鑳?,
        '灏嗘敞鎰忓姏闆嗕腑鍦ㄩ蓟灏栵紝鎰熷彈鍛煎惛鐨勮繘鍑?,
        '涓嶈瘯鍥炬敼鍙樺懠鍚革紝鍙槸瑙傚療瀹?,
        '鍚告皵鏃舵劅鍙楃┖姘旂殑娓呭噳锛屽懠姘旀椂鎰熷彈娓╂殩',
        '褰撴€濈华椋樿蛋鏃讹紝杞昏交鎷夊洖鏉?,
        '涓嶈瘎鍒わ紝涓嶆墽鐫€锛屽彧鏄瀵?,
        '鎰熷彈鍛煎惛鐨勮嚜鐒惰妭濂忥紝涓€鍛间竴鍚?,
        '璁╂墍鏈夌殑蹇靛ご鍍忎簯鏈典竴鏍烽杩?,
        '涓撴敞浜庢鍒伙紝涓撴敞浜庡懠鍚?,
        '鎱㈡參鐫佸紑鐪肩潧锛屼繚鎸佽繖浠借瀵?,
      ],
    ),
    const _MeditationMode(
      title: '鎯呯华骞宠　',
      description: '鎵惧洖鍐呭績骞抽潤',
      icon: Icons.balance,
      color: Color(0xFF9AA5D1),
      defaultDuration: 900,
      isPro: true,
      phrases: [
        '瀹夐潤鍦板潗涓嬶紝鎰熷彈褰撲笅鐨勬儏缁?,
        '涓嶆姉鎷掍换浣曟儏缁紝鍙槸鍏佽瀹冨瓨鍦?,
        '缁欐儏缁懡鍚嶏細杩欐槸鎰ゆ€掞紝杩欐槸鎮蹭激锛岃繖鏄枩鎮?,
        '鎰熷彈鎯呯华鍦ㄨ韩浣撲腑鐨勪綅缃?,
        '娣卞懠鍚革紝璁╂儏缁殢鐫€鍛煎惛娴佸姩',
        '鎯宠薄鎯呯华鍍忔按涓€鏍锋祦杩囦綘鐨勮韩浣?,
        '鎺ョ撼鎵€鏈夌殑鎯呯华锛屽畠浠兘鏄綘鐨勪竴閮ㄥ垎',
        '鎰熷彈鎯呯华閫愭笎骞抽潤涓嬫潵',
        '鎵惧洖鍐呭績鐨勫钩琛′笌瀹侀潤',
        '甯︾潃杩欎唤骞抽潤鍥炲埌褰撲笅',
      ],
    ),
  ];

  // 鐘舵€佸彉閲?
  _MeditationMode? _selectedMode;
  int? _selectedDuration; // 鐢ㄦ埛閫夋嫨鐨勬椂闀匡紙绉掞級
  Timer? _timer;
  Timer? _phraseTimer;
  late AnimationController _progressController;
  late AnimationController _fadeController;

  int _elapsedSeconds = 0;
  int _currentPhraseIndex = 0;
  bool _isPlaying = false;
  bool _isCompleted = false;
  bool _showDurationPicker = false;

  @override
  void initState() {
    super.initState();
    _isPro = PurchaseService().isPro;
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // 閫夋嫨妯″紡骞舵樉绀烘椂闀块€夋嫨鍣?
  void _selectMode(_MeditationMode mode) {
    if (mode.isPro && !PurchaseService().isPro) {
      Navigator.pushNamed(
        context,
        '/pro',
        arguments: {'hint': '瑙ｉ攣楂樼骇鍐ユ兂锛屽寘鍚笓娉ㄥ姏璁粌銆佽韩浣撴壂鎻忕瓑涓撲笟璇剧▼'},
      );
      return;
    }
    setState(() {
      _selectedMode = mode;
      _selectedDuration = mode.defaultDuration;
      _showDurationPicker = true;
    });
  }

  // 寮€濮嬪啣鎯?
  void _startMeditation() {
    final mode = _selectedMode!;
    final durationSeconds = _selectedDuration ?? mode.defaultDuration;

    setState(() {
      _elapsedSeconds = 0;
      _currentPhraseIndex = 0;
      _isPlaying = true;
      _isCompleted = false;
      _showDurationPicker = false;
    });

    _progressController.duration = Duration(seconds: durationSeconds);
    _progressController.forward(from: 0);

    _fadeController.forward(from: 0);

    // 璁＄畻寮曞鏂囧瓧鍒囨崲闂撮殧
    final phraseInterval = durationSeconds ~/ mode.phrases.length;

    // 姣忕鏇存柊璁℃椂鍣?
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        final effectiveDuration = _selectedDuration ?? _selectedMode!.defaultDuration;
        if (_elapsedSeconds >= effectiveDuration) {
          _completeMeditation();
        }
      });
    });

    // 鏍规嵁鏃堕暱鍔ㄦ€佽皟鏁村紩瀵兼枃瀛楀垏鎹㈤鐜?
    _phraseTimer = Timer.periodic(Duration(seconds: phraseInterval), (_) {
      if (!mounted || _isCompleted) return;
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _selectedMode!.phrases.length;
        });
        _fadeController.forward();
      });
    });
  }

  // 瀹屾垚鍐ユ兂
  void _completeMeditation() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.stop();
    setState(() {
      _isPlaying = false;
      _isCompleted = true;
    });
    _showCompletionDialog();
  }

  // 鏆傚仠
  void _pause() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.stop();
    setState(() => _isPlaying = false);
  }

  // 缁х画
  void _resume() {
    setState(() => _isPlaying = true);

    final mode = _selectedMode!;
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;
    _progressController.duration = Duration(seconds: effectiveDuration);
    _progressController.forward(
      from: _elapsedSeconds / effectiveDuration,
    );

    final phraseInterval = effectiveDuration ~/ mode.phrases.length;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        final effectiveDuration = _selectedDuration ?? _selectedMode!.defaultDuration;
        if (_elapsedSeconds >= effectiveDuration) {
          _completeMeditation();
        }
      });
    });

    _phraseTimer = Timer.periodic(Duration(seconds: phraseInterval), (_) {
      if (!mounted || _isCompleted) return;
      _fadeController.reverse().then((_) {
        if (!mounted) return;
        setState(() {
          _currentPhraseIndex =
              (_currentPhraseIndex + 1) % _selectedMode!.phrases.length;
        });
        _fadeController.forward();
      });
    });
  }

  // 杩斿洖妯″紡閫夋嫨
  void _backToModeSelection() {
    _timer?.cancel();
    _phraseTimer?.cancel();
    _progressController.reset();
    _fadeController.reset();
    setState(() {
      _selectedMode = null;
      _selectedDuration = null;
      _elapsedSeconds = 0;
      _currentPhraseIndex = 0;
      _isPlaying = false;
      _isCompleted = false;
      _showDurationPicker = false;
    });
  }

  // 瀹屾垚寮圭獥
  void _showCompletionDialog() {
    final mode = _selectedMode!;
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;
    final minutes = effectiveDuration ~/ 60;
    final seconds = effectiveDuration % 60;
    final durationStr = minutes > 0 ? '$minutes 鍒嗛挓' : '$seconds 绉?;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.self_improvement, color: MirrorColors.primary, size: 28),
            SizedBox(width: 10),
            Text('鍐ユ兂瀹屾垚'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '浣犲仛寰楀緢妫?,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '鏈鍐ユ兂锛?durationStr',
              style: const TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              '妯″紡锛?{mode.title}',
              style: const TextStyle(fontSize: 14, color: MirrorColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              '鑺变竴鐐规椂闂存劅鍙楁鍒荤殑骞抽潤锛屽甫鐫€杩欎唤瀹侀潤缁х画浣犵殑涓€澶┿€?,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: MirrorColors.textSecondary, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _backToModeSelection();
            },
            child: const Text('瀹屾垚'),
          ),
        ],
      ),
    );
  }

  // 鏍煎紡鍖栨椂闂?
  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('鍐ユ兂寮曞'),
        leading: _showDurationPicker
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _backToModeSelection,
              )
            : null,
        actions: [
          if (_selectedMode != null && !_showDurationPicker)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _backToModeSelection,
              tooltip: '閲嶆柊閫夋嫨',
            ),
        ],
      ),
      body: SafeArea(
        child: _showDurationPicker
            ? _buildDurationPicker(isDark)
            : _selectedMode == null
                ? _buildModeSelection(isDark)
                : _buildMeditationSession(isDark),
      ),
    );
  }

  /// 妯″紡閫夋嫨椤?
  Widget _buildModeSelection(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            '閫夋嫨涓€绉嶅啣鎯虫ā寮?,
            style: TextStyle(fontSize: 15, color: MirrorColors.textSecondary),
          ),
        ),
        ...List.generate(getModes(_isPro).length, (index) {
          final mode = getModes(_isPro)[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              child: InkWell(
                onTap: () => _selectMode(mode),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: mode.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(mode.icon, color: mode.color, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    mode.title,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (mode.isPro)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Color(0x80D4C5E2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Pro',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_getDurationLabel(mode.defaultDuration)} 路 ${mode.description}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? MirrorColors.darkTextSecondary
                                    : MirrorColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: mode.color,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// 鏃堕暱閫夋嫨椤?
  Widget _buildDurationPicker(bool isDark) {
    final mode = _selectedMode!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 妯″紡淇℃伅鍗＄墖
        Card(
          margin: const EdgeInsets.only(bottom: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(mode.icon, color: mode.color, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? MirrorColors.darkTextSecondary
                              : MirrorColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 鏍囬
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            '閫夋嫨鍐ユ兂鏃堕暱',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),

        // 鏃堕暱閫夐」缃戞牸
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            // 榛樿鏃堕暱閫夐」锛堟斁鍦ㄧ涓€涓級
            _buildDurationButton(mode.defaultDuration, mode, isDark, isDefault: true),
            // 鍏朵粬棰勮鏃堕暱閫夐」
            ..._durationOptions
                .where((d) => d != mode.defaultDuration)
                .map((duration) => _buildDurationButton(duration, mode, isDark)),
          ],
        ),

        const SizedBox(height: 32),

        // 寮€濮嬫寜閽?
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startMeditation,
            style: ElevatedButton.styleFrom(
              backgroundColor: mode.color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
            ),
            child: const Text(
              '寮€濮嬪啣鎯?,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// 鏃堕暱閫夐」鎸夐挳
  Widget _buildDurationButton(int duration, _MeditationMode mode, bool isDark, {bool isDefault = false}) {
    final isSelected = _selectedDuration == duration;

    return ElevatedButton(
      onPressed: () => setState(() => _selectedDuration = duration),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected
            ? mode.color
            : (isDark ? MirrorColors.darkCardBackground : MirrorColors.cardBackground),
        foregroundColor: isSelected ? Colors.white : (isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide.none
              : BorderSide(
                  color: isDark ? MirrorColors.textSecondary : MirrorColors.textHint,
                  width: 1,
                ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isDefault)
            const Icon(Icons.check, size: 16),
          if (isDefault)
            const SizedBox(width: 6),
          Text(
            _getDurationLabel(duration),
            style: TextStyle(
              fontSize: 15,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 鍐ユ兂杩涜涓?
  Widget _buildMeditationSession(bool isDark) {
    final mode = _selectedMode!;
    final currentPhrase = mode.phrases[_currentPhraseIndex];
    final effectiveDuration = _selectedDuration ?? mode.defaultDuration;

    return Column(
      children: [
        const Spacer(flex: 2),

        // Canvas 鍊掕鏃跺渾鐜?
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 鑳屾櫙鍦嗙幆
              CustomPaint(
                size: const Size(220, 220),
                painter: _CirclePainter(
                  progress: 1.0,
                  color: mode.color.withValues(alpha: 0.1),
                  strokeWidth: 6,
                ),
              ),
              // 杩涘害鍦嗙幆
              if (_elapsedSeconds > 0)
                AnimatedBuilder(
                  animation: _progressController,
                  builder: (context, _) {
                    final progress = _elapsedSeconds / effectiveDuration;
                    return CustomPaint(
                      size: const Size(220, 220),
                      painter: _CirclePainter(
                        progress: progress,
                        color: mode.color,
                        strokeWidth: 6,
                      ),
                    );
                  },
                ),
              // 涓績鏂囧瓧
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w300,
                      color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(effectiveDuration),
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // 寮曞鏂囧瓧锛堟贰鍏ユ贰鍑哄姩鐢伙級
        SizedBox(
          height: 80,
          child: FadeTransition(
            opacity: _fadeController,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                currentPhrase,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode.title,
          style: TextStyle(
            fontSize: 13,
            color: mode.color,
            fontWeight: FontWeight.w600,
          ),
        ),

        const Spacer(),

        // 鎺у埗鎸夐挳
        Padding(
          padding: const EdgeInsets.only(bottom: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 閲嶇疆
              IconButton(
                onPressed: _backToModeSelection,
                icon: const Icon(Icons.replay),
                iconSize: 28,
                color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
              ),
              const SizedBox(width: 24),
              // 鎾斁/鏆傚仠
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: mode.color,
                  boxShadow: [
                    BoxShadow(
                      color: mode.color.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isPlaying ? _pause : _resume,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 24),
              const SizedBox(width: 48), // 鍗犱綅淇濇寔灞呬腑
            ],
          ),
        ),
      ],
    );
  }
}

/// 鍐ユ兂妯″紡鏁版嵁绫?
class _MeditationMode {
  final String title;
  final String description;
  final int defaultDuration;
  final IconData icon;
  final Color color;
  final List<String> phrases;
  final bool isPro;

  const _MeditationMode({
    required this.title,
    required this.description,
    required this.defaultDuration,
    required this.icon,
    required this.color,
    required this.phrases,
    this.isPro = false,
  });
}

/// Canvas 缁樺埗鍊掕鏃跺渾鐜?
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // 浠庨《閮紙-蟺/2锛夊紑濮嬬粯鍒跺姬绾?
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}


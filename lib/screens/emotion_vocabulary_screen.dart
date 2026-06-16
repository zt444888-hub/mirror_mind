import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/purchase_service.dart';

/// 鎯呯华璇嶆眹鎷撳睍 鈥?鎯呯华绮掑害璁粌
class EmotionVocabularyScreen extends StatefulWidget {
  const EmotionVocabularyScreen({super.key});

  @override
  State<EmotionVocabularyScreen> createState() => _EmotionVocabularyScreenState();
}

class _EmotionVocabularyScreenState extends State<EmotionVocabularyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _collected = {}; // 宸叉敹钘忚瘝姹?
  String _dailyWord = ''; // 浠婃棩鎺ㄨ崘璇?

  // ==================== 鎯呯华璇嶆眹搴?====================
  static final Map<String, List<_EmotionWord>> _vocabulary = {
    '寮€蹇?: [
      const _EmotionWord('婊¤冻', '闇€姹傚緱鍒板疄鐜板悗鐨勫厖瀹炴劅', '瀹屾垚涓€澶╃殑宸ヤ綔鍚庯紝韬哄湪娌欏彂涓婏紝鎰熷埌娣辨繁鐨勬弧瓒炽€?, '鑳稿彛娓╂殩锛屽槾瑙掍笉鑷涓婃壃'),
      const _EmotionWord('娆ｆ叞', '鐪嬪埌鍔姏寰楀埌鍥炴姤鏃剁殑瀹夊績', '鐪嬪埌瀛╁瓙鍋ュ悍鎴愰暱锛岀埗姣嶈劯涓婇湶鍑烘鎱扮殑绗戝銆?, '蹇冭烦骞崇ǔ锛屽懠鍚告繁闀?),
      const _EmotionWord('鎯剰', '鑸掗€傝嚜鍦ㄧ殑鎰夋偊鐘舵€?, '鍗堝悗闃冲厜閫忚繃绐楁埛锛屼竴鏉尪涓€鏈功锛屾棤姣旀儸鎰忋€?, '娴戣韩鏀炬澗锛岀湁澶磋垝灞?),
      const _EmotionWord('鍏呭疄', '鏃堕棿琚湁鎰忎箟鍦板～婊＄殑鎰熷彈', '蹇欑浣嗛珮鏁堢殑涓€澶╃粨鏉熷悗锛屾劅鍒版牸澶栧厖瀹炪€?, '韬綋鐣ョ柌鎯絾绮剧楗辨弧'),
      const _EmotionWord('鎰熸仼', '瀵规墍寰椾箣鐗╁績瀛樻劅璋?, '鍥為杩欎竴骞达紝瀵归櫔浼村湪韬竟鐨勪汉鍏呮弧鎰熸仼銆?, '鑳稿彛寰井鍙戠儹锛岀溂鐪跺彲鑳芥箍娑?),
      const _EmotionWord('闆€璺?, '鎶戝埗涓嶄綇鐨勫叴濂嬩笌鏈熷緟', '鏀跺埌姊﹀瘣浠ユ眰鐨刼ffer锛屽唴蹇冮泙璺冧笉宸层€?, '蹇冭烦鍔犻€燂紝鎯宠璺宠捣鏉?),
      const _EmotionWord('鑷湪', '鏃犳嫎鏃犳潫鐨勮交鏉炬劅', '涓€涓汉鏃呰锛岄殢蹇冩墍娆诧紝鏃犳瘮鑷湪銆?, '鍛煎惛鑷敱锛屾浼愯交蹇?),
      const _EmotionWord('娆㈡', '鍙戣嚜鍐呭績鐨勫枩鎮?, '涔呭埆閲嶉€紝婊″績娆㈡锛岃█璇兘鏃犳硶琛ㄨ揪銆?, '绗戝钘忎笉浣忥紝鐪肩潧鍙戜寒'),
    
      const _EmotionWord('鎸', '绮剧鐒曞彂銆佸厖婊″姏閲忕殑鏄傛壃鐘舵€?, '鍚埌杩欎釜濂芥秷鎭紝鏁翠釜浜洪兘鎸浜嗚捣鏉ャ€?, '鑳岃剨鎸虹洿锛岀溂鐫涘彂浜紝鍏呮弧骞插姴'),
      const _EmotionWord('鏁晱', '闈㈠宕囬珮鎴栦紵澶т簨鐗╂椂鐨勮們鐒惰捣鏁?, '闈㈠娴╃€氭槦绌猴紝蹇冧腑娑岃捣娣辨繁鐨勬暚鐣忋€?, '鍛煎惛鏀剧紦锛屽績澧冨紑闃?),
      const _EmotionWord('闄堕唹', '娌夋蹈鍦ㄧ編濂戒綋楠屼腑鐨勫繕鎴戠姸鎬?, '闊充箰浼氫笂锛屽ス闂笂鐪肩潧锛屽畬鍏ㄩ櫠閱夊湪鏃嬪緥涓€?, '韬綋寰井鎽囨憜锛岃〃鎯呮矇閱?),
      const _EmotionWord('鐥涘揩', '灏芥儏灏藉叴鐨勭晠蹇劅', '鎵撳畬涓€鍦虹悆锛屽ぇ姹楁穻婕擄紝璇翠笉鍑虹殑鐥涘揩銆?, '娴戣韩鑸掔晠锛岃劯涓婃寕鐫€绗戞剰'),
    ],
    '鎮蹭激': [
      const _EmotionWord('澶辫惤', '鏈熷緟钀界┖鍚庣殑绌鸿櫄鎰?, '閿欒繃浜嗕竴娆￠噸瑕佺殑鏈轰細锛屽績閲岀┖钀借惤鐨勩€?, '鑳稿彛鍙戦椃锛岃偐鑶€涓嬪瀭'),
      const _EmotionWord('鎬呯劧', '鑻ユ湁鎵€澶辩殑娣℃贰蹇т激', '鑰佹瓕鍝嶈捣锛屾兂璧蜂粠鍓嶏紝涓€涓濇€呯劧娴笂蹇冨ご銆?, '鐩厜鏀剧┖锛屽懠鍚稿彉鎱?),
      const _EmotionWord('瀛ょ嫭', '娓存湜杩炴帴鍗存棤娉曡繛鎺ョ殑鐘舵€?, '浜虹兢涓殑鐙傛锛屽嵈鎰熷埌鏃犲彲瑷€璇寸殑瀛ょ嫭銆?, '韬綋閫€缂╋紝鎯虫姳绱ц嚜宸?),
      const _EmotionWord('鎬€蹇?, '瀵圭編濂借繃寰€鐨勬俯鏌斿洖蹇?, '缈荤湅鏃х収鐗囷紝鎬€蹇甸偅浜涘洖涓嶅幓鐨勬椂鍏夈€?, '鍢磋甯︾瑧浣嗙溂鐪舵箍娑?),
      const _EmotionWord('閬楁喚', '瀵规湭鍋氫箣浜嬬殑鎯嬫儨', '濡傛灉褰撴椂鍕囨暍涓€鐐癸紝涔熻灏变笉浼氭湁浠婂ぉ鐨勯仐鎲俱€?, '蹇冮噷鏈夊潡鐭冲ご鍘嬬潃'),
      const _EmotionWord('濮斿眻', '涓嶈鐞嗚В鏃剁殑闅愬繊闅捐繃', '鏄庢槑寰堝姫鍔涘嵈琚瑙ｏ紝蹇冮噷璇翠笉鍑虹殑濮斿眻銆?, '鍠夊挋鍙戠揣锛屾兂鍝絾蹇嶄綇'),
      const _EmotionWord('钀藉癁', '绻佸崕杩囧悗鐨勫喎娓?, '鑱氫細鐨勭儹闂规暎鍘伙紝鐙嚜涓€浜烘劅鍒拌惤瀵炪€?, '鑴氭鍙樻矇锛屼笉鎯宠璇?),
      const _EmotionWord('蹇冮吀', '涓轰粬浜烘垨鑷繁鐨勯伃閬囨劅鍒伴毦杩?, '鐪嬪埌娴佹氮鐨勫皬鍔ㄧ墿锛屽績閲屼竴闃靛績閰搞€?, '榧诲ご閰告订锛屽績鍙ｅ埡鐥?),
    
      const _EmotionWord('鑻︽订', '闅句互瑷€璇寸殑杈涢吀涓庢棤濂堜氦缁?, '鎯宠捣閭ｆ鑹伴毦鐨勫瞾鏈堬紝蹇冧腑婊℃槸鑻︽订銆?, '鍙ｄ腑鍙戣嫤锛岀湁澶寸揣鐨?),
      const _EmotionWord('鎯嗘€?, '鑻ユ湁鎵€澶便€佽尗鐒舵棤渚濈殑鎯嗘€?, '鍛婂埆鏁呭弸锛岀嫭鑷蛋鍦ㄨ澶达紝鎬呯劧鑻ュけ銆?, '姝ヤ紣缂撴參锛岀洰鍏夋父绂?),
      const _EmotionWord('棰撲抚', '涓уけ淇″績鍜屾枟蹇楃殑浣庤惤鐘舵€?, '鎺ヨ繛澶辫触鍚庯紝浠栧彉寰楅涓э紝浠€涔堥兘涓嶆兂鍋氥€?, '韬綋铚风缉锛屼綆澶翠笉璇?),
      const _EmotionWord('鎬ㄦ劋', '鍥犲彈鍒颁笉鍏瀵瑰緟鑰屼骇鐢熺殑鎰ゆ€掍笌濮斿眻', '琚棤鏁呰鍛橈紝蹇冧腑鎬ㄦ劋闅惧钩銆?, '鎷冲ご绱ф彙锛岃兏闂锋皵鐭?),
    ],
    '鎰ゆ€?: [
      const _EmotionWord('鐑﹁簛', '琚弽澶嶅共鎵板悗浜х敓鐨勪笉鑰愮儲', '鎵嬫満涓嶅仠寮瑰嚭娑堟伅锛岃秺鏉ヨ秺鐑﹁簛銆?, '鐪夊ご绱ч攣锛屾兂瑕佹憯涓滆タ'),
      const _EmotionWord('鎰ゆ噾', '鍐呭績鐨勪笉骞充笌鍘嬫姂', '鏄庢槑鏄嚜宸辩殑鍔熷姵鍗磋鎶㈣蛋锛屾劋鎳戦毦骞炽€?, '鑳稿彛鍫靛緱鎱岋紝鎷冲ご涓嶈嚜瑙夋彙绱?),
      const _EmotionWord('鎭兼€?, '琚啋鐘悗鐨勭敓姘?, '瀵规柟鏃犵悊鍙栭椆鐨勬€佸害璁╀汉鎭兼€掋€?, '鑴稿彂绾紝鍛煎惛鎬ヤ績'),
      const _EmotionWord('涓嶆弧', '瀵圭幇鐘剁殑鎶辨€ㄤ笌涓嶇敇', '浠樺嚭涓庡洖鎶ヤ笉鎴愭姣旓紝鍐呭績鍏呮弧涓嶆弧銆?, '鑵逛腑闅愰殣浣滅棝'),
      const _EmotionWord('鎲庢伓', '瀵逛笉鍏垨鎭惰鐨勫己鐑堝弽鎰?, '鐪嬪埌娆哄噷寮卞皬鐨勮涓猴紝蹇冧腑娑岃捣鎲庢伓銆?, '鍏ㄨ韩绱х环锛岀墮榻垮挰绱?),
      const _EmotionWord('鎲嬪眻', '鏈夋皵鍙戜笉鍑虹殑鍘嬫姂', '鏄庣煡閬撹嚜宸辨病閿欏嵈琚寚璐ｏ紝瀹炲湪鎲嬪眻銆?, '鍠夊挋鍍忔槸琚粈涔堝牭浣?),
      const _EmotionWord('婵€鎰?, '鍥犱笉鍏钩鑰岀垎鍙戠殑寮虹儓鎯呯华', '鐪嬪埌鐪熺浉琚帺鐩栵紝缇や紬婵€鎰や笉宸层€?, '鑲句笂鑵虹礌椋欏崌锛屽０闊冲彂鎶?),
      const _EmotionWord('鎬ㄦ皵', '闀挎湡绉疮鐨勪笉婊?, '涓€鐩撮粯榛樻壙鍙楋紝蹇冮噷鏀掍簡澶鎬ㄦ皵銆?, '鑲╄唨閰哥棝锛岃兏闂锋皵鐭?),
    
      const _EmotionWord('缇炴劎', '鍥犺嚜韬涓烘垨鐘舵€佷笉绗﹀悎鏈熸湜鑰屼骇鐢熺殑缇炶€绘劅', '褰撲紬琚寚鍑洪敊璇紝缇炴劎寰楁弧鑴搁€氱孩銆?, '鑴哥儳寰楀帀瀹筹紝鎯虫壘涓湴缂濋捇杩涘幓'),
      const _EmotionWord('灞堣颈', '浜烘牸鍙楀埌璺佃笍鍚庣殑鏋佸害闅惧彈', '琚綋浼楃緸杈辩殑閭ｄ竴鍒伙紝蹇冧腑鍏呮弧灞堣颈銆?, '鍏ㄨ韩鍍电‖锛屽績鍙ｅ墽鐥?),
      const _EmotionWord('鏀句笅', '鏀句笅鎬ㄦ仺鍚庣殑杞绘澗涓庤В鑴?, '缁堜簬鍘熻皡浜嗛偅涓汉锛屽績涓竴闃甸噴鐒躲€?, '闀胯垝涓€鍙ｆ皵锛岃偐澶磋交鏉?),
      const _EmotionWord('鎮叉偗', '瀵逛粬浜鸿嫤闅剧殑娣卞垏鍚屾儏涓庡叧鎬€', '鐪嬪埌鐏惧尯瀛╁瓙鐨勭溂绁烇紝蹇冧腑娑岃捣鎮叉偗銆?, '鐪肩湺婀挎鼎锛屾兂鍋氱偣浠€涔?),
    ],
    '鎭愭儳': [
      const _EmotionWord('绱у紶', '闈㈠鍘嬪姏鏃剁殑绱х环鐘舵€?, '涓婂彴鍓嶆墜蹇冨嚭姹楋紝绱у紶寰楀繕浜嗗彴璇嶃€?, '鎵嬪績鍐掓睏锛屽績璺冲姞蹇?),
      const _EmotionWord('涓嶅畨', '闅愰殣绾︾害鐨勪笉韪忓疄鎰?, '鎬昏寰楁湁浠€涔堜笉濂界殑浜嬭鍙戠敓锛屽績绁炰笉瀹併€?, '鑳冮儴涓嶉€傦紝鍧愮珛闅惧畨'),
      const _EmotionWord('鎯舵亹', '闈㈠鏈煡鏃剁殑娣辨繁鎭愭儳', '榛戞殫涓嫭鑷璧帮紝鍐呭績鎯舵亹涓嶅凡銆?, '韬綋鍙戞姈锛屾兂瑕侀€冭窇'),
      const _EmotionWord('鐒﹁檻', '瀵规湭鏉ョ殑杩囧害鎷呭咖', '鍛ㄦ棩鐨勬櫄涓婏紝瀵规柊鐨勪竴鍛ㄦ劅鍒扮劍铏戙€?, '蹇冩厡锛屽懠鍚哥煭淇?),
      const _EmotionWord('鑳嗘€?, '闈㈠鎸戞垬鏃剁殑閫€缂?, '鎯充妇鎵嬪彂瑷€鍗村洜涓鸿儐鎬€屾斁寮冦€?, '韬綋鍍电‖锛岃璇濆０闊冲彉灏?),
      const _EmotionWord('鐣忔儳', '瀵瑰己澶у姏閲忕殑瀹虫€?, '闈㈠涓ュ帀鐨勪笂鍙革紝蹇冧腑鍏呮弧鐣忔儳銆?, '鐪肩韬查棯锛屾兂瑕佺缉灏忚嚜宸?),
      const _EmotionWord('鎯婃兌', '绐佸彂鐘跺喌涓嬬殑鎱屼贡', '绐佺劧鍚埌宸ㄥ搷锛屼竴鏃堕棿鎯婃兌澶辨帾銆?, '鏈兘韬查棯锛屽ぇ鑴戠┖鐧?),
      const _EmotionWord('蹇愬繎', '绛夊緟缁撴灉鏃剁殑涓冧笂鍏笅', '鑰冭瘯鍓嶇殑澶滄櫄锛屽績閲屽繍蹇戜笉瀹夈€?, '鑳冮噷缈绘睙鍊掓捣锛岀潯涓嶅畨绋?),
    
      const _EmotionWord('鐤忕', '涓庝粬浜烘垨鐜浜х敓闅旈槀鐨勯檶鐢熸劅', '鍦ㄧ儹闂圭殑鑱氫細涓婏紝鍗存劅鍒版繁娣辩殑鐤忕銆?, '涓嬫剰璇嗘媺寮€璺濈锛屼笉鎰夸氦娴?),
      const _EmotionWord('渚濇亱', '杩囧害渚濊禆鏌愪汉鑰屼骇鐢熺殑鍒嗙鎭愭儳', '姣忔鍒嗗埆閮芥劅鍒板己鐑堢殑涓嶅畨涓庝緷鎭嬨€?, '鎯崇揣绱ф姄浣忓鏂逛笉鏀?),
      const _EmotionWord('鎰х枤', '鍥犱簭娆犱粬浜鸿€屼骇鐢熺殑鑷矗涓庝笉瀹?, '閿欒繃浜嗗瀛愮殑鎴愰暱锛屽績涓弧鏄劎鐤氥€?, '蹇冨彛鍙戞矇锛屼笉鏁㈢洿瑙嗗鏂?),
      const _EmotionWord('鎴掑', '瀵圭幆澧冩垨浠栦汉淇濇寔璀︽儠鐨勯槻寰＄姸鎬?, '鐙嚜璧板璺椂锛屾湰鑳藉湴淇濇寔鎴掑銆?, '鑲岃倝绱х环锛屾椂鍒绘敞鎰忓懆鍥?),
    ],
    '鎯婅': [
      const _EmotionWord('鎯婂枩', '鍑轰箮鎰忔枡鐨勭編濂戒綋楠?, '鐢熸棩褰撳ぉ鏀跺埌浜嗚繙鏂瑰瘎鏉ョ殑绀肩墿锛屾弧婊℃儕鍠溿€?, '鐫佸ぇ鐪肩潧锛屽槾瑙掍笂鎵?),
      const _EmotionWord('璇у紓', '瀵逛笉鍚堝父鐞嗕箣浜嬬殑鐤戦棶', '鍚埌杩欎釜鍐冲畾锛屽ぇ瀹堕兘鎰熷埌璇у紓銆?, '鐪夋瘺鎵捣锛屽仠椤跨墖鍒?),
      const _EmotionWord('闇囨捈', '琚法澶х殑浜嬬墿鎵€鍐插嚮', '闈㈠澹附鐨勮嚜鐒舵櫙瑙傦紝鍐呭績鏃犳瘮闇囨捈銆?, '璇翠笉鍑鸿瘽锛屽叏韬捣楦＄毊鐤欑槱'),
      const _EmotionWord('鏂板', '瀵规湭鐭ヤ簨鐗╃殑濂藉蹇?, '绗竴娆℃潵鍒拌繖搴у煄甯傦紝涓€鍒囬兘鍏呮弧鏂板銆?, '鐪肩潧鏀惧厜锛屽洓澶勫紶鏈?),
      const _EmotionWord('鎯婂徆', '瀵逛紭绉€浜嬬墿鐨勭敱琛疯禐缇?, '鐪嬪埌绮剧編鐨勮壓鏈搧锛屼笉鐢卞緱鍙戝嚭鎯婂徆銆?, '鍢村反寰紶锛屾兂榧撴帉'),
      const _EmotionWord('閿欐剷', '绐佸鍏舵潵鐨勬剰澶栬浜烘劊浣?, '鍚埌绂昏亴鐨勬秷鎭紝澶у閮介敊鎰曚簡銆?, '鍛嗕綇涓嶅姩锛岃剳瀛愯浆涓嶈繃鏉?),
    
      const _EmotionWord('鑷€?, '瀵硅嚜宸遍伃閬囩殑鍚屾儏涓庢€滄儨', '涓€涓汉鎾戜簡杩欎箞涔咃紝绐佺劧鏈変簺鑷€溿€?, '鎯宠鎶变綇鑷繁锛岀溂鐪跺彂閰?),
      const _EmotionWord('褰峰鲸', '鍦ㄦ妷鎷╅潰鍓嶈糠鑼棤鎺殑鐘舵€?, '绔欏湪浜虹敓鐨勫崄瀛楄矾鍙ｏ紝鍐呭績褰峰鲸涓嶅凡銆?, '鏉ュ洖韪辨锛屽績绁炰笉瀹?),
      const _EmotionWord('鍧︾劧', '闂績鏃犳劎鐨勫钩闈欎笌瀹夊畾', '璇ュ仛鐨勯兘鍋氫簡锛岀粨鏋滃浣曢兘鑳藉潶鐒堕潰瀵广€?, '鍛煎惛骞崇ǔ锛岀鎬佷粠瀹?),
      const _EmotionWord('璞佽揪', '鐪嬪紑涓栦簨鍚庣殑寮€闃斿績澧?, '缁忓巻浜嗛椋庨洦闆紝鍙嶈€屽彉寰楁洿鍔犺眮杈句簡銆?, '鐪夊畤鑸掑睍锛岀瑧澹扮埥鏈?),
      const _EmotionWord('鑷渷', '鍚戝唴瀹¤鑷繁鐨勫弽鎬濈姸鎬?, '澶滄繁浜洪潤鏃讹紝涔犳儻鎬у湴寮€濮嬭嚜鐪併€?, '瀹夐潤鐙锛岃鐪熸€濊€?),
      const _EmotionWord('鍧氭瘏', '鍐呭績鍧氬畾銆佷笉涓哄鐣屽姩鎽囩殑纭俊鎰?, '铏界劧鍓嶈矾鏈煡锛屼絾鍐呭績鏍煎绗冨畾銆?, '姝ヤ紣鏈夊姏锛岀溂绁炲潥瀹?),
    ],
    '骞抽潤': [
      const _EmotionWord('鎭贰', '涓嶈拷姹傚悕鍒╃殑娣＄劧', '鍦ㄥ北闂磋涔﹀搧鑼讹紝鏃ュ瓙鎭贰鑰屽厖瀹炪€?, '鍛煎惛骞崇紦锛屽績濡傛姘?),
      const _EmotionWord('浠庡', '闈㈠鍙樻晠闀囧畾鑷嫢', '闈㈣瘯鏃惰櫧鐒剁揣寮狅紝浣嗗ス鍗佸垎浠庡銆?, '姝ヤ紣绋冲仴锛屽０闊冲钩绋?),
      const _EmotionWord('骞冲拰', '鍐呭績瀹夊畞涓庝笘鏃犱簤', '蹇冩€佽秺鏉ヨ秺骞冲拰锛屼笉鍐嶄负灏忎簨璁¤緝銆?, '鐪夌溂鑸掑睍锛岄潰甯﹀井绗?),
      const _EmotionWord('瀹侀潤', '娌℃湁鍣煶鐨勫畨璋?, '娓呮櫒鐨勬箹杈逛竴鐗囧畞闈欍€?, '鑰虫湹鏀炬澗锛屾€濈华瀹夐潤'),
      const _EmotionWord('娉扮劧', '闈㈠鍥伴毦娌夌ǔ娣″畾', '鏃犺鍙戠敓浠€涔堜粬鎬绘槸涓€鍓嘲鐒惰嚜鑻ョ殑鏍峰瓙銆?, '鑲╄唨鏀炬澗锛屽懠鍚稿潎鍖€'),

      const _EmotionWord('瀹夊畞', '鍐呭績鏃犳尝婢滅殑骞冲拰', '澶滄櫄鍏洯鏁ｆ锛屾劅鍙椾箙杩濈殑瀹夊畞銆?, '鍛煎惛鍧囧寑锛岃偐閮ㄦ斁鏉?),
      const _EmotionWord('閲婄劧', '鏀句笅璐熸媴鍚庣殑杞绘澗', '缁堜簬鎯抽€氫簡閭ｄ欢浜嬶紝蹇冧腑閲婄劧銆?, '闀胯垝涓€鍙ｆ皵锛岃偐澶翠竴鏉?),
      const _EmotionWord('娣＄劧', '鐪嬮€忎笘浜嬬殑浠庡', '缁忓巻寰楀浜嗭紝闈㈠寰楀け鍙嶈€屾贰鐒朵簡銆?, '璇磋瘽璇€熷彉鎱紝琛ㄦ儏骞抽潤'),
      const _EmotionWord('涓撴敞', '鍏ㄧ璐敞鐨勫績娴佺姸鎬?, '鐢荤敾鐨勬椂鍊欎笘鐣屼豢浣涢兘闈欎笅鏉ヤ簡锛屾棤姣斾笓娉ㄣ€?, '蹇樿鏃堕棿锛屾矇娴稿叾涓?),
      const _EmotionWord('绗冨畾', '蹇冧腑鏈夋暟鐨勭‘瀹氭劅', '鍋氬嚭鍐冲畾鍚庡唴蹇冩牸澶栫瑑瀹氥€?, '姝ヤ紣绋冲仴锛岀溂绁炲潥瀹?),
      const _EmotionWord('鏉惧紱', '涓嶇揣缁风殑鑷湪鐘舵€?, '鍋囨湡绗竴澶╃殑鏃╂櫒锛屾暣涓汉鏉惧紱浜嗕笅鏉ャ€?, '鑲岃倝鏉捐蒋锛岀湁澶磋垝灞?),
    
      const _EmotionWord('涓嶇敇', '瀵规湭杈炬垚鐨勭洰鏍囧績瀛橀仐鎲句笌涓嶆湇', '宸竴鍒嗗氨鑳介€氳繃锛屾兂璧锋潵杩樻槸涓嶇敇蹇冦€?, '蹇冮噷鍍忔湁浠€涔堜笢瑗跨鐫€'),
      const _EmotionWord('闅愬繊', '寮哄繊鐫€涓嶈銆佷笉琛ㄧ幇鍑烘潵鐨勫厠鍒剁姸鎬?, '涓轰簡澶у眬锛屼粬閫夋嫨浜嗛殣蹇嶄笉鍙戙€?, '鍜揣鐗欏叧锛屾嫵澶村湪琚栦腑鎻＄揣'),
      const _EmotionWord('鎭婚殣', '瀵瑰急鑰呮垨鍙楀鑰呬骇鐢熺殑澶╃劧鍚屾儏蹇?, '鐪嬬潃涔炶鐨勮€佷汉锛屾伝闅愪箣蹇冩补鐒惰€岀敓銆?, '蹇冨彛寰井鍙戦吀锛屾兂浼告墜甯繖'),
      const _EmotionWord('鎵у康', '鏃犳硶鏀句笅鐨勫己鐑堝潥鎸佷笌鐗垫寕', '杩欎箞澶氬勾浜嗭紝蹇冧腑閭ｄ唤鎵у康浠嶇劧鏀句笉涓嬨€?, '鍙嶅鎬濋噺锛岄毦浠ラ噴鎬€'),
      const _EmotionWord('閲婃€€', '缁堜簬鏀句笅鐨勮交鏉句笌閲婄劧', '澶氬勾鍚庨噸閫竴绗戯紝閭ｄ簺杩囧線缁堜簬閲婃€€浜嗐€?, '鍢磋甯︾瑧锛屽績涓竴鐗囨緞婢?),
      const _EmotionWord('椤挎偀', '鐬棿棰嗘偀鐪熺浉鐨勯€氶€忔劅', '璇诲埌鏌愬彞璇濇椂绐佺劧椤挎偀锛屽師鏉ュ姝ゃ€?, '鐚涚劧鎶ご锛岀溂鐫涗竴浜?),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _vocabulary.length, vsync: this);
    _setDailyWord();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 鏍规嵁鏃ユ湡璁剧疆姣忔棩鎺ㄨ崘璇?
  void _setDailyWord() {
    final allWords = _vocabulary.values.expand((list) => list).toList();
    final seed = DateTime.now().day;
    _dailyWord = allWords[seed % allWords.length].name;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categories = _vocabulary.keys.toList();

    return Scaffold(
      backgroundColor: isDark ? MirrorColors.darkBackground : MirrorColors.background,
      appBar: AppBar(
        title: const Text('鎯呯华璇嶅簱'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: MirrorColors.primaryDark,
          unselectedLabelColor: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
          indicatorColor: MirrorColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: categories.map((c) {
            final emoji = _categoryEmoji(c);
            return Tab(text: '$emoji $c');
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // 浠婃棩鎺ㄨ崘璇?
          _buildDailyBanner(isDark),
          // Tab 鍐呭
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: categories.map((category) {
                final words = _vocabulary[category]!;
                return _buildWordList(isDark, words, category);
              }).toList(),
            ),
          ),
          // Pro 閿佸畾鍖?
          if (!PurchaseService().isPro) _buildProBanner(isDark),
        ],
      ),
    );
  }

  /// 浠婃棩鎺ㄨ崘妯箙
  Widget _buildDailyBanner(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.4),
            MirrorColors.accentLight.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('馃摉', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '浠婃棩鎯呯华璇嶆眹',
                  style: TextStyle(fontSize: 12, color: MirrorColors.textSecondary),
                ),
                const SizedBox(height: 2),
                Text(
                  _dailyWord,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: MirrorColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
          if (_collected.contains(_dailyWord))
            const Icon(Icons.bookmark, color: MirrorColors.accent),
        ],
      ),
    );
  }

  /// 璇嶆眹鍒楄〃锛圥ro 鐢ㄦ埛鏄剧ず鍏ㄩ儴锛屽厤璐圭敤鎴锋樉绀烘瘡绫诲墠 N 涓級
  Widget _buildWordList(bool isDark, List<_EmotionWord> words, String category) {
    final isPro = PurchaseService().isPro;
    // 鍏嶈垂鐢ㄦ埛鏄剧ず鏁伴噺锛氭儕璁?骞抽潤 6 涓紝鍏朵粬 8 涓?
    final freeLimit = (category == '鎯婅' || category == '骞抽潤') ? 6 : 8;
    final displayWords = isPro ? words : words.take(freeLimit).toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: displayWords.length,
      itemBuilder: (context, index) {
        final word = displayWords[index];
        final isCollected = _collected.contains(word.name);
        return _buildWordCard(isDark, word, isCollected);
      },
    );
  }

  /// 璇嶆眹鍗＄墖
  Widget _buildWordCard(bool isDark, _EmotionWord word, bool isCollected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _showWordDetail(word),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          word.name,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          word.definition,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '渚嬪彞锛?{word.example}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    if (isCollected) {
                      _collected.remove(word.name);
                    } else {
                      _collected.add(word.name);
                    }
                  });
                },
                icon: Icon(
                  isCollected ? Icons.bookmark : Icons.bookmark_border,
                  color: isCollected ? MirrorColors.accent : MirrorColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 璇嶆眹璇︽儏寮圭獥
  void _showWordDetail(_EmotionWord word) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(word.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Color(0x80D4C5E2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(word.definition,
                style: const TextStyle(fontSize: 14, color: MirrorColors.primaryDark)),
            ),
            const SizedBox(height: 16),
            const Text('渚嬪彞', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
            const SizedBox(height: 4),
            Text(word.example, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? MirrorColors.darkTextPrimary : MirrorColors.textPrimary)),
            const SizedBox(height: 16),
            const Text('韬綋鎰熷彈', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: MirrorColors.textSecondary)),
            const SizedBox(height: 4),
            Text(word.bodyFeeling, style: TextStyle(fontSize: 14, height: 1.5, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                if (_collected.contains(word.name)) {
                  _collected.remove(word.name);
                } else {
                  _collected.add(word.name);
                }
              });
              Navigator.pop(ctx);
            },
            child: Text(_collected.contains(word.name) ? '鍙栨秷鏀惰棌' : '鏀惰棌璇嶆眹'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('鍏抽棴')),
        ],
      ),
    );
  }

  String _categoryEmoji(String category) {
    switch (category) {
      case '寮€蹇?: return '馃槉';
      case '鎮蹭激': return '馃槩';
      case '鎰ゆ€?: return '馃槫';
      case '鎭愭儳': return '馃槰';
      case '鎯婅': return '馃槻';
      case '骞抽潤': return '馃槍';
      default: return '馃挱';
    }
  }

  /// Pro 閿佸畾鍖?
  Widget _buildProBanner(bool isDark) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            MirrorColors.primaryLight.withValues(alpha: 0.4),
            MirrorColors.secondaryLight.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: MirrorColors.primaryLight.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: MirrorColors.primaryDark.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pro',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: MirrorColors.primaryDark),
                ),
              ),
              const SizedBox(width: 10),
              const Text('馃敁', style: TextStyle(fontSize: 22)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '瑙ｉ攣 Pro 鎺㈢储鍏ㄩ儴 72 璇嶆眹',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: MirrorColors.primaryDark),
          ),
          const SizedBox(height: 6),
          Text(
            '姣忎釜鎯呯华绫诲瀷鎵╁睍鑷?12 涓簿鍑嗚瘝姹囷紝闄勬繁搴﹁瘝瑙ｄ笌鍦烘櫙渚嬪彞',
            style: TextStyle(fontSize: 13, color: isDark ? MirrorColors.darkTextSecondary : MirrorColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/pro'),
            style: ElevatedButton.styleFrom(
              backgroundColor: MirrorColors.primaryDark,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('绔嬪嵆瑙ｉ攣'),
          ),
        ],
      ),
    );
  }
}

/// 鎯呯华璇嶆眹鏁版嵁绫?
class _EmotionWord {
  final String name;
  final String definition;
  final String example;
  final String bodyFeeling;

  const _EmotionWord(this.name, this.definition, this.example, this.bodyFeeling);
}


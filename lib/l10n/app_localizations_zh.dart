// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Aria';

  @override
  String get composerHint => '想让 Aria 做什么？';

  @override
  String get send => '发送';

  @override
  String get stop => '停止';

  @override
  String get untitled => '未命名';

  @override
  String get back => '返回';

  @override
  String minutesShort(int count) {
    return '$count 分钟';
  }

  @override
  String secondsShort(int count) {
    return '$count 秒';
  }

  @override
  String get details => '详情';

  @override
  String get stepInput => '输入';

  @override
  String get stepOutput => '输出';

  @override
  String moreWaiting(int count) {
    return '$count 个决定在排队';
  }

  @override
  String get toolCall => '工具调用';

  @override
  String get reconnecting => '正在重新连接。草稿已保留，停止键仍然可用。';

  @override
  String get settings => '设置';

  @override
  String get executorProfiles => '执行端';

  @override
  String get addExecutor => '添加执行端';

  @override
  String get editExecutor => '编辑执行端';

  @override
  String get deleteExecutor => '删除执行端';

  @override
  String deleteExecutorConfirm(String name) {
    return '删除「$name」？此操作不可撤销。';
  }

  @override
  String get executorName => '名称';

  @override
  String get executorUrl => 'Agent 地址';

  @override
  String get executorToken => '访问令牌（可选）';

  @override
  String get tokenUnchanged => '留空则保留已保存的令牌。';

  @override
  String get executorCwd => '工作目录';

  @override
  String get executorCwdHint => 'Agent 主机上的绝对路径';

  @override
  String get executorUrlInvalid => '请输入 ws:// 或 wss:// 地址。';

  @override
  String get requiredField => '必填';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get noExecutors => '还没有执行端';

  @override
  String get noExecutorsBody => '添加一个 ACP 端点即可开始。';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '中文';

  @override
  String get errorNetwork => '连不上这个执行端。检查地址与网络。';

  @override
  String get errorAuth => '执行端拒绝了令牌。';

  @override
  String get errorProtocol => '这个端点不是在说 ACP v1。';

  @override
  String errorRemote(int code) {
    return '执行端返回了错误（$code）。';
  }

  @override
  String get errorStorage => '本地保存失败，不过内容还在屏幕上。';

  @override
  String get errorUnknown => '出了点问题。';

  @override
  String get errorAgentStopped => '执行端没做完就停下了，请重试。';

  @override
  String get errorRefused => '执行端拒绝继续，换个说法或调整做法。';

  @override
  String get errorTruncated => '回答达到模型的 token 上限，被截断了。';

  @override
  String get retry => '重试';

  @override
  String get connectSubtitle => '选一个 Agent 连接。';

  @override
  String get connect => '连接';

  @override
  String get connecting => '连接中…';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '已断开';

  @override
  String get connectFirstAgent => '先接上一个 Agent';

  @override
  String get connectFirstAgentBody => '添加一个执行端，Aria 才能开始做事。';

  @override
  String get connectAria => '连接 Aria';

  @override
  String get connectingAria => '正在连接 Aria';

  @override
  String get connectionFailed => '连接失败';

  @override
  String get changeAgent => '切换';

  @override
  String get chooseAgent => '选择 Agent';

  @override
  String get reconnectingShort => '重连中';

  @override
  String get manageExecutors => '管理 Agent';

  @override
  String get newChat => '新对话';

  @override
  String get sessions => '最近';

  @override
  String get noSessions => '还没有会话。';

  @override
  String get switchConnection => '切换连接';

  @override
  String get signOut => '退出';

  @override
  String get refresh => '刷新';

  @override
  String get model => '模型';

  @override
  String get mode => '模式';

  @override
  String get effort => '推理强度';

  @override
  String get processTitle => '执行过程';

  @override
  String get processEmpty => '没有执行过程。';

  @override
  String get thinkingProcess => '思考过程';

  @override
  String get processThinking => '正在思考';

  @override
  String get processAnswering => '正在整理回复';

  @override
  String processDone(int count) {
    return '已完成 · $count 步';
  }

  @override
  String get heroQuestion => '要做什么，直接说。';

  @override
  String get homeComposeHint => '描述任务，开启新对话';

  @override
  String get startConversation => '开始新对话';

  @override
  String get recentConversations => '最近对话';

  @override
  String takesThis(String name) {
    return '由 $name 接';
  }

  @override
  String get noConversations => '还没有对话。从一件具体的小事开始。';

  @override
  String get searchConversations => '搜索对话';

  @override
  String get findConversation => '搜索';

  @override
  String get searchKicker => '搜索';

  @override
  String get searchHint => '输入关键词';

  @override
  String noSearchResults(String query) {
    return '没有找到「$query」。换个词试试。';
  }

  @override
  String get conversations => '对话';

  @override
  String get youPrefix => '你：';

  @override
  String get newConversation => '新对话';

  @override
  String get now => '现在';

  @override
  String minutesAgo(int count) {
    return '$count 分钟前';
  }

  @override
  String hoursAgo(int count) {
    return '$count 小时前';
  }

  @override
  String get settingsKicker => 'ARIA';

  @override
  String get theme => '主题';

  @override
  String get themeDark => '深色';

  @override
  String get themeLight => '浅色';

  @override
  String get themeSystem => '跟随';

  @override
  String get agents => 'Agent';

  @override
  String get agent => 'Agent';

  @override
  String get addAgent => '添加 Agent';

  @override
  String get agentName => '名称';

  @override
  String get agentNameHint => '比如：查';

  @override
  String get agentNameTaken => '这个名字已经用过了';

  @override
  String get tokenOptionalHint => '留空表示不需要';

  @override
  String get agentDesc => '负责什么';

  @override
  String get agentDescHint => '一句话就够';

  @override
  String get agentDefault => '默认';

  @override
  String get makeDefault => '设为默认';

  @override
  String get connectThisAgent => '连接这个 Agent';

  @override
  String defaultSet(String name) {
    return '已将 $name 设为默认';
  }

  @override
  String get defaultCannotDelete => '默认不能删，先把下一个设为默认';

  @override
  String get disconnectToDelete => '断开连接后才能删除这个 Agent。';

  @override
  String get add => '添加';

  @override
  String agentAdded(String name) {
    return '加了 $name';
  }

  @override
  String agentDeleted(String name) {
    return '已删除 $name';
  }

  @override
  String get agentSaved => '配置已保存';

  @override
  String get agentLocked => '连接中不能改地址、Token 和目录。断开后可修改。';

  @override
  String get disconnect => '断开连接';

  @override
  String get disconnectedKept => '已断开 · 对话已保留';

  @override
  String disconnectConfirm(String name) {
    return '断开与 $name 的连接？';
  }

  @override
  String get done => '完成';

  @override
  String get close => '关闭';

  @override
  String get backToSettings => '返回设置';

  @override
  String get connectTitle => '连接执行端';

  @override
  String get noAgents => '还没有 Agent。';

  @override
  String get currentAgent => '当前 Agent';

  @override
  String get workingNote => '正在做…';

  @override
  String liveStep(String name) {
    return '正在$name…';
  }

  @override
  String get thinkingNow => '正在思考…';

  @override
  String get replyingNow => '正在回…';

  @override
  String get needsApproval => '等你授权';

  @override
  String needsApprovalWith(String prompt) {
    return '等你授权：$prompt';
  }

  @override
  String get waitingForYou => '等你回一句';

  @override
  String get stoppedNotice => '已停止 · 已保留上面的内容。';

  @override
  String get jumpLatest => '回到最新';

  @override
  String get composerPlaceholder => '继续补充…';

  @override
  String get composerLabel => '给 Aria 发消息';

  @override
  String get stopToast => '已停止';

  @override
  String get turnRunningToast => '这一轮还在跑；先停止，或等它结束。';

  @override
  String get workLog => '执行记录';

  @override
  String get thought => '思考';

  @override
  String get statusDone => '完成';

  @override
  String get statusRunning => '进行中';

  @override
  String get statusFailed => '失败';

  @override
  String get statusPending => '等待';

  @override
  String get statusStopped => '已停止';

  @override
  String get statusSkipped => '已跳过';

  @override
  String toolsUsed(int count) {
    return '用了 $count 个工具';
  }

  @override
  String thoughtsCount(int count) {
    return '$count 段思考';
  }

  @override
  String thoughtsCountSuffix(int count) {
    return '，$count 段思考';
  }

  @override
  String failedCountSuffix(int count) {
    return ' · $count 处失败';
  }

  @override
  String get failedSuffix => ' · 失败';

  @override
  String stepsCount(int count) {
    return '$count 步';
  }

  @override
  String andMoreSteps(int count) {
    return '等 $count 步';
  }

  @override
  String get andMore => '等';

  @override
  String get listSeparator => '、';

  @override
  String get stepError => '错误';

  @override
  String get backToWorkLog => '返回执行记录';

  @override
  String get workLogGone => '这段执行记录不在了';

  @override
  String get stepGone => '这一步不在记录里了';

  @override
  String get thoughtGone => '这段思考不在了';

  @override
  String get modelEffortMode => '模型与执行方式';

  @override
  String get thisTurn => '本轮设置';

  @override
  String get reasoningEffort => '推理强度';

  @override
  String get appliesNextTurn => '下一轮生效。';

  @override
  String get noModels => '此执行端未提供模型选择。';

  @override
  String get noEfforts => '此执行端未提供推理强度。';

  @override
  String get noModes => '此执行端未提供模式。';

  @override
  String modelChipLabel(String model, String effort, String mode) {
    return '模型 $model，推理强度 $effort，模式 $mode';
  }

  @override
  String get approvalKicker => '等待授权';

  @override
  String get command => '命令';

  @override
  String get approvalDetail => '详情';

  @override
  String get riskNote => '这条命令会修改工作区之外的内容，执行后不能撤销。';

  @override
  String get cancelThis => '取消这次';

  @override
  String get optionAllowOnce => '只这次运行';

  @override
  String get optionAllowAlways => '以后同类命令不再问';

  @override
  String get optionRejectOnce => '这次不运行';

  @override
  String get optionRejectAlways => '以后同类命令都拒绝';

  @override
  String get requestClosed => '这个请求已经处理过了';

  @override
  String get connectionLost => '与执行端的连接断了 · 正在重连，恢复后自动补发。';

  @override
  String get connectionOffline => '离线';

  @override
  String get notConnected => '未连接';

  @override
  String get onWatch => '值守中';

  @override
  String get connectToStart => '连接执行端后开始。';

  @override
  String get edit => '编辑';

  @override
  String deleteAgentConfirm(String name) {
    return '删除「$name」？删了就找不回来。';
  }

  @override
  String get relink => '重新连接';

  @override
  String get sessionRefreshing => '正在刷新…';
}

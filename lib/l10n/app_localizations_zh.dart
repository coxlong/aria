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
  String get languageChinese => '简体中文';

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
  String get connectSubtitle => '选择一个执行端连接。';

  @override
  String get connect => '连接';

  @override
  String get connecting => '连接中…';

  @override
  String get connected => '已连接';

  @override
  String get disconnected => '已断开';

  @override
  String get reconnectingShort => '重连中';

  @override
  String get manageExecutors => '管理执行端';

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
  String processRunning(int index) {
    return '执行中 · 第 $index 步';
  }

  @override
  String processDone(int count) {
    return '已完成 · $count 步';
  }
}

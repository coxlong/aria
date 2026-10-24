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
  String get connectTitle => '连接一个 agent';

  @override
  String get connectSubtitle => '和 AI 的二重奏，从一次顺畅的连接开始。';

  @override
  String get connect => '连接';

  @override
  String get addServer => '添加连接';

  @override
  String get editServer => '编辑连接';

  @override
  String get deleteServer => '删除连接';

  @override
  String deleteServerConfirm(String name) {
    return '确定删除「$name」吗？此操作不可撤销。';
  }

  @override
  String get serverName => '名称';

  @override
  String get serverUrl => 'Agent 地址';

  @override
  String get serverToken => '访问令牌（可选）';

  @override
  String get serverCwd => '工作目录';

  @override
  String get serverCwdHint => '/agent 主机上的绝对路径';

  @override
  String get save => '保存';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get noServersTitle => '还没有 agent';

  @override
  String get noServersBody => '添加一个 ACP 服务端来开始会话。';

  @override
  String get newChat => '新对话';

  @override
  String get recentSessions => '最近';

  @override
  String get noSessions => '还没有会话';

  @override
  String get currentConnection => '当前连接';

  @override
  String get switchServer => '切换连接';

  @override
  String get composerHint => '给 agent 发消息…';

  @override
  String get send => '发送';

  @override
  String get stop => '停止';

  @override
  String processRunning(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '第 $count 步',
      one: '第 1 步',
      zero: '准备中',
    );
    return '执行中 · $_temp0';
  }

  @override
  String processCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 步',
      one: '1 步',
    );
    return '已完成 · $_temp0';
  }

  @override
  String get thinking => '思考过程';

  @override
  String get stepDetails => '步骤详情';

  @override
  String get permissionTitle => '审批工具调用';

  @override
  String get permissionHint => 'agent 正在等待你的决定。';

  @override
  String get allowOnce => '允许一次';

  @override
  String get allowAlways => '始终允许';

  @override
  String get rejectOnce => '拒绝';

  @override
  String get rejectAlways => '始终拒绝';

  @override
  String get permissionCancel => '取消';

  @override
  String get model => '模型';

  @override
  String get mode => '模式';

  @override
  String get effort => '推理强度';

  @override
  String get errorNetwork => '无法连接到 agent，请检查地址、网络和 bridge。';

  @override
  String get errorAuth => 'agent 拒绝了令牌，请检查访问令牌。';

  @override
  String get errorProtocol => '该连接不是 ACP v1 协议。';

  @override
  String get errorTimeout => 'agent 响应超时。';

  @override
  String get errorSessionLost => '该会话在 agent 上已不可用。';

  @override
  String errorAgent(int code) {
    return 'agent 返回了错误（$code）。';
  }

  @override
  String get errorGeneric => '出了点问题。';

  @override
  String get reconnecting => '正在重连…';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageChinese => '简体中文';

  @override
  String get emptyChatBody => '发一条消息，开始你们的二重奏。';

  @override
  String get sessionUntitled => '未命名会话';

  @override
  String get retry => '重试';

  @override
  String get close => '关闭';

  @override
  String get settings => '设置';

  @override
  String get requiredField => '必填';

  @override
  String get serverUrlInvalid => '请输入 ws:// 或 wss:// 地址。';

  @override
  String get refresh => '刷新';

  @override
  String get status => '状态';

  @override
  String get toolInput => '输入';

  @override
  String get toolOutput => '输出';

  @override
  String get deleteSession => '删除对话';
}

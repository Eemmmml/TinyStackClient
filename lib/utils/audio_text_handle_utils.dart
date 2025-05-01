import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:asr_plugin/flashfile_plugin.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tinystack/entity/chat_message_item.dart';
import 'package:tts_plugin/tts_plugin.dart';

import 'cloud_upload_utils.dart';

// 音频配置数据模型
class FlashFileASRParamsConfigModel<T> {
  T val;
  String label;

  FlashFileASRParamsConfigModel(this.val, this.label);
}

class AudioTextHandleUtils {
  // 快速音频文件识别配置参数
  FlashFileASRParams params = FlashFileASRParams();

  // 快速音频文件识别控制器
  FlashFileASRController controller = FlashFileASRController();

  final int _appId = 1356865752;

  final _secretId = 'AKIDIVZQ2PXR5UhmhRyINGvOdcPyINDoAIAQ';

  final _secretKey = '70f5HI6lOo0xFOJzRjrnUzHNK7jDj9OQ';

  // // 音频处理模型类型
  // final _engine_type = [
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_8K_ZH, "中文电话通用"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_8K_EN, "英文电话通用"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ZH, "中文通用"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ZH_PY, "中英粤"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ZH_MEDICAL, "中文医疗"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_EN, "英语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_YUE, "粤语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_JA, "日语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_KO, "韩语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_VI, "越南语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_MS, "马来语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ID, "印度尼西亚语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_FIL, "菲律宾语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_TH, "泰语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_PT, "葡萄牙语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_TR, "土耳其语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_AR, "阿拉伯语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ES, "西班牙语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_HI, "印地语"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.ENGINE_16K_ZH_DIALECT, "多方言"),
  // ];
  //
  // // 音频文件格式类型
  // final _voice_format = [
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_WAV, "wav"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_PCM, "pcm"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_OGG_OPUS, "ogg-opus"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_SPEEX, "speex"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_SILK, "silk"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_MP3, "mp3"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_M4A, "m4a"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_AAC, "aac"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FORMAT_AMR, "amr"),
  // ];
  //
  //
  // // 热词增强功能选项
  // final _reinforce_hotword = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.REINFORCE_HOTWORD_MODE_0, "关闭热词增强功能"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.REINFORCE_HOTWORD_MODE_1, "开启热词增强功能")
  // ];
  //
  // // 脏词过滤策略
  // final _filter_dirty = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_DIRTY_MODE_0, "不过滤脏词"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_DIRTY_MODE_1, "过滤脏词"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_DIRTY_MODE_2, "将脏词替换为 * ")
  // ];
  //
  // // 语气词过滤策略
  // final _filter_modal = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_MODAL_MODE_0, "不过滤语气词"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_MODAL_MODE_1, "部分过滤"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_MODAL_MODE_2, "严格过滤")
  // ];
  //
  // // 标点符号过滤策略
  // final _filter_punc = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_PUNC_MODE_0, "不过滤标点符号"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_PUNC_MODE_1, "过滤句末标点"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FILTER_PUNC_MODE_2, "过滤所有标点")
  // ];
  //
  // // 文字转换模式
  // final _convert_num_mode = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.CONVERT_NUM_NODE_0, "不转换，直接输出中文数字"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.CONVERT_NUM_NODE_1, "根据场景智能转换为阿拉伯数字")
  // ];
  //
  // // 文本信息
  // final _word_info = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.WORD_INFO_MODE_0, "不显示"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.WORD_INFO_MODE_1, "显示，不包含标点时间戳"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.WORD_INFO_MODE_2, "显示，包含标点时间戳"),
  // ];
  //
  // // 识别声道显示
  // final _first_channel_only = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FIRST_CHANNEL_ONLY_MODE_0, "识别所有声道"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.FIRST_CHANNEL_ONLY_MODE_1, "识别首个声道"),
  // ];
  //
  // // 是否开启说话人分离
  // final _speaker_diarization = [
  //   FlashFileASRParamsConfigModel(-1, "-"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.SPEAKER_DIARIZATION_MODE_0, "不开启"),
  //   FlashFileASRParamsConfigModel(FlashFileASRParams.SPEAKER_DIARIZATION_MODE_1, "开启"),
  // ];

  Future<String> recognizeAudio(String audioLocalPath) async {
    var result = '';

    params.appid = _appId;
    params.secretid = _secretId;
    params.secretkey = _secretKey;
    // 语音引擎使用中英粤
    params.engine_type = FlashFileASRParams.ENGINE_16K_ZH_PY;
    // 音频文件格式为 aac
    params.voice_format = FlashFileASRParams.FORMAT_AAC;
    // 不开启说话人分离
    params.speaker_diarization = FlashFileASRParams.SPEAKER_DIARIZATION_MODE_0;
    // 开启热词增强
    params.reinforce_hotword = FlashFileASRParams.REINFORCE_HOTWORD_MODE_1;
    // 将脏词替换为 *
    params.filter_dirty = FlashFileASRParams.FILTER_DIRTY_MODE_2;
    // 语气词部分过滤
    params.filter_modal = FlashFileASRParams.FILTER_MODAL_MODE_1;
    // 部分过滤标点符号
    params.filter_punc = FlashFileASRParams.FILTER_PUNC_MODE_1;
    // 根据场景自动转换阿拉伯数字
    params.convert_num_mode = FlashFileASRParams.CONVERT_NUM_NODE_1;
    // 关闭词级时间戳
    params.word_info = FlashFileASRParams.WORD_INFO_MODE_0;
    // 识别首个声道
    params.first_channel_only = FlashFileASRParams.FIRST_CHANNEL_ONLY_MODE_1;

    // 获取本地音频文件数据
    try {
      File file = File(audioLocalPath);
      Uint8List bytes = await file.readAsBytes();
      params.data = bytes;
      final ret = await controller.recognize(params);
      final json = ret.response_body;
      final textList = parseTextFromJson(json);
      if (textList.isNotEmpty) {
        result = textList[0];
      } else {
        result = '';
      }
    } catch (e) {
      debugPrint('读取文件失败：$e');
      result = e.toString();
    }
    return result;
  }

  List<String> parseTextFromJson(String json) {
    final List<String> results = [];

    try {
      // 解析 JSON
      final Map<String, dynamic> jsonData = jsonDecode(json);

      // 处理 flash_result 数组
      final flashResults = jsonData['flash_result'] as List? ?? [];

      for (final result in flashResults) {
        // 提取第一层 text
        if (result['text'] != null) {
          results.add(result['text'] as String);
        }
      }
    } catch (e) {
      debugPrint(
          '${DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now())}: JSON 解析错误: $e');
    }

    return results;
  }

  // 语音合成控制器配置器
  final _ttsConfig = TTSControllerConfig();

  // 文本阅读器
  var _textReader = AudioPlayer();

  final String _bucketName = 'tinystack-tts-store-1356865752';

  final String _region = 'ap-beijing';

  // 流订阅
  StreamSubscription<TTSData>? _sub;

  Future<String> readText(ChatMessageItem message) async {
    String ttsAudioUrl = '';

    _ttsConfig.secretKey = _secretKey;
    _ttsConfig.secretId = _secretId;
    // 音频语速
    _ttsConfig.voiceSpeed = -1;
    // 音频音量
    _ttsConfig.voiceVolume = 0;
    // 音频音色
    _ttsConfig.voiceType = 601000;
    // 音频语言
    _ttsConfig.voiceLanguage = 1;
    // 音频编码
    _ttsConfig.codec = 'mp3';
    // 连接超时
    _ttsConfig.connectTimeout = 15 * 1000;
    // 读取超时
    _ttsConfig.readTimeout = 30 * 1000;

    await _sub?.cancel();
    _sub = null;

    _sub = TTSController.instance.listener.handleError((e) {
      debugPrint('语音合成出错1：$e');
    }).listen((ret) async {
      try {
        final dir = await getTemporaryDirectory();
        var file = await File(
          '${dir.path}/tts_temp_${DateTime.now().millisecondsSinceEpoch}_${_ttsConfig.voiceVolume}.${_ttsConfig.codec}',
        ).writeAsBytes(ret.data);

        // 将语音合成文件上传
        // 获取上传工具
        final ttsCloudUploadUtil = CloudUploadUtils(
            secretId: _secretId,
            secretKey: _secretKey,
            bucketName: _bucketName,
            region: _region);

        final cosPath =
            'tiny_stack_tts_audio_${currentUserId}_${DateTime.now().millisecondsSinceEpoch}';

        ttsAudioUrl = await ttsCloudUploadUtil.uploadLocalFileToCloud(
            file.path, cosPath, message.senderId);

        message.ttsAudioUrl = ttsAudioUrl;

        debugPrint('语音合成成功：$ttsAudioUrl');
      } catch (e) {
        debugPrint('语音合成时出错2：$e');
      }
    });

    TTSController.instance.config = _ttsConfig;
    await TTSController.instance.synthesize(message.content, null);

    // await TTSController.instance.cancel();
    // await TTSController.instance.release();

    return ttsAudioUrl;
  }
}

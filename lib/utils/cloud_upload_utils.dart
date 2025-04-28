import 'package:flutter/material.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos.dart';
import 'package:tencentcloud_cos_sdk_plugin/cos_transfer_manger.dart';
import 'package:tencentcloud_cos_sdk_plugin/enums.dart';
import 'package:tencentcloud_cos_sdk_plugin/pigeon.dart';
import 'package:tencentcloud_cos_sdk_plugin/transfer_task.dart';

class CloudUploadUtils {
  final String secretId;
  final String secretKey;
  final String bucketName;

  // 腾讯云存储通的区域
  final String region;

  // 存储服务配置
  CosXmlServiceConfig? serviceConfig;

  // 传输服务配置
  TransferConfig? transferConfig;

  // 数据传输管理器
  CosTransferManger? transferManager;

  // 数据传输成功的回调方法
  ResultSuccessCallBack? successCallBack;

  // 数据传输失败的回调方法
  ResultFailCallBack? failCallBack;

  // 数据传输状态变化的回调方法
  dynamic Function(TransferState)? stateCallBack;

  // 数据传输进度跟踪回调方法
  dynamic Function(int, int)? progressCallBack;

  // 初始化多上传回调方法
  dynamic Function(String, String, String)? initMultipleUploadCallBack;

  CloudUploadUtils({
    required this.secretId,
    required this.secretKey,
    required this.bucketName,
    required this.region,
    this.serviceConfig,
    this.transferConfig,
    this.transferManager,
    this.successCallBack,
    this.failCallBack,
    this.stateCallBack,
    this.progressCallBack,
    this.initMultipleUploadCallBack,
  });

  // 实现语音云存储上传
  Future<String> uploadLocalFileToCloud(
      String localPath, String cosPath, String uploaderId) async {
    // 存储身份验证
    await Cos().initWithPlainSecret(secretId, secretKey);
    // =========== 注册 COS 服务 ===========
    // 创建 CosXmlServiceConfig 对象，根据需要修改默认的参数配置
    CosXmlServiceConfig defaultServiceConfig = serviceConfig ??
        CosXmlServiceConfig(
          region: region,
          isDebuggable: true,
          isHttps: true,
        );

    // 注册默认 Cos Service
    await Cos().registerDefaultService(defaultServiceConfig);
    // 创建 TransferConfig 对象，根据需要修改默认的配置参数
    TransferConfig defaultTransferConfig = transferConfig ??
        TransferConfig(
          forceSimpleUpload: false,
          enableVerification: true,
          // 设置大于等于 2M 的文件进行分块上传
          divisionForUpload: 2097152,
          // 设置默认分块大小为 1M
          sliceSizeForUpload: 1048576,
        );

    // 注册默认 COS TransferManager
    await Cos().registerDefaultTransferManger(
        defaultServiceConfig, defaultTransferConfig);

    // =========== 访问 COS 服务 ===========
    // 获取 TransferManager
    CosTransferManger defaultTransferManager =
        transferManager ?? Cos().getDefaultTransferManger();
    // 存储桶名称
    String bucket = bucketName;

    // 若存在初始化分块上传的 UploadId，则赋值对应的 uploadId 值用于续传；否则复制 null
    String? uploadId = cosPath;

    // 上传成功回调
    final ResultSuccessCallBack whenSuccess = successCallBack ??
        (Map<String?, String?>? hander, CosXmlResult? result) {
          // TODO: 上传成功后的默认逻辑
        };

    // 上传失败回调
    final whenFail = failCallBack ??
        (clientException, serviceException) {
          // TODO: 上传失败后的默认逻辑
          if (clientException != null) {
            debugPrint('客户端语音消息上传失败 ${clientException.toString()}');
          }
          if (serviceException != null) {
            debugPrint('服务端语音消息上传失败 ${clientException.toString()}');
          }
        };

    // 上传状态回调，可以查看任务过程
    final whenStateChanged = stateCallBack ??
        (state) {
          // TODO: 通知传输状态
        };

    // 上传进度回调
    final whenProgressChanged = progressCallBack ??
        (complete, target) {
          // TODO: 上传进度逻辑
        };

    // 初始化分块完成回调
    final whenInitMultipleUpload = initMultipleUploadCallBack ??
        (String bucket, String cosKey, String uploadId) {
          // 用户下次续传上传的 uploadId
          uploadId = uploadId;
        };

    // 开始上传
    TransferTask transferTask = await defaultTransferManager.upload(
      bucket,
      cosPath,
      filePath: localPath,
      uploadId: uploadId,
      resultListener: ResultListener(whenSuccess, whenFail),
      progressCallBack: whenProgressChanged,
      initMultipleUploadCallback: whenInitMultipleUpload,
      stateCallback: whenStateChanged,
    );
    return 'https://$bucket.cos.$region.myqcloud.com/$cosPath';
  }
}

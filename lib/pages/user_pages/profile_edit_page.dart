import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:tinystack/configs/dio_config.dart';
import 'package:tinystack/configs/tencent_cos_config.dart';
import 'package:tinystack/pojo/user_profile_update_pojo.dart';
import 'package:tinystack/pojo/user_profile_update_response_pojo.dart';
import 'package:tinystack/provider/auth_state_provider.dart';
import 'package:tinystack/utils/cloud_upload_utils.dart';

import '../../entity/user_basic_info.dart';

class ProfileEditPage extends StatefulWidget {
  final UserBasicInfo userInfo;

  ProfileEditPage({super.key, required this.userInfo});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  // 用户名输入控制器
  final TextEditingController _usernameController = TextEditingController();

  // 个人简介输入控制器
  final TextEditingController _bioController = TextEditingController();

  // 默认的头像
  static const String defaultAvatarUrl = 'assets/user_info/user_avatar2.jpg';

  String _avatarUrl = '';

  // UserBasicInfo myUserBasicInfo = UserBasicInfo.myUserBasicInfo;

  // 是否修改了头像
  bool _isAvatarChanged = false;

  // 作为新头像的本地图片文件
  File? _selectedAvatarFile;

  // 头像图片文件存储桶
  final String _avatarBucketName = TencentCosConfig.imageBucket;

  // 存储桶的位置信息
  final String _region = TencentCosConfig.region;

  // 访问密钥 ID
  final String _secretId = TencentCosConfig.secretId;

  // 访问密钥
  final String _secretKey = TencentCosConfig.secretKey;

  // 日志工具
  final logger = Logger();

  // 网络请求工具
  final dio = Dio();

  @override
  void initState() {
    super.initState();
    // TODO: 初始化当前用户数据
    // 当前的用户名
    _usernameController.text = widget.userInfo.username;
    // 当前的个人简介
    _bioController.text = widget.userInfo.description;
    // 当前的用户头像
    _avatarUrl = widget.userInfo.avatarImageUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('编辑资料'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              // TODO: 实现修改后的数据的同步逻辑
              _submit();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildUsernameSection(),
            const SizedBox(height: 16),
            _buildBioSection(),
          ],
        ),
      ),
    );
  }

  // 构建头像部分
  Widget _buildAvatarSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // 用户头像
          _selectedAvatarFile != null
              ? CircleAvatar(
                  radius: 64,
                  backgroundImage: FileImage(_selectedAvatarFile!),
                )
              : CachedNetworkImage(
                  imageUrl: widget.userInfo.avatarImageUrl,
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 64,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => Container(
                    width: 80,
                    height: 80,
                    padding: const EdgeInsets.all(20),
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.error, size: 40),
                  ),
                ),
          // CircleAvatar(
          //   radius: 64,
          //   backgroundImage: myUserBasicInfo.avatarImageUrl.isNotEmpty
          //       ? NetworkImage(myUserBasicInfo.avatarImageUrl)
          //       : const AssetImage(defaultAvatarUrl) as ImageProvider,
          //   child: myUserBasicInfo.avatarImageUrl.isEmpty
          //       ? const Icon(Icons.person, size: 64)
          //       : null,
          // ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.edit, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // 构建用户名部分
  Widget _buildUsernameSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Expanded(
              flex: 2,
              child: Text('昵称'),
            ),
            Expanded(
              flex: 5,
              child: TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: '请输入修改后的昵称',
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                maxLength: 20,
                buildCounter: (context,
                        {required currentLength,
                        required isFocused,
                        maxLength}) =>
                    null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建个人简介部分
  Widget _buildBioSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('个人简介'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _bioController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: '介绍一下自己吧...',
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 4,
              maxLength: 200,
              buildCounter: (context,
                      {required currentLength,
                      required isFocused,
                      maxLength}) =>
                  null,
            ),
          ],
        ),
      ),
    );
  }

  // 从设备中选择图片并发送图片消息的方法
  void _pickImage() async {
    // 请求访问存储权限
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      debugPrint('返回3');
      _showToast('图片访问权限被拒绝');
      return;
    }
    final XFile? image = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70);

    if (image == null) {
      debugPrint('用户未选择图片');
      return;
    }

    setState(() {
      _isAvatarChanged = true;
      _selectedAvatarFile = File(image.path);
    });
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // 将照片同步到云端
  Future<String> _uploadImageToCloud(String uploaderId) async {
    logger.d('开始同步用户新的头像');
    // 获取图片云同步工具
    CloudUploadUtils cloudUploadUtils = CloudUploadUtils(
        secretId: _secretId,
        secretKey: _secretKey,
        bucketName: _avatarBucketName,
        region: _region);


    final String cosPath = 'tiny_stack_user_avatar_${uploaderId}_${DateTime.now().millisecondsSinceEpoch}';

    if (_selectedAvatarFile != null) {
      String newAvatarUrl = await cloudUploadUtils.uploadLocalFileToCloud(_selectedAvatarFile!.path, cosPath, uploaderId);
      logger.d('用户新头像 Url: $newAvatarUrl');
      return newAvatarUrl;
    } else {
      logger.d('用户未选择头像');
      return '';
    }
  }

  // 发送请求向云端同步数据
  Future<bool> _submitChangedProfileInfo() async {
    // 获取用户 ID
    final authProvider = Provider.of<AuthStateProvider>(context, listen: false);
    final uploaderId = authProvider.isLoggedInID;

    final url = '${DioConfig.severUrl}/user/info/profile/update';
    logger.d('发送数据同步请求 ServerUrl: $url');
    final username = _usernameController.text;
    final description = _bioController.text;

    // 将照片同步到云端
    String avatarUrl = await _uploadImageToCloud(uploaderId.toString());

    UserProfileUpdatePojo bodyParams;

    if (avatarUrl.isEmpty) {
      bodyParams = UserProfileUpdatePojo(
        userID: uploaderId,
        username: username.isNotEmpty ? username : null,
        description: description.isNotEmpty ? description : null,
      );
    } else {
      bodyParams = UserProfileUpdatePojo(
        userID: uploaderId,
        username: username.isNotEmpty ? username : null,
        description: description.isNotEmpty ? description : null,
        avatarImageUrl: avatarUrl,
      );
    }
    final response = await dio.put(url, data: bodyParams.toJson());

    if (response.statusCode == 200) {
      logger.d('用户信息更新同步请求成功');
      // 开始解析数据
      logger.d('解析请求数据: ${response.data.toString()}');
      final result = UserProfileUpdateResponsePojo.fromJson(response.data);
      if (result.code == 1) {
        logger.d('用户信息同步成功');
        return true;
      } else {
        logger.e('用户信息更新同步请求失败: Message: ${result.msg}');
        _showErrorSnackBar('用户信息更新同步请求失败: ${result.msg}');
        return false;
      }
    } else {
      logger.e('用户信息更新同步请求失败: Status Code: ${response.statusCode}');
      _showErrorSnackBar('用户信息更新同步请求失败');
      return false;
    }
  }

  Future<void> _submit() async {
    if (await _submitChangedProfileInfo() && mounted) {
      Navigator.pop(context, true);
    }
  }

  // 显示错误提示
  void _showErrorSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '关闭',
          textColor: Colors.white,
          onPressed: () {
            // TODO: 实现点击逻辑
          },
        ),
      ),
    );
  }
}

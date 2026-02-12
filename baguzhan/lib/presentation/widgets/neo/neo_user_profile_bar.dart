/// Neo-Brutal 风格用户信息头部栏组件
///
/// 黑色背景，包含头像、用户名、状态指示器和等级徽章
library;

import 'package:flutter/material.dart';

import '../../../core/theme/neo_brutal_theme.dart';

/// 用户信息头部栏
class NeoUserProfileBar extends StatelessWidget {
  const NeoUserProfileBar({
    super.key,
    this.username = 'Dev_Slasher',
    this.status = 'Learning JavaScript',
    this.level = 12,
    this.avatarUrl,
    this.onTap,
  });

  final String username;
  final String status;
  final int level;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: NeoBrutalTheme.charcoal,
          border: Border.all(
            color: NeoBrutalTheme.charcoal,
            width: NeoBrutalTheme.borderWidth,
          ),
          borderRadius: BorderRadius.circular(9999), // 完整圆形
          boxShadow: NeoBrutalTheme.shadowMd,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        child: Row(
          children: [
            // 头像
            _buildAvatar(),
            const SizedBox(width: 12),

            // 用户名 + 状态
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: NeoBrutalTheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          status,
                          style: const TextStyle(
                            color: NeoBrutalTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 等级徽章
            _buildLevelBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: NeoBrutalTheme.primary,
          width: 2,
        ),
        shape: BoxShape.circle,
      ),
      child: avatarUrl != null
          ? ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      decoration: BoxDecoration(
        color: NeoBrutalTheme.primary.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          '👤',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }

  Widget _buildLevelBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Text(
        'LVL $level',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

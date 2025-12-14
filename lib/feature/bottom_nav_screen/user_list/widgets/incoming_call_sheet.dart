import 'package:flutter/material.dart';
import 'package:video_calling_system/app_constants/utils/colors.dart';
import 'package:video_calling_system/app_constants/utils/global_textstyle.dart';
import 'package:video_calling_system/feature/bottom_nav_screen/user_list/models/call_session.dart';

class IncomingCallSheet extends StatelessWidget {
  final CallSession session;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const IncomingCallSheet({
    super.key,
    required this.session,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                (session.callerName.isNotEmpty
                        ? session.callerName[0]
                        : '?')
                    .toUpperCase(),
                style: GlobalTextStyle.heading(
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              session.callerName,
              style: GlobalTextStyle.heading(fontSize: 20),
            ),
            const SizedBox(height: 6),
            Text(
              'is calling you...',
              style: GlobalTextStyle.body(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDecline,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

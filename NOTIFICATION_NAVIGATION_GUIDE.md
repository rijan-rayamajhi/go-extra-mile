# Notification Navigation Guide

This guide explains how to send push notifications that will properly navigate users to specific screens when clicked.

## How It Works

The app now supports deep linking through push notifications. When a user taps a notification, the app will:

1. **Foreground/Background**: Navigate directly to the specified screen
2. **Terminated**: Store the navigation data and navigate when the app opens

## Notification Data Format

Send notifications with the following data structure:

### Basic Navigation
```json
{
  "notification": {
    "title": "Your notification title",
    "body": "Your notification message"
  },
  "data": {
    "type": "ride"  // or "profile", "gem_coin", "redeem", "notification", "home"
  }
}
```

### Screen-Specific Navigation
```json
{
  "notification": {
    "title": "Your notification title", 
    "body": "Your notification message"
  },
  "data": {
    "screen": "ride"  // or "profile", "earn", "redeem", "notifications", "home"
  }
}
```

### Notification with ID
```json
{
  "notification": {
    "title": "New notification",
    "body": "You have a new message"
  },
  "data": {
    "type": "notification",
    "id": "notification_123"
  }
}
```

## Supported Navigation Types

| Type/Screen | Description | Destination |
|-------------|-------------|-------------|
| `ride` | Navigate to ride screen | RideVehicleScreen |
| `profile` | Navigate to profile screen | MyProfileScreen |
| `gem_coin` / `earn` | Navigate to earn gem coin screen | EarnGemCoinScreen |
| `redeem` | Navigate to redeem screen | RedeemScreen |
| `notification` | Navigate to notifications screen | NotificationScreen |
| `home` | Navigate to home (default) | MainScreen with home tab |

## Example Firebase Admin SDK (Node.js)

```javascript
const admin = require('firebase-admin');

// Send notification to navigate to ride screen
const message = {
  token: 'user_fcm_token_here',
  notification: {
    title: 'Start Your Ride!',
    body: 'Tap to begin tracking your ride and earn gem coins'
  },
  data: {
    type: 'ride'
  }
};

// Send notification to navigate to profile
const profileMessage = {
  token: 'user_fcm_token_here',
  notification: {
    title: 'Profile Update',
    body: 'Your profile has been updated successfully'
  },
  data: {
    type: 'profile'
  }
};

// Send notification to navigate to specific notification
const notificationMessage = {
  token: 'user_fcm_token_here',
  notification: {
    title: 'New Message',
    body: 'You have received a new message'
  },
  data: {
    type: 'notification',
    id: 'notification_123'
  }
};

admin.messaging().send(message);
```

## Example cURL Request

```bash
curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "USER_FCM_TOKEN",
    "notification": {
      "title": "Start Your Ride!",
      "body": "Tap to begin tracking your ride"
    },
    "data": {
      "type": "ride"
    }
  }'
```

## Implementation Details

### Navigation Service
- **File**: `lib/core/service/navigation_service.dart`
- **Purpose**: Handles all notification-based navigation
- **Features**: 
  - Authentication check before navigation
  - Support for both `type` and `screen` parameters
  - Pending notification handling for terminated apps

### FCM Service Updates
- **File**: `lib/core/service/fcm_notification_service.dart`
- **Updates**:
  - Integrated with NavigationService
  - Handles foreground, background, and terminated app notifications
  - Proper error handling

### App Integration
- **Main App**: Uses NavigationService.navigatorKey for global navigation
- **Auth Wrapper**: Handles pending notifications when user becomes authenticated
- **Notification Screen**: Accepts initial notification ID parameter

## Testing

1. **Foreground Testing**: Send notification while app is open
2. **Background Testing**: Send notification while app is in background
3. **Terminated Testing**: Send notification while app is closed, then open app

## Error Handling

- If user is not authenticated, navigation is ignored
- If navigation fails, app continues normally
- Invalid notification data defaults to home navigation
- All navigation operations are wrapped in try-catch blocks

## Best Practices

1. **Always include notification title and body** for user experience
2. **Use descriptive notification messages** that explain what will happen when tapped
3. **Test all navigation paths** before deploying
4. **Handle edge cases** like user not being authenticated
5. **Use appropriate notification types** based on the action you want to trigger

// File: lib/providers/websocket_provider.dart
import 'package:flutter/foundation.dart';
import 'package:web_scoket/WEBSOCKET/utils/web_socket_manager.dart';

/// Provider class for WebSocket state management
/// This class uses ChangeNotifier to notify UI about state changes
class WebSocketProvider with ChangeNotifier {
  // WebSocket manager instance
  late final WebSocketManager _webSocketManager;

  // Echo WebSocket server URL for testing
  static const String _echoServerUrl = 'wss://echo.websocket.org/';

  // State variables
  bool _isConnected = false;
  List<String> _messages = [];
  String? _error;

  // Getters for UI to access state
  bool get isConnected => _isConnected;
  List<String> get messages => List.unmodifiable(_messages);
  String? get error => _error;

  WebSocketProvider() {
    _initializeWebSocket();
  }

  /// Initialize WebSocket manager and set up listeners
  void _initializeWebSocket() {
    _webSocketManager = WebSocketManager();

    // Listen to connection status changes
    _webSocketManager.connectionStream.listen((isConnected) {
      _isConnected = isConnected;

      // Clear error when successfully connected
      if (isConnected) {
        _error = null;
      }

      // Notify UI about connection status change
      notifyListeners();
    });

    // Listen to incoming messages
    _webSocketManager.messageStream.listen((message) {
      _messages.add('Received: $message');

      // Keep only last 50 messages to prevent memory issues
      if (_messages.length > 50) {
        _messages.removeAt(0);
      }

      // Notify UI about new message
      notifyListeners();
    });
  }

  /// Create WebSocket connection
  Future<void> createConnection() async {
    try {
      _error = null;
      notifyListeners();

      debugPrint('Provider: Creating WebSocket connection...');
      await _webSocketManager.connect(_echoServerUrl);

      // Add connection success message
      _messages.add('Connected to $_echoServerUrl');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to connect: $e';
      debugPrint('Provider: Connection error: $e');
      notifyListeners();
    }
  }

  /// Stop WebSocket connection
  Future<void> stopConnection() async {
    try {
      debugPrint('Provider: Stopping WebSocket connection...');
      await _webSocketManager.disconnect();

      // Add disconnection message
      _messages.add('Disconnected from server');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to disconnect: $e';
      debugPrint('Provider: Disconnection error: $e');
      notifyListeners();
    }
  }

  /// Send a test message
  void sendTestMessage(String message) {
    if (_isConnected) {
      _webSocketManager.sendMessage(message);
      _messages.add('Sent: $message');
      notifyListeners();
    }
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Dispose resources when provider is destroyed
  @override
  void dispose() {
    _webSocketManager.dispose();
    super.dispose();
  }
}

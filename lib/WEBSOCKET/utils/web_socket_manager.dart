import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// WebSocket Manager Utility Class for Learning
/// This class demonstrates WebSocket implementation patterns in Flutter
class WebSocketManager {
  // Private WebSocket instance
  WebSocket? _socket;
  
  // Stream controller to broadcast received messages to listeners
  final StreamController<String> _messageController = StreamController<String>.broadcast();
  
  // Stream controller to broadcast connection status updates
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  
  // Getters to expose streams (read-only access)
  Stream<String> get messageStream => _messageController.stream;
  Stream<bool> get connectionStream => _connectionController.stream;
  
  // Current connection status
  bool _isConnected = false;
  bool get isConnected => _isConnected;
  
  /// Establishes WebSocket connection
  /// [url] - WebSocket server URL (ws:// or wss://)
  Future<void> connect(String url) async {
    try {
      // Check if already connected
      if (_isConnected) {
        debugPrint('WebSocket: Already connected');
        return;
      }
      
      debugPrint('WebSocket: Attempting to connect to $url');
      
      // Create WebSocket connection
      // WebSocket.connect() returns a Future<WebSocket>
      _socket = await WebSocket.connect(url);
      
      // Update connection status
      _isConnected = true;
      _connectionController.add(true);
      
      debugPrint('WebSocket: Connected successfully');
      
      // Listen to incoming messages
      // The WebSocket listen method provides a stream of data
      _socket!.listen(
        // onData: Called when a message is received
        (data) {
          debugPrint('WebSocket: Received message: $data');
          // Add the received message to our stream controller
          // This allows UI components to listen for new messages
          _messageController.add(data.toString());
        },
        // onError: Called when an error occurs
        onError: (error) {
          debugPrint('WebSocket: Error occurred: $error');
          _handleDisconnection();
        },
        // onDone: Called when the connection is closed
        onDone: () {
          debugPrint('WebSocket: Connection closed');
          _handleDisconnection();
        },
        // cancelOnError: Whether to cancel the subscription on first error
        cancelOnError: false,
      );
      
      // Send a test message to echo server
      sendMessage('Hello from Flutter WebSocket!');
      
    } catch (e) {
      debugPrint('WebSocket: Connection failed: $e');
      _handleDisconnection();
      rethrow;
    }
  }
  
  /// Sends a message through the WebSocket connection
  /// [message] - The message to send (will be converted to string)
  void sendMessage(String message) {
    if (_socket != null && _isConnected) {
      debugPrint('WebSocket: Sending message: $message');
      // The add() method sends data through the WebSocket
      _socket!.add(message);
    } else {
      debugPrint('WebSocket: Cannot send message - not connected');
    }
  }
  
  /// Closes the WebSocket connection
  Future<void> disconnect() async {
    if (_socket != null) {
      debugPrint('WebSocket: Disconnecting...');
      
      // Close the WebSocket connection
      // The close() method gracefully closes the connection
      await _socket!.close();
      _socket = null;
    }
    
    _handleDisconnection();
  }
  
  /// Private method to handle disconnection cleanup
  void _handleDisconnection() {
    _isConnected = false;
    _connectionController.add(false);
    _socket = null;
  }
  
  /// Cleanup method - important for preventing memory leaks
  /// Should be called when the WebSocketManager is no longer needed
  void dispose() {
    debugPrint('WebSocket: Disposing resources...');
    
    // Close WebSocket if still connected
    if (_socket != null) {
      _socket!.close();
    }
    
    // Close stream controllers to prevent memory leaks
    _messageController.close();
    _connectionController.close();
  }
}


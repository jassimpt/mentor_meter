import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_scoket/WEBSOCKET/screens/widgets/quick_message_button.dart';
import '../providers/websocket_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Text editing controller for the message input field
  final TextEditingController _messageController = TextEditingController();

  // Focus node for better UX
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    // Clean up controllers when widget is disposed
    _messageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Send message and clear the text field
  void _sendMessage(WebSocketProvider provider) {
    final message = _messageController.text.trim();
    if (message.isNotEmpty && provider.isConnected) {
      provider.sendTestMessage(message);
      _messageController.clear();
      // Keep focus on text field for continuous messaging
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Learning'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<WebSocketProvider>(
        builder: (context, webSocketProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Connection Status Card
                Card(
                  color: webSocketProvider.isConnected
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          webSocketProvider.isConnected
                              ? Icons.wifi
                              : Icons.wifi_off,
                          color: webSocketProvider.isConnected
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          webSocketProvider.isConnected
                              ? 'Connected to Echo Server'
                              : 'Disconnected',
                          style: TextStyle(
                            color: webSocketProvider.isConnected
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Connection Control Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: webSocketProvider.isConnected
                            ? null
                            : () => webSocketProvider.createConnection(),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Create Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: webSocketProvider.isConnected
                            ? () => webSocketProvider.stopConnection()
                            : null,
                        icon: const Icon(Icons.stop),
                        label: const Text('Stop Connection'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Custom Message Input Section
                if (webSocketProvider.isConnected) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Send Custom Message',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              // Text input field
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  focusNode: _focusNode,
                                  decoration: const InputDecoration(
                                    hintText: 'Type your message here...',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  // Send message when user presses Enter
                                  onSubmitted: (_) =>
                                      _sendMessage(webSocketProvider),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Send button
                              ElevatedButton.icon(
                                onPressed: () =>
                                    _sendMessage(webSocketProvider),
                                icon: const Icon(Icons.send),
                                label: const Text('Send'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Quick message buttons for convenience
                          const Text(
                            'Quick Messages:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              QuickMessageButton(
                                text: 'Hello!',
                                onPressed: () => webSocketProvider
                                    .sendTestMessage('Hello Echo Server!'),
                              ),
                              QuickMessageButton(
                                text: 'Time',
                                onPressed: () =>
                                    webSocketProvider.sendTestMessage(
                                        'Current time: ${DateTime.now()}'),
                              ),
                              QuickMessageButton(
                                text: 'Test',
                                onPressed: () => webSocketProvider
                                    .sendTestMessage('This is a test message'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Error Display
                if (webSocketProvider.error != null) ...[
                  Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              webSocketProvider.error!,
                              style: TextStyle(color: Colors.red.shade700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Messages Header with Clear Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Real-time Messages',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (webSocketProvider.messages.isNotEmpty)
                      TextButton.icon(
                        onPressed: webSocketProvider.clearMessages,
                        icon: const Icon(Icons.clear_all),
                        label: const Text('Clear'),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Real-time Messages List
                Expanded(
                  child: Card(
                    child: Column(
                      children: [
                        // Messages count indicator
                        if (webSocketProvider.messages.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              '${webSocketProvider.messages.length} messages',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // Messages list
                        Expanded(
                          child: webSocketProvider.messages.isEmpty
                              ? const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.chat_bubble_outline,
                                        size: 64,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No messages yet',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Connect and send messages\nto see real-time communication!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(8),
                                  // Reverse to show latest messages at bottom
                                  reverse: false,
                                  itemCount: webSocketProvider.messages.length,
                                  itemBuilder: (context, index) {
                                    final message =
                                        webSocketProvider.messages[index];
                                    final isReceived =
                                        message.startsWith('Received:');
                                    final isSent = message.startsWith('Sent:');
                                    final isSystem = !isReceived && !isSent;

                                    // Extract actual message content
                                    String displayMessage = message;
                                    if (isReceived) {
                                      displayMessage = message
                                          .substring(10); // Remove "Received: "
                                    } else if (isSent) {
                                      displayMessage = message
                                          .substring(6); // Remove "Sent: "
                                    }

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 3,
                                        horizontal: 4,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: isReceived
                                            ? MainAxisAlignment.start
                                            : MainAxisAlignment.end,
                                        children: [
                                          if (!isReceived && !isSystem)
                                            const Spacer(flex: 1),
                                          Flexible(
                                            flex: 4,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: isReceived
                                                    ? Colors.blue.shade100
                                                    : isSent
                                                        ? Colors.green.shade100
                                                        : Colors.grey.shade100,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withOpacity(0.05),
                                                    blurRadius: 2,
                                                    offset: const Offset(0, 1),
                                                  ),
                                                ],
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Message type indicator
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        isReceived
                                                            ? Icons
                                                                .arrow_circle_down
                                                            : isSent
                                                                ? Icons
                                                                    .arrow_circle_up
                                                                : Icons
                                                                    .info_outline,
                                                        size: 14,
                                                        color: isReceived
                                                            ? Colors
                                                                .blue.shade600
                                                            : isSent
                                                                ? Colors.green
                                                                    .shade600
                                                                : Colors.grey
                                                                    .shade600,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        isReceived
                                                            ? 'Received'
                                                            : isSent
                                                                ? 'Sent'
                                                                : 'System',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: isReceived
                                                              ? Colors
                                                                  .blue.shade600
                                                              : isSent
                                                                  ? Colors.green
                                                                      .shade600
                                                                  : Colors.grey
                                                                      .shade600,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  // Message content
                                                  Text(
                                                    displayMessage,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.3,
                                                    ),
                                                  ),
                                                  // Timestamp
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          Colors.grey.shade500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isReceived || isSystem)
                                            const Spacer(flex: 1),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

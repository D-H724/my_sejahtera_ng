import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:my_sejahtera_ng/features/check_in/screens/check_in_screen.dart';
import 'package:my_sejahtera_ng/features/hotspots/screens/hotspot_screen.dart';
import 'package:my_sejahtera_ng/features/vaccine/screens/vaccine_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final bool isError;
  final Widget? actionWidget; // Widget to display for actions (e.g. Buttons)
  final String? imagePath; // Path to image asset

  ChatMessage({
    required this.text,
    required this.isUser,
    this.isError = false,
    this.actionWidget,
    this.imagePath,
  });
}

// State Notifier
class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() {
    return [
      ChatMessage(
        text: 'Hello! I am your virtual assistant , powered by Llama 3 on Groq. I can help you check in, find vaccines, or answer health questions.',
        isUser: false,
      ),
    ];
  }

  void addMessage(ChatMessage message) {
    state = [...state, message];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

class AIChatScreen extends ConsumerStatefulWidget {
  const AIChatScreen({super.key});

  @override
  ConsumerState<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends ConsumerState<AIChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // Voice
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  bool _isMuted = false; // Voice enabled by default

  bool _isLoading = false;
  final bool _isInitializing = false;
  bool _useSimulatedAI = false;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  void _initTts() async {
    _flutterTts = FlutterTts();

    try {
      // Diagnostic: Check available languages
      dynamic langs = await _flutterTts.getLanguages;
      debugPrint("TTS Available Languages: $langs");

      // Minimal Setup for macOS/General
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0); 
      await _flutterTts.setSpeechRate(1.0); // MAX SPEED
      
      try {
        List<dynamic> voices = await _flutterTts.getVoices;
        Map<String, String>? bestVoice;
        final priorityNames = ["Samantha", "Ava", "Siri", "Daniel", "Karen"];
        for (var name in priorityNames) {
          try {
             var found = voices.firstWhere((v) => v["name"].toString().contains(name), orElse: () => null);
             if (found != null) {
               bestVoice = {"name": found["name"], "locale": found["locale"]};
               break;
             }
          } catch(e) {/* ignore */}
        }
        if (bestVoice != null) {
          await _flutterTts.setVoice(bestVoice);
        }
      } catch (e) {
        debugPrint("TTS Voice Selection Error: $e");
      }

      _flutterTts.setStartHandler(() => setState(() => _isSpeaking = true));
      _flutterTts.setCompletionHandler(() => setState(() => _isSpeaking = false));
      _flutterTts.setCancelHandler(() => setState(() => _isSpeaking = false));
      _flutterTts.setErrorHandler((msg) {
         setState(() => _isSpeaking = false);
      });
      
      // Speak Welcome Message Automatically
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && !_isMuted) {
          _speak("Hello! I am My S J AI. How can I help you?");
        }
      });

    } catch (e) {
      debugPrint("TTS Init Error: $e");
    }
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty || _isMuted) return;
    debugPrint("TTS Speaking: $text");
    try {
      // Direct speak (removing stop() to prevent race conditions)
      final result = await _flutterTts.speak(text);
      if (result == 1) setState(() => _isSpeaking = true);
    } catch (e) {
      debugPrint("TTS Speak Error: $e");
    }
  }
  
  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _sendMessage([String? manualText]) async {
    final text = manualText ?? _controller.text;
    if (text.trim().isEmpty) return;

    HapticFeedback.lightImpact(); // Haptic for send
    ref.read(chatProvider.notifier).addMessage(ChatMessage(text: text, isUser: true));
    if (manualText == null) _controller.clear();
    _scrollToBottom();

    if (_useSimulatedAI) {
      _handleSimulatedResponse(text);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final responseText = await _fetchGroqResponse(text);
      if (!mounted) return;
      
      Widget? action;
      String? imagePath;
      
      // 1. Prioritize User Input for specific intent
      final userLower = text.toLowerCase();
      // Randomizer for variety
      final random = DateTime.now().millisecondsSinceEpoch % 2 == 0; 

      if (userLower.contains("diet") || userLower.contains("food") || userLower.contains("eat") || userLower.contains("nutrition")) {
         imagePath = "assets/images/ai/healthy_diet.png";
      } else if (userLower.contains("water") || userLower.contains("drink") || userLower.contains("hydrate") || userLower.contains("thirst")) {
         imagePath = "assets/images/ai/hydration_water.png";
      } else if (userLower.contains("sleep") || userLower.contains("insomnia") || userLower.contains("rest") || userLower.contains("tired") || userLower.contains("bed")) {
         imagePath = "assets/images/ai/sleep_rest.png";
      } else if (userLower.contains("exercise") || userLower.contains("run") || userLower.contains("gym") || userLower.contains("fitness") || userLower.contains("workout")) {
         imagePath = "assets/images/ai/exercise.png";
      } else if (userLower.contains("yoga") || userLower.contains("meditation") || userLower.contains("zen")) {
         imagePath = "assets/images/ai/yoga_meditation.png";
      } else if (userLower.contains("mental") || userLower.contains("stress") || userLower.contains("sad") || userLower.contains("relax") || userLower.contains("anxiety")) {
         // 50% chance to show Yoga image for general mental health queries for variety
         imagePath = random ? "assets/images/ai/mental_wellness.png" : "assets/images/ai/yoga_meditation.png";
      } else if (userLower.contains("vaccine") || userLower.contains("dose") || userLower.contains("booster") || userLower.contains("immunization")) {
         imagePath = "assets/images/ai/vaccination.png";
      } else if (userLower.contains("virus") || userLower.contains("cov") || userLower.contains("flu") || userLower.contains("protect") || userLower.contains("mask")) {
         imagePath = "assets/images/ai/virus_protection.png";
      } else if (userLower.contains("doctor") || userLower.contains("sick") || userLower.contains("pain") || userLower.contains("hospital") || userLower.contains("clinic")) {
         imagePath = "assets/images/ai/doctor_consult.png";
      }

      // 2. Action Detection & Fallback Logic
      if (imagePath == null) {
        final combinedContext = "${text.toLowerCase()} ${responseText.toLowerCase()}";

        if (combinedContext.contains("check in") || combinedContext.contains("scan")) {
          action = _buildActionChip("Open Scanner", Colors.blueAccent, const CheckInScreen());
          imagePath = "assets/images/ai/general_health.png";
        } else if (combinedContext.contains("vaccine") || combinedContext.contains("certificate")) {
          action = _buildActionChip("View Vaccine", Colors.amber, const VaccineScreen());
          imagePath ??= "assets/images/ai/vaccination.png";
        } else if (combinedContext.contains("hotspot") || combinedContext.contains("map") || combinedContext.contains("risk")) {
          action = _buildActionChip("Check Hotspots", Colors.redAccent, const HotspotScreen());
        } else if (combinedContext.contains("health") || combinedContext.contains("medical")) {
            imagePath = "assets/images/ai/general_health.png";
        }
      }

      HapticFeedback.mediumImpact(); // Haptic for receive
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
        text: responseText, 
        isUser: false, 
        actionWidget: action,
        imagePath: imagePath
      ));
      await _speak(responseText);
    } catch (e) {
      if (!mounted) return;
      HapticFeedback.heavyImpact(); // Haptic for error
      
      // If network calls fail, show error.
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
        text: "Error connecting to AI: ${e.toString()}",
        isUser: false,
        isError: true,
      ));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  Future<String> _fetchGroqResponse(String userMessage) async {
    // Get conversation history to send context
    final currentMessages = ref.read(chatProvider);
    
    // Groq uses OpenAI-compatible format
    // OpenAI API expects: {"role": "user"|"assistant"|"system", "content": "text"}
    final List<Map<String, String>> apiMessages = [
      {"role": "system", "content": "You are MySejahtera NG's helpful health assistant. You are concise, friendly, and knowledgeable about COVID-19 and public health. Please keep your responses short and to the point. Use markdown bullet points for lists to make them easy to read. Avoid using decorative asterisks or excessive bold text unless necessary for emphasis."}
    ];

    // Add last few messages for context (limit to last 10 to save tokens)
    for (var msg in currentMessages.skip(currentMessages.length > 10 ? currentMessages.length - 10 : 0)) {
        apiMessages.add({
          "role": msg.isUser ? "user" : "assistant",
          "content": msg.text
        });
    }
    // Add the new message
    apiMessages.add({"role": "user", "content": userMessage});

    try {
      final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
      if (apiKey.isEmpty || apiKey.contains("PLACEHOLDER")) {
         if (mounted) setState(() => _useSimulatedAI = true);
         return "Please set your Groq API Key in the .env file to use the AI.";
      }

      final response = await http.post(
        Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "llama-3.3-70b-versatile", 
          "messages": apiMessages,
          "max_tokens": 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].toString().trim();
      } else {
        final errorMsg = response.body;
        debugPrint("Groq Error: $errorMsg");
        throw Exception("Groq Error ($errorMsg)");
      }
    } catch (e) {
       // Switch to offline mode if it was a network error
       if (e.toString().contains("ClientException") || e.toString().contains("SocketException")) {
         if (mounted) setState(() => _useSimulatedAI = true);
         return "Network error. Switching to Offline Mode... (Try asking me again)";
       }
       rethrow;
    }
  }

  void _handleSimulatedResponse(String text) {
    setState(() => _isLoading = true);
    
    // Smart Command Parser (Simulated)
    final lowerText = text.toLowerCase();
    String response = "I'm in Offline Mode. I can help you navigate to Check-In, Vaccine, or Hotspots.";
    Widget? action;
    String? imagePath;

    if (lowerText.contains("check in") || lowerText.contains("scan")) {
      response = "Opening the Check-In scanner for you...";
      action = _buildActionChip("Launch Scanner", Colors.blueAccent, const CheckInScreen());
      imagePath = "assets/images/ai/general_health.png";
    } else if (lowerText.contains("vaccine") || lowerText.contains("certificate")) {
      response = "Here is your vaccination status. Staying vaccinated protects you and your community.";
      action = _buildActionChip("Show Certificate", Colors.amber, const VaccineScreen());
      imagePath = "assets/images/ai/vaccination.png";
    } else if (lowerText.contains("hotspot") || lowerText.contains("map")) {
      response = "Checking nearby risk zones. Please stay safe!";
      action = _buildActionChip("Open Hotspot Map", Colors.redAccent, const HotspotScreen());
    } else if (lowerText.contains("health") || lowerText.contains("vital") || lowerText.contains("digital")) {
      response = "Did you know you can track your vitals in the Digital Health section?";
      imagePath = "assets/images/ai/general_health.png";
    } else if (lowerText.contains("diet") || lowerText.contains("food") || lowerText.contains("eat")) {
      response = "A balanced diet is key to good health! Include plenty of fruits, vegetables, and lean proteins.";
      imagePath = "assets/images/ai/healthy_diet.png";
    } else if (lowerText.contains("exercise") || lowerText.contains("run") || lowerText.contains("gym") || lowerText.contains("fitness")) {
      response = "Regular exercise improves heart health and mood. Try to get at least 30 minutes of activity today!";
      imagePath = "assets/images/ai/exercise.png";
    } else if (lowerText.contains("mental") || lowerText.contains("stress") || lowerText.contains("sad") || lowerText.contains("relax")) {
      response = "Your mental wellness matters. Take a moment to breathe and center yourself.";
      imagePath = "assets/images/ai/mental_wellness.png";
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      HapticFeedback.mediumImpact(); // Haptic for receive
      
      ref.read(chatProvider.notifier).addMessage(ChatMessage(
        text: response, 
        isUser: false, 
        actionWidget: action,
        imagePath: imagePath
      ));
      _speak(response);
      _scrollToBottom();
    });
  }

  Widget _buildActionChip(String label, Color color, Widget destination) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, spreadRadius: 1)
          ]
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(LucideIcons.arrowRight, color: Colors.white, size: 16),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      backgroundColor: Colors.black, // Dark base
      body: Stack(
        children: [
          // 1. Futuristic Animated Background
          const _FuturisticBackground(),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildCustomAppBar(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length) {
                        return _buildTypingIndicator();
                      }
                      final msg = messages[index];
                      // Greeting is usually index 0
                      bool isWelcome = index == 0 && !msg.isUser; 
                      return _buildFuturisticMessage(msg, isWelcome: isWelcome);
                    },
                  ),
                ),
                if (!_isInitializing) ...[
                  _buildFuturisticSuggestions(),
                  _buildFuturisticInput(),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
              child: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "MySJ Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _useSimulatedAI ? Colors.orangeAccent : Colors.greenAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (_useSimulatedAI ? Colors.orangeAccent : Colors.greenAccent).withOpacity(0.6),
                          blurRadius: 8,
                          spreadRadius: 2,
                        )
                      ]
                    ),
                  ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(duration: 1000.ms),
                  const SizedBox(width: 8),
                  Text(
                    _useSimulatedAI ? "Offline Mode" : "Online • Llama 3",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // Audio Settings (Mute Toggle)
          GestureDetector(
            onTap: () async {
              setState(() => _isMuted = !_isMuted);
              if (_isMuted) {
                await _flutterTts.stop(); // Stop immediately
                setState(() => _isSpeaking = false);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _isMuted 
                    ? Colors.white.withOpacity(0.1) 
                    : (_isSpeaking ? Colors.purple.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isMuted 
                    ? LucideIcons.volumeX 
                    : (_isSpeaking ? LucideIcons.volume2 : LucideIcons.volume1),
                color: _isMuted 
                    ? Colors.grey 
                    : (_isSpeaking ? Colors.purpleAccent : Colors.white70),
                size: 20,
              ),
            ).animate(target: _isSpeaking && !_isMuted ? 1 : 0).scale(begin: const Offset(1,1), end: const Offset(1.2,1.2)),
          ),
        ],
      ),
    );
  }

  Widget _buildFuturisticMessage(ChatMessage msg, {bool isWelcome = false}) {
    final isUser = msg.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI Avatar
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C6FF).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: const Icon(LucideIcons.bot, color: Colors.white, size: 18),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            const SizedBox(width: 12),
          ],
          
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isUser 
                        ? const Color(0xFF4A00E0).withOpacity(0.9) // User text bg
                        : Colors.white.withOpacity(0.08), // AI text glass
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(24),
                      topRight: const Radius.circular(24),
                      bottomLeft: isUser ? const Radius.circular(24) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(24),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.transparent : Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                    gradient: isUser 
                        ? const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)]) 
                        : LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
                          ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isWelcome)
                        AnimatedTextKit(
                          animatedTexts: [
                            TypewriterAnimatedText(
                              msg.text,
                              textStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: FontWeight.w400,
                              ),
                              speed: const Duration(milliseconds: 30),
                            ),
                          ],
                          isRepeatingAnimation: false,
                          totalRepeatCount: 1,
                        )
                      else
                        MarkdownBody(
                          data: msg.text,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                            strong: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            em: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic),
                            listBullet: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      
                      // AI Image Attachment
                      if (msg.imagePath != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                                borderRadius: BorderRadius.circular(16),
                                ),
                              child: Image.asset(
                                msg.imagePath!,
                                fit: BoxFit.fitWidth, // Show full width/aspect ratio
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),

                      if (msg.isError)
                        Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text("System Error", style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold))
                        )
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut),

                // Render Action Button if Available
                if (msg.actionWidget != null)
                  msg.actionWidget!
              ],
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 12),
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [Color(0xFFFF3CAC), Color(0xFF784BA0)]),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3CAC).withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              ),
              child: const Icon(LucideIcons.user, color: Colors.white, size: 18),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ]
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 48, bottom: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 12, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00C6FF)),
            ),
            const SizedBox(width: 10),
            Text(
              "Processing...",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ).animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 1500.ms, color: Colors.white),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildFuturisticSuggestions() {
    final chips = [
      "Vaccine Status", 
      "Check-in Scan", 
      "Risky Spots", 
      "Symptoms",
      "Better Sleep",
      "Stay Hydrated",
      "Find Doctor",
      "Yoga Tips",
      "Virus Guard"
    ];
    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _sendMessage(chips[index]),
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                gradient: LinearGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)]
                )
              ),
              child: Text(
                chips[index],
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ).animate().fade(delay: (100 * index).ms).slideX();
        },
      ),
    );
  }

  Widget _buildFuturisticInput() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 15,
            spreadRadius: 5,
            offset: Offset(0, 10),
          )
        ]
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Ask AI Assistant...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFF00C6FF), Color(0xFF0072FF)])
            ),
            child: IconButton(
              icon: const Icon(LucideIcons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(),
            ),
          ).animate(target: _controller.text.isNotEmpty ? 1 : 0).scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
        ],
      ),
    );
  }
}

// Minimal Animated Background Widget
class _FuturisticBackground extends StatelessWidget {
  const _FuturisticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Space Base
        Container(color: const Color(0xFF0F172A)), // Slate 900
        
        // Glowing Orb 1 (Top Left)
        Positioned(
          top: -100, left: -100,
          child: Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4A00E0).withOpacity(0.3),
              backgroundBlendMode: BlendMode.screen,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 4000.ms)
           .blur(begin: const Offset(60, 60), end: const Offset(100, 100)),
        ),

        // Glowing Orb 2 (Bottom Right)
        Positioned(
          bottom: -100, right: -100,
          child: Container(
            width: 300, height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00C6FF).withOpacity(0.2),
              backgroundBlendMode: BlendMode.screen,
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true))
           .moveY(begin: 0, end: -50, duration: 5000.ms)
           .blur(begin: const Offset(80, 80), end: const Offset(40, 40)),
        ),
        
        // Overlay Noise/Texture (Optional, simulating with subtle gradient)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

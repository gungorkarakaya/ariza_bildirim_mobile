import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../models/ariza_bildirim_model.dart';
import '../services/ariza_bildirim_service.dart';
import '../services/token_storage_service.dart';
import '../widgets/ariza/ariza_card.dart';
import '../widgets/ariza/ariza_empty_state.dart';
import '../widgets/ariza/ariza_error_view.dart';
import 'login_screen.dart';
import '../services/local_notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TokenStorageService _tokenStorageService = TokenStorageService();
  final ArizaBildirimService _arizaBildirimService = ArizaBildirimService();

  StreamSubscription<RemoteMessage>? _messageSubscription;

  bool _isLoading = true;
  String? _errorMessage;
  List<ArizaBildirimModel> _aktifArizalar = [];

  Future<void> _loadScreenData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _tokenStorageService.getAccessToken();

      if (!mounted) return;

      if (token == null || token.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
        return;
      }

      final arizalar =
      await _arizaBildirimService.getActiveArizaBildirimleri();

      try {
        final ids = arizalar.map((ariza) => ariza.id).toList();
        await _arizaBildirimService.markSeen(ids);
      } catch (_) {
        // Görüldü bilgisi gönderilemese bile liste gösterilmeye devam eder.
      }

      if (!mounted) return;

      setState(() {
        _aktifArizalar = arizalar;
        _isLoading = false;
      });
    } on UnauthorizedException catch (_) {
      await _tokenStorageService.deleteAccessToken();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            initialMessage: 'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await _tokenStorageService.deleteAccessToken();

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
    );
  }

  Future<void> _showResolveConfirmDialog(ArizaBildirimModel ariza) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Arıza çözüldü mü?'),
          content: Text(
            '${ariza.arizaCesidiAdi.isEmpty ? 'Bu arıza' : ariza.arizaCesidiAdi} çözüldü olarak işaretlenecek.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Çözüldü Yap'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _arizaBildirimService.resolveAriza(ariza.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arıza çözüldü olarak işaretlendi.'),
        ),
      );

      await _loadScreenData();
    } on UnauthorizedException catch (_) {
      await _tokenStorageService.deleteAccessToken();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(
            initialMessage: 'Oturum süresi doldu. Lütfen tekrar giriş yapın.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Arıza çözüldü olarak işaretlenemedi.'),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadScreenData();

    _messageSubscription = FirebaseMessaging.onMessage.listen((message) async {
      await LocalNotificationService.showForegroundNotification(message);

      if (!mounted) return;

      await _loadScreenData();
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadScreenData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadScreenData,
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(),
        )
            : _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Arıza Bildirim Mobil'),
      actions: [
        IconButton(
          onPressed: _loadScreenData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Yenile',
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          tooltip: 'Çıkış Yap',
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null) {
      return ArizaErrorView(
        message: _errorMessage!,
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Aktif Arızalar',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Çözülmemiş arızalar aşağıda listelenir.',
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 16),
        if (_aktifArizalar.isEmpty)
          const ArizaEmptyState()
        else
          ..._aktifArizalar.map(
                (ariza) => ArizaCard(
              ariza: ariza,
              onResolvePressed: () => _showResolveConfirmDialog(ariza),
            ),
          ),
      ],
    );
  }
}
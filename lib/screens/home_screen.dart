import 'package:flutter/material.dart';

import '../models/ariza_bildirim_model.dart';
import '../services/ariza_bildirim_service.dart';
import '../services/token_storage_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TokenStorageService _tokenStorageService = TokenStorageService();
  final ArizaBildirimService _arizaBildirimService = ArizaBildirimService();

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

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '-';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  String _formatKonsolNo(int? konsolNo) {
    if (konsolNo == null) {
      return '-';
    }

    return 'K${konsolNo.toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadScreenData();
  }

  @override
  void dispose() {
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
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
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
          _buildEmptyCard()
        else
          ..._aktifArizalar.map(_buildArizaCard),
      ],
    );
  }

  Widget _buildEmptyCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Şu anda aktif arıza bulunmuyor.'),
      ),
    );
  }

  Widget _buildArizaCard(ArizaBildirimModel ariza) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ariza.arizaCesidiAdi.isEmpty
                  ? 'Arıza Bildirimi'
                  : ariza.arizaCesidiAdi,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow(
              icon: Icons.desktop_windows_outlined,
              label: 'Konsol',
              value: _formatKonsolNo(ariza.konsolNo),
            ),
            _buildInfoRow(
              icon: Icons.apartment_outlined,
              label: 'Departman',
              value: ariza.departmanAdi,
            ),
            _buildInfoRow(
              icon: Icons.info_outline,
              label: 'Durum',
              value: ariza.durumAdi,
            ),
            _buildInfoRow(
              icon: Icons.access_time,
              label: 'Tarih',
              value: _formatDate(ariza.created),
            ),
            if (ariza.aciklama.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                ariza.aciklama,
                style: TextStyle(
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value),
          ),
        ],
      ),
    );
  }
}
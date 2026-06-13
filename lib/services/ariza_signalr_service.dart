import 'package:signalr_netcore/signalr_client.dart';

import '../core/constants/api_constants.dart';

class ArizaSignalRService {
  HubConnection? _connection;

  Future<void> start({
    required void Function(int arizaId) onArizaCozuldu,
    required void Function(int arizaId) onArizaIptal,
  }) async {
    if (_connection?.state == HubConnectionState.Connected) {
      return;
    }

    _connection = HubConnectionBuilder()
        .withUrl(ApiConstants.arizaHubUrl)
        .withAutomaticReconnect()
        .build();

    _connection!.on('ReceiveArizaCozuldu', (arguments) {
      final arizaId = _extractArizaId(arguments);

      if (arizaId != null) {
        onArizaCozuldu(arizaId);
      }
    });

    _connection!.on('ReceiveArizaIptal', (arguments) {
      final arizaId = _extractArizaId(arguments);

      if (arizaId != null) {
        onArizaIptal(arizaId);
      }
    });

    await _connection!.start();
  }

  Future<void> stop() async {
    await _connection?.stop();
    _connection = null;
  }

  int? _extractArizaId(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) {
      return null;
    }

    final first = arguments.first;

    if (first is int) {
      return first;
    }

    return int.tryParse(first.toString());
  }
}
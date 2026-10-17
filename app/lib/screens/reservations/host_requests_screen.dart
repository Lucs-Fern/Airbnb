import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/reservation.dart';
import '../../repositories/reservation_repository.dart';

class HostRequestsScreen extends StatefulWidget {
  const HostRequestsScreen({super.key});

  @override
  State<HostRequestsScreen> createState() =>
      _HostRequestsScreenState();
}

class _HostRequestsScreenState
    extends State<HostRequestsScreen> {
  List<Reservation> get _reservations =>
      ReservationRepository.instance.reservations;

  void _updateStatus(
    Reservation reservation,
    ReservationStatus newStatus,
  ) {
    ReservationRepository.instance.updateReservationStatus(
      reservation.id,
      newStatus,
    );

    setState(() {});

    final message = switch (newStatus) {
      ReservationStatus.accepted =>
        'Solicitud aceptada con éxito.',
      ReservationStatus.rejected =>
        'Solicitud rechazada.',
      ReservationStatus.pending =>
        'Solicitud actualizada.',
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitudes recibidas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 750,
            ),
            child: _reservations.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Solicitudes de hospedaje',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Revisa las solicitudes recibidas '
                        'y decide si deseas aceptarlas o rechazarlas.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      ..._reservations.map(
                        _buildRequestCard,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 70,
            color: AppTheme.textSecondary,
          ),
          SizedBox(height: 18),
          Text(
            'No hay solicitudes',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Las solicitudes de hospedaje aparecerán aquí.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(
    Reservation reservation,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 18,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.home_work_outlined,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  reservation.propertyTitle,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _StatusChip(
                status: reservation.status,
              ),
            ],
          ),

          const SizedBox(height: 18),

          _InfoRow(
            label: 'Entrada',
            value: _formatDate(
              reservation.startDate,
            ),
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Salida',
            value: _formatDate(
              reservation.endDate,
            ),
          ),

          const SizedBox(height: 8),

          _InfoRow(
            label: 'Personas',
            value: '${reservation.guests}',
          ),

          const SizedBox(height: 20),

          if (reservation.status ==
              ReservationStatus.pending)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _updateStatus(
                        reservation,
                        ReservationStatus.rejected,
                      );
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    label: const Text(
                      'Rechazar',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _updateStatus(
                        reservation,
                        ReservationStatus.accepted,
                      );
                    },
                    icon: const Icon(
                      Icons.check_rounded,
                    ),
                    label: const Text(
                      'Aceptar',
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                reservation.status ==
                        ReservationStatus.accepted
                    ? 'Esta solicitud fue aceptada.'
                    : 'Esta solicitud fue rechazada.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReservationStatus status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final text = switch (status) {
      ReservationStatus.pending => 'Pendiente',
      ReservationStatus.accepted => 'Aceptada',
      ReservationStatus.rejected => 'Rechazada',
    };

    final icon = switch (status) {
      ReservationStatus.pending =>
        Icons.schedule_rounded,
      ReservationStatus.accepted =>
        Icons.check_circle_outline_rounded,
      ReservationStatus.rejected =>
        Icons.cancel_outlined,
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
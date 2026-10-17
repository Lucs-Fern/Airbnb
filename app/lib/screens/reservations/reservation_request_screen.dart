import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/property.dart';
import '../../models/reservation.dart';
import '../../repositories/reservation_repository.dart';
import 'my_reservations_screen.dart';

class ReservationRequestScreen extends StatefulWidget {
  final Property property;

  const ReservationRequestScreen({
    super.key,
    required this.property,
  });

  @override
  State<ReservationRequestScreen> createState() =>
      _ReservationRequestScreenState();
}

class _ReservationRequestScreenState
    extends State<ReservationRequestScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  int _guests = 1;

  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;

        if (_endDate != null &&
            !_endDate!.isAfter(selectedDate)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    if (_startDate == null) {
      _showError(
        'Primero debes seleccionar la fecha de entrada.',
      );
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate!.add(
        const Duration(days: 1),
      ),
      firstDate: _startDate!.add(
        const Duration(days: 1),
      ),
      lastDate: DateTime.now().add(
        const Duration(days: 730),
      ),
    );

    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  void _increaseGuests() {
    if (_guests < widget.property.capacity) {
      setState(() {
        _guests++;
      });
    }
  }

  void _decreaseGuests() {
    if (_guests > 1) {
      setState(() {
        _guests--;
      });
    }
  }

  void _submitReservation() {
    if (_startDate == null || _endDate == null) {
      _showError(
        'Debes seleccionar las fechas de entrada y salida.',
      );
      return;
    }

    if (!_endDate!.isAfter(_startDate!)) {
      _showError(
        'La fecha de salida debe ser posterior a la fecha de entrada.',
      );
      return;
    }

    if (_guests > widget.property.capacity) {
      _showError(
        'La cantidad de personas supera la capacidad del alojamiento.',
      );
      return;
    }

    final reservation = Reservation(
  id: DateTime.now().millisecondsSinceEpoch,
  propertyId: widget.property.id,
  propertyTitle: widget.property.title,
  startDate: _startDate!,
  endDate: _endDate!,
  guests: _guests,
);

ReservationRepository.instance.addReservation(
  reservation,
);

    debugPrint(
      'Reserva creada: '
      '${reservation.propertyId}, '
      '${reservation.startDate}, '
      '${reservation.endDate}, '
      '${reservation.guests}',
    );

    showDialog(
  context: context,
  barrierDismissible: false,
  builder: (context) {
    return AlertDialog(
      icon: const Icon(
        Icons.check_circle_outline_rounded,
        color: AppTheme.primary,
        size: 48,
      ),
      title: const Text(
        'Solicitud enviada',
      ),
      content: const Text(
        'Tu solicitud de reserva fue enviada '
        'correctamente y quedó en estado pendiente.',
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Cerrar',
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    const MyReservationsScreen(),
              ),
            );
          },
          child: const Text(
            'Ver mis reservas',
          ),
        ),
      ],
    );
  },
);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Seleccionar fecha';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Solicitud de reserva',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 650,
            ),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildPropertySummary(),

                const SizedBox(height: 28),

                const Text(
                  'Fechas de estadía',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _DateCard(
                        title: 'Entrada',
                        value: _formatDate(_startDate),
                        icon: Icons.login_rounded,
                        onTap: _selectStartDate,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DateCard(
                        title: 'Salida',
                        value: _formatDate(_endDate),
                        icon: Icons.logout_rounded,
                        onTap: _selectEndDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Cantidad de personas',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Este alojamiento permite máximo '
                  '${widget.property.capacity} persona(s).',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppTheme.border,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Personas',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _guests > 1 ? _decreaseGuests : null,
                        icon: const Icon(
                          Icons.remove_circle_outline,
                        ),
                      ),
                      Text(
                        '$_guests',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            _guests < widget.property.capacity
                                ? _increaseGuests
                                : null,
                        icon: const Icon(
                          Icons.add_circle_outline,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                _buildReservationSummary(),

                const SizedBox(height: 30),

                ElevatedButton.icon(
                  onPressed: _submitReservation,
                  icon: const Icon(
                    Icons.send_rounded,
                  ),
                  label: const Text(
                    'Enviar solicitud',
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'La solicitud quedará pendiente hasta que '
                  'el anfitrión la acepte o rechace.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPropertySummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              widget.property.type == 'Habitación'
                  ? Icons.bedroom_parent_rounded
                  : Icons.apartment_rounded,
              color: AppTheme.primary,
              size: 38,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.property.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.property.location,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '\$${widget.property.price.toStringAsFixed(0)} COP / mes',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'Entrada',
            value: _formatDate(_startDate),
          ),
          _SummaryRow(
            label: 'Salida',
            value: _formatDate(_endDate),
          ),
          _SummaryRow(
            label: 'Personas',
            value: '$_guests',
          ),
          _SummaryRow(
            label: 'Estado inicial',
            value: 'Pendiente',
          ),
        ],
      ),
    );
  }
}

class _DateCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _DateCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
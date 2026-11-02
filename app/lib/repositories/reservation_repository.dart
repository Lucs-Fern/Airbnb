
import '../models/reservation.dart';

class ReservationRepository {
  ReservationRepository._();

  static final ReservationRepository instance =
      ReservationRepository._();

  final List<Reservation> _reservations = [];

  List<Reservation> get reservations =>
      List.unmodifiable(_reservations);

  // Guardar una nueva reserva
  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
  }

  // Aceptar o rechazar una solicitud pendiente
  bool updateReservationStatus(
    int reservationId,
    ReservationStatus newStatus,
  ) {
    final index = _reservations.indexWhere(
      (reservation) => reservation.id == reservationId,
    );

    // La reserva no existe
    if (index == -1) {
      return false;
    }

    // Solo se modifican reservas pendientes
    if (_reservations[index].status !=
        ReservationStatus.pending) {
      return false;
    }

    // No permitimos volver a estado pendiente
    if (newStatus == ReservationStatus.pending) {
      return false;
    }

    _reservations[index] = _reservations[index].copyWith(
      status: newStatus,
    );

    return true;
  }

  // Comprobar si existen reservas
  bool get hasReservations => _reservations.isNotEmpty;
}

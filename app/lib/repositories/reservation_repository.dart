import '../models/reservation.dart';

class ReservationRepository {
  ReservationRepository._();

  static final ReservationRepository instance =
      ReservationRepository._();

  final List<Reservation> _reservations = [];

  List<Reservation> get reservations =>
      List.unmodifiable(_reservations);

  void addReservation(Reservation reservation) {
    _reservations.add(reservation);
  }

  void updateReservationStatus(
    int reservationId,
    ReservationStatus newStatus,
  ) {
    final index = _reservations.indexWhere(
      (reservation) => reservation.id == reservationId,
    );

    if (index == -1) {
      return;
    }

    _reservations[index] = _reservations[index].copyWith(
      status: newStatus,
    );
  }

  bool get hasReservations => _reservations.isNotEmpty;
}
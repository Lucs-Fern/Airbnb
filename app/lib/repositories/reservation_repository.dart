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

  bool get hasReservations => _reservations.isNotEmpty;
}
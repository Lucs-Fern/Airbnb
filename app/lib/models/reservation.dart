enum ReservationStatus {
  pending,
  accepted,
  rejected,
}

class Reservation {
  final int id;
  final int propertyId;
  final String propertyTitle;
  final DateTime startDate;
  final DateTime endDate;
  final int guests;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.startDate,
    required this.endDate,
    required this.guests,
    this.status = ReservationStatus.pending,
  });
}
class BookForOtherTitle {
  const BookForOtherTitle({required this.id, required this.label});

  final int id;
  final String label;

  static const mr = BookForOtherTitle(id: 1, label: 'Mr');
  static const mss = BookForOtherTitle(id: 2, label: 'Ms');

  static const List<BookForOtherTitle> values = [mr, mss];
}

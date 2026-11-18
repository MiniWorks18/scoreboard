import 'package:web/web.dart' as web;

void setBrowserModalOpen(bool isOpen) {
  final meta = web.document.querySelector('meta[name="theme-color"]');
  meta?.setAttribute('content', isOpen ? '#979CA6' : '#F2F4F9');
}

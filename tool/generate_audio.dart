// dart run tool/generate_audio.dart
// Generates simple WAV tone files into assets/audio/
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  final dir = Directory('assets/audio');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  _write('hit',        [_note(440, 80,  0.5)]);
  _write('player_hit', [_note(200, 120, 0.5)]);
  _write('ability',    [_note(880, 130, 0.45)]);
  _write('coin',       [_note(1047, 70, 0.55)]);
  _write('victory',    [_note(523, 140, 0.5), _note(659, 140, 0.5), _note(784, 200, 0.55)]);
  _write('defeat',     [_note(330, 250, 0.5), _note(220, 300, 0.4)]);
  _write('levelup',    [_note(523, 120, 0.45), _note(659, 120, 0.45),
                        _note(784, 120, 0.45), _note(1047, 200, 0.6)]);

  print('Generated 7 WAV files in assets/audio/');
}

void _write(String name, List<Uint8List> segments) {
  final data = segments.fold<List<int>>([], (acc, s) => acc..addAll(s));
  final bytes = _wrapWav(Uint8List.fromList(data));
  File('assets/audio/$name.wav').writeAsBytesSync(bytes);
  print('  $name.wav  (${bytes.length} bytes)');
}

Uint8List _note(double freq, int durationMs, double vol) {
  const sampleRate = 22050;
  final numSamples = (sampleRate * durationMs / 1000).round();
  final buf = ByteData(numSamples * 2);
  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    final env = _envelope(i, numSamples);
    final v = (sin(2 * pi * freq * t) * env * vol * 32767).round().clamp(-32768, 32767);
    buf.setInt16(i * 2, v, Endian.little);
  }
  return buf.buffer.asUint8List();
}

double _envelope(int i, int total) {
  final attack  = (total * 0.08).round();
  final release = (total * 0.30).round();
  if (i < attack)  return i / attack;
  if (i >= total - release) return (total - i) / release;
  return 1.0;
}

Uint8List _wrapWav(Uint8List pcm) {
  const sampleRate = 22050;
  const bitsPerSample = 16;
  const channels = 1;
  final byteRate = sampleRate * channels * bitsPerSample ~/ 8;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final dataSize = pcm.length;
  final fileSize = 36 + dataSize;

  final header = ByteData(44);
  // RIFF
  _writeStr(header, 0, 'RIFF');
  header.setUint32(4, fileSize, Endian.little);
  _writeStr(header, 8, 'WAVE');
  // fmt
  _writeStr(header, 12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);        // PCM
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  // data
  _writeStr(header, 36, 'data');
  header.setUint32(40, dataSize, Endian.little);

  return Uint8List.fromList([...header.buffer.asUint8List(), ...pcm]);
}

void _writeStr(ByteData buf, int offset, String s) {
  for (var i = 0; i < s.length; i++) buf.setUint8(offset + i, s.codeUnitAt(i));
}

// Cuts the most intense stretch of a .wav (16-bit PCM) and saves it over the original, with a soft fade in and out.
// Usage: node ferramentas/cortar-som.mjs conteudo/01-sons/sons/aurora.wav 4
import {readFileSync, writeFileSync} from 'node:fs';

const [file, secondsText = '4'] = process.argv.slice(2);
const seconds = Number(secondsText);
const b = readFileSync(file);
let p = 12, fmt = null, dataStart = 0, dataSize = 0;
while (p < b.length) {
  const id = b.toString('ascii', p, p + 4), size = b.readUInt32LE(p + 4);
  if (id === 'fmt ') fmt = {channels: b.readUInt16LE(p + 10), rate: b.readUInt32LE(p + 12), bits: b.readUInt16LE(p + 22)};
  if (id === 'data') { dataStart = p + 8; dataSize = size; }
  p += 8 + size + (size % 2);
}
if (!fmt || fmt.bits !== 16) throw new Error('only works with 16-bit PCM WAV');
const frame = fmt.channels * 2;
const total = Math.floor(dataSize / frame);
const sample = (i, c) => b.readInt16LE(dataStart + i * frame + c * 2);

// Energy in 50 ms blocks; finds the window with the most energy.
const block = Math.round(fmt.rate * 0.05);
const energy = [];
for (let i = 0; i + block <= total; i += block) {
  let s = 0;
  for (let j = i; j < i + block; j += 4) for (let c = 0; c < fmt.channels; c++) s += sample(j, c) ** 2;
  energy.push(s);
}
const n = Math.round(seconds / 0.05);
let best = 0, sum = energy.slice(0, n).reduce((a, x) => a + x, 0), max = sum;
for (let k = 1; k + n <= energy.length; k++) {
  sum += energy[k + n - 1] - energy[k - 1];
  if (sum > max) { max = sum; best = k; }
}
const start = best * block, end = Math.min(total, start + n * block);
const fadeIn = Math.round(fmt.rate * 0.15), fadeOut = Math.round(fmt.rate * 0.6);
const data = Buffer.alloc((end - start) * frame);
for (let i = start; i < end; i++) {
  const k = i - start, vol = Math.min(1, k / fadeIn, (end - i) / fadeOut);
  for (let c = 0; c < fmt.channels; c++) data.writeInt16LE(Math.round(sample(i, c) * vol), k * frame + c * 2);
}
const header = Buffer.alloc(44);
header.write('RIFF', 0); header.writeUInt32LE(36 + data.length, 4); header.write('WAVE', 8);
header.write('fmt ', 12); header.writeUInt32LE(16, 16); header.writeUInt16LE(1, 20); header.writeUInt16LE(fmt.channels, 22);
header.writeUInt32LE(fmt.rate, 24); header.writeUInt32LE(fmt.rate * frame, 28); header.writeUInt16LE(frame, 32); header.writeUInt16LE(16, 34);
header.write('data', 36); header.writeUInt32LE(data.length, 40);
writeFileSync(file, Buffer.concat([header, data]));
console.log(`${file}: stretch from ${(start / fmt.rate).toFixed(1)}s to ${(end / fmt.rate).toFixed(1)}s (of ${(total / fmt.rate).toFixed(1)}s) → ${(data.length / 1024).toFixed(0)} KB`);

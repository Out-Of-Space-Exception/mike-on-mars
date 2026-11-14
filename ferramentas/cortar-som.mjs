// Corta o trecho mais intenso de um .wav (PCM 16 bits) e salva por cima, com entrada e saída suaves.
// Uso: node ferramentas/cortar-som.mjs conteudo/01-sons/sons/aurora.wav 4
import {readFileSync, writeFileSync} from 'node:fs';

const [arquivo, segundosTxt = '4'] = process.argv.slice(2);
const segundos = Number(segundosTxt);
const b = readFileSync(arquivo);
let p = 12, fmt = null, dataIni = 0, dataTam = 0;
while (p < b.length) {
  const id = b.toString('ascii', p, p + 4), tam = b.readUInt32LE(p + 4);
  if (id === 'fmt ') fmt = {canais: b.readUInt16LE(p + 10), taxa: b.readUInt32LE(p + 12), bits: b.readUInt16LE(p + 22)};
  if (id === 'data') { dataIni = p + 8; dataTam = tam; }
  p += 8 + tam + (tam % 2);
}
if (!fmt || fmt.bits !== 16) throw new Error('só funciona com WAV PCM de 16 bits');
const quadro = fmt.canais * 2;
const total = Math.floor(dataTam / quadro);
const amostra = (i, c) => b.readInt16LE(dataIni + i * quadro + c * 2);

// Energia em blocos de 50 ms; acha a janela com mais energia.
const bloco = Math.round(fmt.taxa * 0.05);
const energia = [];
for (let i = 0; i + bloco <= total; i += bloco) {
  let s = 0;
  for (let j = i; j < i + bloco; j += 4) for (let c = 0; c < fmt.canais; c++) s += amostra(j, c) ** 2;
  energia.push(s);
}
const n = Math.round(segundos / 0.05);
let melhor = 0, soma = energia.slice(0, n).reduce((a, x) => a + x, 0), max = soma;
for (let k = 1; k + n <= energia.length; k++) {
  soma += energia[k + n - 1] - energia[k - 1];
  if (soma > max) { max = soma; melhor = k; }
}
const ini = melhor * bloco, fim = Math.min(total, ini + n * bloco);
const entrada = Math.round(fmt.taxa * 0.15), saida = Math.round(fmt.taxa * 0.6);
const dados = Buffer.alloc((fim - ini) * quadro);
for (let i = ini; i < fim; i++) {
  const k = i - ini, vol = Math.min(1, k / entrada, (fim - i) / saida);
  for (let c = 0; c < fmt.canais; c++) dados.writeInt16LE(Math.round(amostra(i, c) * vol), k * quadro + c * 2);
}
const cab = Buffer.alloc(44);
cab.write('RIFF', 0); cab.writeUInt32LE(36 + dados.length, 4); cab.write('WAVE', 8);
cab.write('fmt ', 12); cab.writeUInt32LE(16, 16); cab.writeUInt16LE(1, 20); cab.writeUInt16LE(fmt.canais, 22);
cab.writeUInt32LE(fmt.taxa, 24); cab.writeUInt32LE(fmt.taxa * quadro, 28); cab.writeUInt16LE(quadro, 32); cab.writeUInt16LE(16, 34);
cab.write('data', 36); cab.writeUInt32LE(dados.length, 40);
writeFileSync(arquivo, Buffer.concat([cab, dados]));
console.log(`${arquivo}: trecho de ${(ini / fmt.taxa).toFixed(1)}s a ${(fim / fmt.taxa).toFixed(1)}s (de ${(total / fmt.taxa).toFixed(1)}s) → ${(dados.length / 1024).toFixed(0)} KB`);

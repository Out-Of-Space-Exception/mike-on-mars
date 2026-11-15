"""Apply the reviewed four-language copy without changing keys or placeholders."""
from pathlib import Path
import csv
import re

folder = Path(__file__).resolve().parent
source = folder / 'textos.csv'
with source.open(encoding='utf-8-sig', newline='') as handle:
    reader = csv.DictReader(handle)
    fields = reader.fieldnames
    rows = list(reader)
assert fields == ['keys', 'pt_BR', 'en', 'es', 'fr']
changes = {
 'BTN_NASA': ['NASA', 'NASA', 'NASA', 'NASA'],
 'B_HABITAT_DESC': [
  'A casa protege o Mike. Melhore para ampliar a base e as barras.',
  "Mike stays safe here. Upgrade it to expand the base and the bars.",
  'Aquí Mike está a salvo. Mejora la casa para ampliar la base y las barras.',
  "Mike est à l'abri ici. Améliore la maison pour agrandir la base et les barres."],
 'EV_SOLAR_REAL': [
  'Data no arquivo da NASA: {date}.', 'Date in the NASA archive: {date}.',
  'Fecha en el archivo de la NASA: {date}.', "Date dans les archives de la NASA : {date}."],
 'EV_NOSIGNAL_TEXT': [
  'O Sol está entre a Terra e Marte. As mensagens podem falhar por alguns dias.',
  'The Sun is between Earth and Mars. Messages may be disrupted for a few days.',
  'El Sol está entre la Tierra y Marte. Los mensajes pueden fallar unos días.',
  'Le Soleil est entre la Terre et Mars. Les messages peuvent être perturbés quelques jours.'],
 'NASA_DONKI': [
  'Arquivo NASA: {n} registros de clima espacial de 2024. Algumas datas vêm de simulações de chegada a Marte no DONKI. São dados arquivados, não previsões ao vivo.',
  'NASA archive: {n} space weather records from 2024. Some dates come from DONKI simulations of arrivals at Mars. Archived data, not live forecasts.',
  'Archivo NASA: {n} registros de clima espacial de 2024. Algunas fechas vienen de simulaciones de llegada a Marte en DONKI. Son datos archivados, no pronósticos en vivo.',
  "Archives NASA : {n} entrées de météo spatiale de 2024. Certaines dates viennent de simulations d'arrivée sur Mars dans DONKI. Des archives, pas des prévisions en direct."],
 'STORM_WARNING': [
  'Tempestade solar no jogo em {name} sóis!', 'Solar storm in the game in {name} sols!',
  '¡Tormenta solar en el juego en {name} soles!', 'Tempête solaire dans le jeu dans {name} sols !'],
 'OUT_ENERGY': ['Energia baixa. Vamos recuperar!', "Low energy. Let's recharge!", 'Energía baja. ¡Vamos a recuperarla!', "Énergie faible. On recharge !"],
 'OUT_ENERGY_HINT': [
  'Espere a barra amarela subir. Depois, construa um painel solar ou um RTG.',
  'Wait for the yellow bar to rise. Then build a solar panel or an RTG.',
  'Espera a que suba la barra amarilla. Luego construye un panel solar o un RTG.',
  "Attends que la barre jaune remonte. Puis construis un panneau solaire ou un RTG."],
 'OUT_OXYGEN': [
  'Oxigênio baixo. O Mike espera em casa.', 'Low oxygen. Mike waits inside.',
  'Oxígeno bajo. Mike espera en casa.', "Oxygène faible. Mike attend à l'intérieur."],
 'OUT_OXYGEN_HINT': [
  'Espere o oxigênio subir. Um MOXIE ou plantas na estufa ajudam.',
  'Wait for oxygen to rise. A MOXIE or greenhouse plants can help.',
  'Espera a que suba el oxígeno. Un MOXIE o plantas en el invernadero ayudan.',
  "Attends que l'oxygène remonte. Un MOXIE ou des plantes dans la serre peuvent aider."],
 'TUTO_DONE': [
  'Muito bem! Construa a Antena para receber sementes da Terra. Cuide das 3 barras e complete o álbum.',
  'Great job! Build the Antenna to get seeds from Earth. Manage the 3 bars and complete the album.',
  '¡Muy bien! Construye la Antena para recibir semillas de la Tierra. Cuida las 3 barras y completa el álbum.',
  "Bravo ! Construis l'Antenne pour recevoir des graines de la Terre. Gère les 3 barres et complète l'album."],
 'NEED_MAX': ['Você já tem esse item.', 'You already have this item.', 'Ya tienes este objeto.', 'Tu as déjà cet objet.'],
 'SET_ON': ['sim', 'on', 'sí', 'oui'],
 'SET_OFF': ['não', 'off', 'no', 'non'],
 'EXPLORE_EMPTY': [
  'Nenhuma amostra desta vez. O lanche voltou!', 'No sample this time. Your snack is back!',
  'Esta vez no hay muestra. ¡Recuperaste la merienda!', "Pas d'échantillon cette fois. Ton goûter est de retour !"],
 'HOW_STORM': ['Espere uma tempestade solar passar.', 'Wait for a solar storm to pass.', 'Espera a que pase una tormenta solar.', "Attends la fin d'une tempête solaire."],
 'HOW_DUST': ['Espere uma tempestade de poeira passar.', 'Wait for a dust storm to pass.', 'Espera a que pase una tormenta de polvo.', "Attends la fin d'une tempête de poussière."],
 'HOW_AURORA': [
  'Passe por uma tempestade solar com o escudo ligado. A carta é difícil de encontrar!',
  "Get through a solar storm with the shield on. This card is hard to find!",
  'Pasa una tormenta solar con el escudo activado. ¡Esta carta es difícil de conseguir!',
  "Attends la fin d'une tempête solaire avec le bouclier activé. Cette carte est difficile à trouver !"],
 'PACKAGE_PAUSED': [
  'Sem sinal! O pacote chega quando o sinal voltar.', 'No signal! The package arrives when the signal returns.',
  '¡Sin señal! El paquete llega cuando vuelva la señal.', 'Pas de signal ! Le colis arrive au retour du signal.'],
 'REMOVE_TITLE': ['Remover {name}?', 'Remove {name}?', '¿Quitar {name}?', 'Retirer {name} ?'],
 'ITEM_BROKEN': [
  '{name} parou. Toque no item para consertar.', '{name} stopped working. Tap the item to fix it.',
  '{name} dejó de funcionar. Toca el objeto para arreglarlo.', "{name} ne fonctionne plus. Touche cet objet pour le réparer."],
}
log = []
for row in rows:
    if row['keys'] not in changes:
        continue
    for language, revised in zip(fields[1:], changes[row['keys']]):
        old = row[language]
        assert sorted(re.findall(r'\{[^{}]+\}', old)) == sorted(re.findall(r'\{[^{}]+\}', revised)), row['keys']
        if old != revised:
            log.append([row['keys'], language, old, revised])
        row[language] = revised
with source.open('w', encoding='utf-8', newline='') as handle:
    writer = csv.DictWriter(handle, fields, lineterminator='\n')
    writer.writeheader()
    writer.writerows(rows)
if log and not (folder/'alteracoes-textos.csv').exists():
    with (folder/'alteracoes-textos.csv').open('w', encoding='utf-8', newline='') as handle:
        writer=csv.writer(handle,lineterminator='\n')
        writer.writerow(['keys','idioma','antes','depois'])
        writer.writerows(log)
print(f'{len(rows)} keys preserved; {len(log)} cells revised.')

# Phantasmagoria 2 – Sottotitoli in italiano

Sottotitoli italiani (fan-made) per **Phantasmagoria 2: A Puzzle of Flesh** (Sierra, 1996), da usare con [ScummVM](https://www.scummvm.org/).

Il gioco originale è solo in inglese parlato, con centinaia di filmati FMV e nessun sottotitolo.
ScummVM carica automaticamente un file `<n>.DUK.srt` accanto a ogni filmato `<n>.DUK`: questo progetto fornisce quei file.

- 331 filmati sottotitolati (gli altri 155 non hanno parlato)
- ~1650 battute, trascritte con Whisper e tradotte in italiano

## Requisiti

- Phantasmagoria 2 (testato sulla versione Steam)
- ScummVM 2.8 o più recente, con il gioco aggiunto alla libreria

## Installazione

1. Scarica la repo (**Code → Download ZIP**) ed estraila.
2. Tasto destro su `install.ps1` → **Esegui con PowerShell**.
   Lo script trova da solo il gioco nelle librerie Steam; altrimenti chiede il percorso.

Da terminale, anche con un percorso specifico (es. versione GOG):

```powershell
.\install.ps1 -GamePath "C:\Giochi\Phantasmagoria 2"
```

Se Windows blocca lo script ("esecuzione di script disabilitata"), abilita gli script locali per il tuo utente una volta sola:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

In alternativa copia a mano tutti i file di `srt/` nella cartella `Phant2\DUK` del gioco.

### Impostazioni ScummVM

In **Opzioni del gioco → Motore**:

- ✅ *Use high-quality video scaling* (attivo, è il default)
- ❌ *Enable black-lined video* (spento, è il default)

ScummVM disegna i sottotitoli solo nella modalità video ad alta qualità.

## Disinstallazione

```powershell
.\install.ps1 -Uninstall
```

## Limiti

- Sottotitoli solo nei filmati: le poche voci fuori dai video non sono coperte.
- Trascrizione automatica: qualche nome o frase sussurrata può essere imprecisa. Segnalazioni e correzioni benvenute (issue o pull request).

## Correggere una battuta

Le traduzioni stanno in `data/translations/it_*.json` (`id_video → [battute]`, stesso ordine di `data/en/<id>.json`, che contiene testo inglese e tempi).
Dopo la modifica rigenera gli SRT:

```bash
python tools/build_srt.py
```

## Rifare tutto da zero

1. Estrai l'audio dei filmati in `wav/` (16 kHz mono):
   ```bash
   for f in "<gioco>/Phant2/DUK/"*.{DUK,AVI}; do n=$(basename "${f%.*}"); ffmpeg -v error -i "$f" -vn -ac 1 -ar 16000 "wav/$n.wav"; done
   ```
2. Trascrivi con [faster-whisper](https://github.com/SYSTRAN/faster-whisper) (large-v3, GPU NVIDIA consigliata):
   ```bash
   pip install faster-whisper nvidia-cublas-cu12 nvidia-cudnn-cu12
   python tools/transcribe.py
   ```
3. Traduci `data/en` in `data/translations/it_*.json` e lancia `tools/build_srt.py`.

## Note legali

Progetto amatoriale non affiliato a Sierra / Activision. Non contiene file del gioco: serve una copia originale.
Phantasmagoria 2 e i suoi dialoghi sono proprietà dei rispettivi titolari. Gli script sono rilasciati con licenza MIT.

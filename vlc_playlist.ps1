# ==========================================
# Playlist Série VLC - PowerShell
# ==========================================

Add-Type -AssemblyName System.Windows.Forms


# ==========================
# Sélection du dossier série
# ==========================

$folderDialog = New-Object System.Windows.Forms.FolderBrowserDialog

$folderDialog.Description = "Sélectionnez le dossier principal de la série"
$folderDialog.ShowNewFolderButton = $false


$result = $folderDialog.ShowDialog()


if ($result -ne "OK") {
    exit
}


$MAIN_DIR = $folderDialog.SelectedPath



# ==========================
# Configuration
# ==========================

$PLAYLIST = Join-Path $env:TEMP "playlist.m3u"

$VLC = "C:\Program Files\VideoLAN\VLC\vlc.exe"



# ==========================
# Vérification VLC
# ==========================

if (!(Test-Path $VLC)) {

    [System.Windows.Forms.MessageBox]::Show(
        "VLC introuvable.`n`nChemin recherché :`n$VLC",
        "Erreur VLC",
        "OK",
        "Error"
    )

    exit
}



# ==========================
# Création playlist
# ==========================

if (Test-Path $PLAYLIST) {

    Remove-Item $PLAYLIST -Force

}


"#EXTM3U" | Out-File `
    -FilePath $PLAYLIST `
    -Encoding UTF8



# ==========================
# Recherche MKV
# ==========================

$episodes = Get-ChildItem `
    -Path $MAIN_DIR `
    -Filter "*.mkv" `
    -File `
    -Recurse |
    Sort-Object FullName



if ($episodes.Count -eq 0) {

    [System.Windows.Forms.MessageBox]::Show(
        "Aucun fichier MKV trouvé dans ce dossier.",
        "Playlist VLC",
        "OK",
        "Warning"
    )

    exit

}



# ==========================
# Ajout des épisodes
# ==========================

foreach ($episode in $episodes) {

    $episode.FullName | Out-File `
        -FilePath $PLAYLIST `
        -Append `
        -Encoding UTF8

}



# ==========================
# Lancement VLC
# ==========================

Start-Process `
    -FilePath $VLC `
    -ArgumentList "`"$PLAYLIST`""


exit
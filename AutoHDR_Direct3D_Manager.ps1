# ==========================================
# Auto HDR Direct3D Registry Manager
# Windows 11
# ==========================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Fenêtre propriétaire invisible pour forcer les dialogues au premier plan
$owner = New-Object System.Windows.Forms.Form
$owner.TopMost = $true
$owner.Show()
$owner.Hide()

$base = "HKCU:\Software\Microsoft\Direct3D"


# ==========================
# Création clé Direct3D si inexistante
# ==========================

if (!(Test-Path $base)) {
    New-Item -Path $base -Force | Out-Null
}


# ==========================
# Menu principal
# ==========================

$menuForm = New-Object System.Windows.Forms.Form

$menuForm.Text = "Auto HDR Direct3D"
$menuForm.Size = New-Object System.Drawing.Size(420,210)
$menuForm.StartPosition = "CenterScreen"
$menuForm.TopMost = $true
$menuForm.FormBorderStyle = "FixedDialog"
$menuForm.MaximizeBox = $false
$menuForm.MinimizeBox = $false


$menuLabel = New-Object System.Windows.Forms.Label

$menuLabel.Text = "Choisissez une action :"
$menuLabel.Location = New-Object System.Drawing.Point(20,20)
$menuLabel.Size = New-Object System.Drawing.Size(360,25)


$addButton = New-Object System.Windows.Forms.Button

$addButton.Text = "Ajouter ou mettre a jour un jeu"
$addButton.Location = New-Object System.Drawing.Point(20,60)
$addButton.Size = New-Object System.Drawing.Size(360,35)


$deleteButton = New-Object System.Windows.Forms.Button

$deleteButton.Text = "Supprimer un jeu existant"
$deleteButton.Location = New-Object System.Drawing.Point(20,105)
$deleteButton.Size = New-Object System.Drawing.Size(360,35)


$quitButton = New-Object System.Windows.Forms.Button

$quitButton.Text = "Quitter"
$quitButton.Location = New-Object System.Drawing.Point(145,150)
$quitButton.Size = New-Object System.Drawing.Size(130,30)


$action = $null


$addButton.Add_Click({
    $script:action = "Add"
    $menuForm.Close()
})


$deleteButton.Add_Click({
    $script:action = "Delete"
    $menuForm.Close()
})


$quitButton.Add_Click({
    $script:action = "Quit"
    $menuForm.Close()
})


$menuForm.Controls.Add($menuLabel)
$menuForm.Controls.Add($addButton)
$menuForm.Controls.Add($deleteButton)
$menuForm.Controls.Add($quitButton)


$menuForm.ShowDialog() | Out-Null


if ($action -eq "Quit" -or $null -eq $action) {

    $owner.Close()
    exit

}


# ==========================
# Suppression d'une entrée
# ==========================

if ($action -eq "Delete") {

    $entries = @()


    Get-ChildItem $base -ErrorAction SilentlyContinue | ForEach-Object {

        $data = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue


        if ($null -ne $data.Name -and $_.PSChildName -match "^Application\d+$") {

            $entries += [PSCustomObject]@{

                Key = $_.PSChildName
                EXE = $data.Name

            }

        }

    }


    if ($entries.Count -eq 0) {

        [System.Windows.Forms.MessageBox]::Show(
            $owner,
            "Aucune entree Auto HDR n'a ete trouvee.",
            "Suppression",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null

        $owner.Close()
        exit

    }


    $deleteForm = New-Object System.Windows.Forms.Form

    $deleteForm.Text = "Supprimer un jeu"
    $deleteForm.Size = New-Object System.Drawing.Size(500,190)
    $deleteForm.StartPosition = "CenterScreen"
    $deleteForm.TopMost = $true


    $deleteLabel = New-Object System.Windows.Forms.Label

    $deleteLabel.Text = "Selectionnez le jeu a supprimer :"
    $deleteLabel.Location = New-Object System.Drawing.Point(15,20)
    $deleteLabel.Size = New-Object System.Drawing.Size(450,25)


    $comboBox = New-Object System.Windows.Forms.ComboBox

    $comboBox.Location = New-Object System.Drawing.Point(15,50)
    $comboBox.Size = New-Object System.Drawing.Size(450,30)
    $comboBox.DropDownStyle = "DropDownList"


    foreach ($entry in $entries) {

        [void]$comboBox.Items.Add("$($entry.EXE) - $($entry.Key)")

    }


    $comboBox.SelectedIndex = 0


    $deleteButton2 = New-Object System.Windows.Forms.Button

    $deleteButton2.Text = "Supprimer"
    $deleteButton2.Location = New-Object System.Drawing.Point(270,100)
    $deleteButton2.Size = New-Object System.Drawing.Size(95,30)


    $cancelButton = New-Object System.Windows.Forms.Button

    $cancelButton.Text = "Annuler"
    $cancelButton.Location = New-Object System.Drawing.Point(370,100)
    $cancelButton.Size = New-Object System.Drawing.Size(95,30)


    $selectedEntry = $null


    $deleteButton2.Add_Click({

        $script:selectedEntry = $entries[$comboBox.SelectedIndex]
        $deleteForm.Close()

    })


    $cancelButton.Add_Click({

        $deleteForm.Close()

    })


    $deleteForm.Controls.Add($deleteLabel)
    $deleteForm.Controls.Add($comboBox)
    $deleteForm.Controls.Add($deleteButton2)
    $deleteForm.Controls.Add($cancelButton)


    $deleteForm.ShowDialog() | Out-Null


    if ($null -eq $selectedEntry) {

        $owner.Close()
        exit

    }


    $confirm = [System.Windows.Forms.MessageBox]::Show(
        $owner,
        "Supprimer cette entree ?`n`nJeu : $($selectedEntry.EXE)`nCle : $($selectedEntry.Key)",
        "Confirmation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )


    if ($confirm -eq "Yes") {

        Remove-Item -Path "$base\$($selectedEntry.Key)" -Recurse -Force

        [System.Windows.Forms.MessageBox]::Show(
            $owner,
            "Entree supprimee.",
            "Auto HDR",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        ) | Out-Null

    }


    $owner.Close()
    exit

}

# ==========================
# Choix du type de jeu
# ==========================

$result = [System.Windows.Forms.MessageBox]::Show(
    $owner,
    "Le jeu est-il sur le gamepass?`n`n" +
    "Oui = entrer le nom EXE (GamePass)`n`n" +
    "Non = choisir un fichier EXE (Steam/Epic)",
    "Auto HDR Direct3D",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)


# ==========================
# Steam / Epic
# ==========================

if ($result -eq "No") {


    $dialog = New-Object System.Windows.Forms.OpenFileDialog

    $dialog.Title = "Choisir le jeu"
    $dialog.Filter = "Fichier executable (*.exe)|*.exe"


    if ($dialog.ShowDialog() -ne "OK") {
        exit
    }


    $exe = Split-Path $dialog.FileName -Leaf

}



# ==========================
# Game Pass
# ==========================

else {


    $form = New-Object System.Windows.Forms.Form

    $form.Text = "Jeu GamePass"
    $form.Size = New-Object System.Drawing.Size(420,160)
    $form.StartPosition = "CenterScreen"
    $form.TopMost = $true
    $form.Activate()
    $form.BringToFront()


    $label = New-Object System.Windows.Forms.Label

    $label.Text = "Nom exact de l'executable. exemple : monjeux.exe"
    $label.Location = New-Object System.Drawing.Point(10,15)
    $label.Size = New-Object System.Drawing.Size(380,20)



    $textbox = New-Object System.Windows.Forms.TextBox

    $textbox.Location = New-Object System.Drawing.Point(10,45)
    $textbox.Size = New-Object System.Drawing.Size(380,25)



    $button = New-Object System.Windows.Forms.Button

    $button.Text = "Valider"
    $button.Location = New-Object System.Drawing.Point(300,85)
    $button.Size = New-Object System.Drawing.Size(90,25)



    $button.Add_Click({

        $form.Close()

    })



    $form.Controls.Add($label)
    $form.Controls.Add($textbox)
    $form.Controls.Add($button)


    $form.ShowDialog() | Out-Null


    $exe = $textbox.Text.Trim()


    if ([string]::IsNullOrWhiteSpace($exe)) {
        exit
    }

}



Write-Host ""
Write-Host "Executable choisi :" $exe -ForegroundColor Cyan



# ==========================
# Recherche doublon EXE
# ==========================


$existing = $null


Get-ChildItem $base -ErrorAction SilentlyContinue | ForEach-Object {


    $data = Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue


    if ($data.Name -eq $exe) {

        $existing = $_.PSChildName

    }

}



if ($existing) {


    $answer = [System.Windows.Forms.MessageBox]::Show(
        $owner,
        "Ce jeu existe deja dans : $existing`n`nMettre a jour cette entree ?",
        "Doublon detecte",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )


    if ($answer -ne "Yes") {
        exit
    }


    $key = "$base\$existing"

}

else {


    # Recherche Application libre


    $i = 0


    do {


        $newName = "Application$i"

        $exists = Test-Path "$base\$newName"

        $i++


    } while ($exists)



    $key = "$base\$newName"


    New-Item -Path $key -Force | Out-Null



}

# ==========================
# Compatibilité Auto HDR
# ==========================

$autoHDR = [System.Windows.Forms.MessageBox]::Show(
    $owner,
    "Le jeu est-il compatible avec Windows Auto HDR ?`n`n" +
    "Oui :`n" +
    "Le jeu est deja reconnu par Auto HDR.`n" +
    "Ne pas activer le mode Override.`n`n" +
    "Non :`n" +
    "Le jeu n'est pas reconnu par Auto HDR.`n" +
    "Activer le mode Override pour tenter de forcer Auto HDR.",
    "Compatibilite Auto HDR",
    [System.Windows.Forms.MessageBoxButtons]::YesNo,
    [System.Windows.Forms.MessageBoxIcon]::Question
)



if ($autoHDR -eq "Yes") {


    $enable10bit = [System.Windows.Forms.MessageBox]::Show(
        $owner,
        "Le jeu est deja compatible Auto HDR.`n`n" +
        "Voulez-vous activer BufferUpgradeEnable10Bit=1 ?`n`n" +
        "Oui : cree une entree avec BufferUpgradeEnable10Bit=1.`n" +
        "Non : aucune entree ne sera creee.",
        "Buffer 10 bits Auto HDR",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )


    if ($enable10bit -eq "Yes") {

        $behavior = "BufferUpgradeEnable10Bit=1"

    }
    else {

        # Suppression de la clé Application créée avant
        Remove-Item -Path $key -Recurse -Force -ErrorAction SilentlyContinue

        $owner.Close()
        exit

    }


}
else {


    # Jeu non reconnu par Auto HDR

    $behavior = "BufferUpgradeOverride=1;BufferUpgradeEnable10Bit=1"


}

# ==========================
# Écriture registre
# ==========================


New-ItemProperty `
-Path $key `
-Name "Name" `
-Value $exe `
-PropertyType String `
-Force | Out-Null



New-ItemProperty `
-Path $key `
-Name "D3DBehaviors" `
-Value $behavior `
-PropertyType String `
-Force | Out-Null




# ==========================
# Résultat
# ==========================


[System.Windows.Forms.MessageBox]::Show(
$owner,
"Configuration terminee !`n`n" +
"Cle : $key`n" +
"EXE : $exe`n`n" +
"D3DBehaviors :`n$behavior",
"Auto HDR",
[System.Windows.Forms.MessageBoxButtons]::OK,
[System.Windows.Forms.MessageBoxIcon]::Information
) | Out-Null


$owner.Close()
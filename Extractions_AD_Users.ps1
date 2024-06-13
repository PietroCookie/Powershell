# Spécifier le chemin de l'OU que vous souhaitez extraire
$ouPath = "OU=ORGANIZATIONAL_UTILS,DC=DOMAINE.LOCAL,DC=ad"

# Obtenir tous les utilisateurs de l'OU spécifiée avec les champs souhaités
$users = Get-ADUser -Filter * -SearchBase $ouPath -Properties PasswordLastSet,LastLogonDate,Enabled,lastLogon,MemberOf

# Initialiser une collection pour stocker les détails de chaque utilisateur
$userDetails = @()

# Parcourir chaque utilisateur et extraire les détails requis
foreach ($user in $users) {
  $lastPasswordSet = $user.PasswordLastSet
  $lastLogonDate = $user.LastLogonDate

  $lastLogon = [DateTime]::FromFileTimeUtc($user.lastLogon)

  $estMembrePSOUsers = $user.MemberOf -contains (Get-ADGroup -Filter { Name -eq "GG_PSO_users" }).DistinguishedName
   
  # Vérifier si le compte est actif
  if ($user.Enabled) {
    $accountStatus = "Actif"
  } else {
    $accountStatus = "Inactif"
  }

  # Ajouter les détails de l'utilisateur à la collection
  $userDetails += New-Object PSObject -Property @{
    "Nom du compte" = $user.SamAccountName
    "Date du dernier changement de mot de passe" = $lastPasswordSet
    "Compte actif" = $accountStatus
    "Date du dernier login (lastLogonTimestamp)" = $lastLogonDate
    "Date du dernier login (lastLogon)" = $lastLogon
    "Membre du groupe GG_PSO_users" = $estMembrePSOUsers
    
  }
}

# Exporter les détails des utilisateurs dans un fichier CSV
$userDetails | Export-Csv -Path "C:\temp\User_extract.csv" -NoTypeInformation

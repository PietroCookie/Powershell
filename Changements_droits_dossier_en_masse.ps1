# Chemin du dossier dont on modifie les droits de tous les sous-répertoires
$path = "PATH"
# Nom du compte à qui on rajoute les droits
$accountNewAccess = "USER/OU"

Function ModifyAccess($folder) {
    $securityFolder = Get-Acl -Path $folder
    $newRulesAccess = New-Object System.Security.AccessControl.FileSystemAccessRule($accountNewAccess, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")

    $securityFolder.AddAccessRule($newRulesAccess)
    Set-Acl -Path $folder -AclObject $securityFolder

    Write-Host "Les droits sur $folder pour $accountNewAccess ont été ajouté"
}

Get-ChildItem -Path $path -Directory -Recurse | ForEach-Object {
    ModifyAccess($_.FullName)
}
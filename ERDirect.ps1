Connect-AzAccount -Subscription 'Microsoft Sponsored - 1'

$rgname = "er-direct-westcentral-rg"
$ername = "er-direct-westcentral"
$kvname = "er-direct-westcentral-kv"

# Set the length of the hexadecimal string
$length = 64

# Generate a random hexadecimal string
$cknstring = -join (Get-Random -Count $length -Minimum 0 -Maximum 16 | ForEach-Object { $_.ToString("X") })
$cknstring = -join (Get-Random -Count $length -Minimum 0 -Maximum 16 | ForEach-Object { $_.ToString("X") })


$CAK = ConvertTo-SecureString $cknstring -AsPlainText -Force
$CKN = ConvertTo-SecureString $cknstring -AsPlainText -Force
$MACsecCAKSecret = Set-AzKeyVaultSecret -VaultName $kvname -Name "CAK-ER-Direct-AUE" -SecretValue $CAK
$MACsecCKNSecret = Set-AzKeyVaultSecret -VaultName $kvname -Name "CKN-ER-Direct-AUE" -SecretValue $CKN

$secret = Get-AzKeyVaultSecret -VaultName $kvname -Name "CAK-ER-Direct-AUE"
$secret

$erDirect = Get-AzExpressRoutePort -ResourceGroupName $rgname -Name $ername
$erIdentity = Get-AzExpressRoutePortIdentity -ExpressRoutePort $erDirect

$erDirect.Links[0]. MacSecConfig.CknSecretIdentifier = $MacSecCKNSecret.Id
$erDirect.Links[0]. MacSecConfig.CakSecretIdentifier = $MacSecCAKSecret.Id
$erDirect.Links[0]. MacSecConfig.Cipher = "GcmAes256"
$erDirect.Links[1]. MacSecConfig.CknSecretIdentifier = $MacSecCKNSecret.Id
$erDirect.Links[1]. MacSecConfig.CakSecretIdentifier = $MacSecCAKSecret.Id
$erDirect.Links[1]. MacSecConfig.Cipher = "GcmAes256"
$erDirect.identity = $erIdentity
Set-AzExpressRoutePort -ExpressRoutePort $erDirect
# Request-StackAPI.ps1
# Generate CloudStack API Request URL
# Writen by Takashi Kanai (anikundesu@gmail.com)
#
# 2011/9/16  v1.0 created

[VOID][System.Reflection.Assembly]::Load("System.Web, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a");

### Definition of Variables
$ADDRESS="http://(your URL):8080/client/api?"
$API_KEY="(Your API Key)"
$SECRET_KEY="(Your Secret Key)"

$WebClient = New-Object net.WebClient

### URL Encoding $COMMAND variable
$APIKeyURI="apikey="+($API_KEY)+"&"
$EncodedCommand="apikey="+($API_KEY).ToLower()

if($args.length -eq 0)
{
    echo "Usage: .\Request-StackAPI.ps1 command=(your command) param1=var1 param2=var2 ...."
    echo "for example: .\Request-StackAPI.ps1 command=listVirtualMachine"
    exit
}

### Generate URL

$ArrayCOMMAND = $args
$COMMAND=$args[0]
for($i=1; $i -lt $args.length; $i++)
{
    $COMMAND += "&"+$args[$i]
}

### to lower & URL Encode 
foreach($keyvalue in $ArrayCOMMAND){
    $key = ($keyvalue -split "=")[0].ToLower()
    $value = ($keyvalue -split "=")[1]
    $encoded = ([System.Web.HttpUtility]::UrlEncode($value)).ToLower() -replace "\+","%20"
    $EncodedCommand += "&$key=$encoded"
}

### Sort All Parameters
$ParamList = $EncodedCommand -split "&" | sort
for($i = 0; $i -lt $ParamList.Length; $i++)
{
    if($i -eq 0)
    {
        $EncodedCommand = $ParamList[$i]
    }
    else
    {
        $EncodedCommand += "&"+$ParamList[$i]
    }
}

### Signing Encoded URL with $SECRET_KEY
$HMAC_SHA1 = New-Object System.Security.Cryptography.HMACSHA1
$HMAC_SHA1.key = [Text.Encoding]::ASCII.GetBytes($SECRET_KEY)
$Digest = $HMAC_SHA1.ComputeHash([Text.Encoding]::ASCII.GetBytes($EncodedCommand))
$Base64Digest = [Convert]::ToBase64String($Digest)  
$signature = [System.Web.HttpUtility]::UrlEncode($Base64Digest)
$URL = $ADDRESS+$APIKeyURI+$COMMAND+"&signature="+$signature

### Print Generated URLs (for Debug)
##echo "EncodedCommand: "$EncodedCommand
##echo "BASE64&URL Encoded Digest: " $Signature
##echo "URL: "$URL


### Execute API Access & get Response as XML 
$Response = [xml]$WebClient.DownloadString($URL)
$Response

exit
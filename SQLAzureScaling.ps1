param
(
        # Target Resource Group
        [parameter(Mandatory=$true)] 
        [string] $ResourceGroup,
        # Name of the Azure SQL Database server WITHOUT the trailing '.database.windows.net'
        [parameter(Mandatory=$true)] 
        [string] $SqlServerName,
        # Target Azure SQL Database name 
        [parameter(Mandatory=$true)] 
        [string] $DatabaseName,
        # Desired Azure SQL Database edition {Basic, Standard, Premium, GeneralPurpose}
        [parameter(Mandatory=$true)] 
        [string] $Edition,
        # Desired scale. 1, 2, 4... 16 for $Edition=GeneralPurpose
        # S0-S12 for $Edition=Standard and P1 to P15 $Edition=Premium 
        [parameter(Mandatory=$true)]
        [string] $Capacity,
        # Desired compute model
        [parameter(Mandatory=$true)] 
        [string] $ServerlessOrProvisioned = "Serverless",
        # Azure Automation Run As account name. Needs to be able to access target 
        [parameter(Mandatory=$false)] 
        [string] $AzureRunAsConnectionName = "AzureRunAsConnection"
)

$servicePrincipalConnection = Get-AutomationConnection -Name $AzureRunAsConnectionName
Connect-AzAccount `
        -ServicePrincipal `
        -TenantId $servicePrincipalConnection.TenantId `
        -ApplicationId $servicePrincipalConnection.ApplicationId `
        -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint


if($Edition -eq "GeneralPurpose")
{
    Write-Output "Scaling GP"
    Set-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $SqlServerName -DatabaseName $DatabaseName -Edition $Edition -VCore $Capacity -ComputeModel $ServerlessOrProvisioned -ComputeGeneration Gen5
}
else
{
    Write-Output "Scaling DTU based"
    Set-AzSqlDatabase -ResourceGroupName $ResourceGroup -ServerName $SqlServerName -DatabaseName $DatabaseName -Edition $Edition -RequestedServiceObjectiveName $Capacity     
}

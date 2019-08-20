workflow PeriodicallyDeleteResourceGroups
{
    Write-Output "---------Logging in...---------"
    Get-Date -Format o
    Write-Output "-------------------------------"
    $connectionName = "AzureRunAsConnection"
    try
    {
        # Get the connection "AzureRunAsConnection "
        $servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        "Logging in to Azure..."
        Add-AzureRmAccount `
            -ServicePrincipal `
            -TenantId $servicePrincipalConnection.TenantId `
            -ApplicationId $servicePrincipalConnection.ApplicationId `
            -CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
    }
    catch {
        if (!$servicePrincipalConnection)
        {
            $ErrorMessage = "Connection $connectionName not found."
            throw $ErrorMessage
        } else{
            Write-Error -Message $_.Exception
            throw $_.Exception
        }
    }
    Write-Output "---------Logged in---------"
    Get-Date -Format o
    Write-Output "---------------------------"

    Write-Output "---------Starting deleting...---------"
    Get-Date -Format o
    Write-Output "--------------------------------------"
    $azrg = Get-AzureRmResourceGroup
    foreach -parallel ($rg in $azrg) 
    { 
        if($rg.Tags.count -eq 0 -Or ($rg.Tags.count -ne 0 -And $rg.Tags["Locked"] -ne "yes"))
        {
            Write-Output ("Removing: " + $rg.ResourceGroupName)
            Remove-AzureRmResourceGroup -Name $rg.ResourceGroupName -Force
        }
    }
    Write-Output "---------Deleting finished---------"
    Get-Date -Format o
    Write-Output "-----------------------------------"
}

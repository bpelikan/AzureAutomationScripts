workflow PeriodicallyDeleteResourceGroups
{
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

    Write-Output "--------------"
    $azrg = Get-AzureRmResourceGroup
    foreach -parallel ($rg in $azrg) 
    { 
        if($rg.Tags["Locked"] -ne "yes")
        {
            Write-Output ("Removing: " + $rg.ResourceGroupName)
            Remove-AzureRmResourceGroup -Name $rg.ResourceGroupName -Force
        }
    }
}

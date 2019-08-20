workflow Start-Stop-All-Web-Apps
{
    Param 
    (    
        [Parameter(Mandatory=$true)][ValidateSet("Start","Stop")] 
        [String] 
        $Action 
    ) 
     
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
 
    $WebApps = Get-AzureRmWebApp

    Write-Output "--------------"
    if($Action -eq "Stop") 
    { 
        Write-Output "Stopping all Web Apps"; 
        foreach -parallel ($WebApp in $WebApps) 
        { 
            Stop-AzureRmWebApp -ResourceGroupName $WebApp.ResourceGroup -Name $WebApp.Name
        } 
    } 
    else 
    { 
        Write-Output "Starting all Web Apps"; 
    }
}

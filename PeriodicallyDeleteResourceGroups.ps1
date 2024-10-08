workflow PeriodicallyDeleteResourceGroups
{
    Write-Output "---------Logging in...---------"
	Get-Date -Format o
    Write-Output "-------------------------------"

    try
    {
        "Logging in to Azure..."
        Connect-AzureRMAccount –Identity
        Write-Output "---------Logged in---------"
        Get-Date -Format o
        Write-Output "---------------------------"
    }
    catch {
        Write-Error -Message $_.Exception
        throw $_.Exception
    }
    
    Write-Output "---------Starting deleting...---------"
	Get-Date -Format o
    Write-Output "--------------------------------------"
    
    $azrg = Get-AzureRmResourceGroup
    foreach -parallel ($rg in $azrg) 
    { 
        if($rg.Tags.count -eq 0 -Or ($rg.Tags.count -ne 0 -And $rg.Tags["Locked"] -ne "yes"))
        {
            Write-Output ("Removing resource group: `"" + $rg.ResourceGroupName + "`"")
            Remove-AzureRmResourceGroup -Name $rg.ResourceGroupName -Force
        }
    }
    Write-Output "---------Deleting finished---------"
	Get-Date -Format o
    Write-Output "-----------------------------------"
}

function Get-TargetResource
{
	[OutputType([Hashtable])]
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[alias("Modules","Module")][array]$Modulelist

	)
	
    [reflection.assembly]::LoadWithPartialName("Microsoft.Web.PlatformInstaller") | Out-Null
    $ProductManager = New-Object Microsoft.Web.PlatformInstaller.ProductManager
    $ProductManager.Load()
    foreach ($Module in $Modulelist){
        if (!$($ProductManager.Products | ? ProductId -like "*$Module*" -and Installed -eq $true)){
        Write-Verbose "Module Missing: $Module"
        }
        else {Write-Verbose "Module Installed: $Module"}
        }


<#
	if(!(Test-Path -Path $($DestinationFolder,$DestinationFilename -join "\")))
	{
		Write-Verbose "File is not present and needs to be downloaded."
		$Configuration = @{
					Ensure = $Ensure
					SourceURL = $SourceURL
					DestinationFolder = $DestinationFolder
					DestinationFilename = $DestinationFilename
					}
	}
	else
	{
		Write-Verbose "File is present."
		$Configuration = @{
					Ensure = $Ensure
					SourceURL = $SourceURL
					DestinationFolder = $DestinationFolder
					DestinationFilename = $DestinationFilename
					}
	}
	
		
}
#>



function Set-TargetResource
{
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[alias("Modules","Module")][array]$Modulelist

	)
	try
	{
	$myLogSource = $PSCmdlet.MyInvocation.MyCommand.ModuleName
	New-Eventlog -LogName "DevOps" -Source $myLogSource -ErrorAction SilentlyContinue
	}
	catch {}
	
	if ($Ensure -like 'Present')
	{
		if(!(Test-Path -Path $DestinationFolder)) 
		{
			Write-Verbose "Folder is not present and will be created."
			New-Item $DestinationFolder -type directory
		}

		if(!(Test-Path -Path $($DestinationFolder,$DestinationFilename -join "\"))) 
		{
			Write-Verbose "File is not present and will be downloaded."
			$downloadtry = 1
			While ($downloadtry -lt 4)
				{
					try{
						Write-Verbose "Trying download $downloadtry"
						$webclient = New-Object System.Net.WebClient
						$webclient.DownloadFile($SourceURL,$($DestinationFolder,$DestinationFilename -join "\"))
						$downloadtry = 4
					}
					catch [System.Net.WebException] {
						Write-Verbose "Download failed"
						$downloadtry++
						}
				}
		}
		else
		{
			Write-Verbose "File is present, no action needed."
		}
	}
	else
	{
		if (!(Test-Path -Path $($DestinationFolder,$DestinationFilename -join "\")))
		{
			Write-Verbose "File is not present, no action needed"
		}
		else
		{
			Write-Verbose "File is present, and will be removed."
			Remove-Item $($DestinationFolder,$DestinationFileName -join "\") -recurse
		}
	}
}




function Test-TargetResource
{
	[OutputType([boolean])]
	param
	(
		[Parameter()]
		[ValidateSet("Present", "Absent")]
		[string]$Ensure = "Present",
		
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[alias("Modules","Module")][array]$Modulelist

	)
	
	$IsValid = $false
	
	$FileLocation = $($DestinationFolder,$DestinationFilename -join "\")
	
	if ($Ensure -like 'Present')
	{
		Write-Verbose "Checking for $DestinationFilename inside $DestinationFolder."
		if(!(Test-Path -Path $($DestinationFolder,$DestinationFilename -join "\")))
		{
			Write-Verbose "File is not present."
		}
		else
		{
			Write-Verbose "File is present."
			$IsValid = $true
		}
	}
	else
	{
		if(!(Test-Path -Path $($DestinationFolder,$DestinationFilename -join "\")))
		{
			Write-Verbose "File is not present."
			$IsValid = $true
		}
		else
		{
			Write-Verbose "File is present."
		}
	}
	return $IsValid
}




													
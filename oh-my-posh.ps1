# This PS Script configures for oh-my-posh
# Refer https://ohmyposh.dev/docs/installation/prompt for more info



function Get-FileEncoding($Path) {
    $bytes = [byte[]](Get-Content $Path -Encoding byte -ReadCount 4 -TotalCount 4)

    if(!$bytes) { return 'utf8' }

    switch -regex ('{0:x2}{1:x2}{2:x2}{3:x2}' -f $bytes[0],$bytes[1],$bytes[2],$bytes[3]) {
        '^efbbbf'   { return 'utf8' }
        '^2b2f76'   { return 'utf7' }
        '^fffe'     { return 'unicode' }
        '^feff'     { return 'bigendianunicode' }
        '^0000feff' { return 'utf32' }
        default     { return 'ascii' }
    }
}




# check if $target is installed
$target = "JanDeDobbeleer.OhMyPosh"
$check = (winget list -e $target | Select-String -Pattern "No installed package found matching input criteria.").Matches.Success
echo $check
# install $target if not exists
if ($check){
	winget install JanDeDobbeleer.OhMyPosh -s winget
}


$file = $PROFILE

# check if $PROFILE exists, create if not exists.
if (-not(Test-Path -Path ($file) -PathType Leaf)) {
	echo ("not found: [$file]")
	try {
		$null = New-Item -ItemType File -Path $file -Force -ErrorAction Stop
		Write-Host "The file [$file] has been created."
	}catch{
		echo "FAILED TO CREATE " + $file
		echo $_.Exception.Message
		return
	}
}

# Search for Command in $PROFILE
$command = "oh-my-posh init pwsh | Invoke-Expression"
$search = (Get-Content $file | Select-String -Pattern $command).Matches.Success

# Add command if $command is not configured
if (!$search){
	echo "adding command..."
	printf ("\n" + $command) | Out-File $file -Append -Encoding (Get-FileEncoding($file))
	. $PROFILE
}
echo "Successfully configured OH-MY-POSH"

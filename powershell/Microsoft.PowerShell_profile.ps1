##### CONFIGURE/LIST MODULES #####
# PSReadLine
Set-PSReadlineOption -EditMode Emacs

# posh-git
# No config yet

# Get-ChildItem-Color
. "~\Documents\WindowsPowerShell\Get-ChildItem-Color\Get-ChildItem-Color.ps1"
Set-Alias l Get-ChildItem-Color -Option AllScope
Set-Alias ls Get-ChildItem-Format-Wide -Option AllScope

##################################

# Start in the home directory
Set-Location ~

# Customize prompt
function prompt {
    $origLastExitCode = $LASTEXITCODE

    # Display the username and computername
    Write-Host "$env:UserName@$env:ComputerName" -ForegroundColor DarkGreen -NoNewline
    Write-Host ":" -ForegroundColor White -NoNewline

    # Display the path
    $currPath = $ExecutionContext.SessionState.Path.CurrentLocation.Path
    if ($currPath.ToLower().StartsWith($Home.ToLower()))
    {
        $currPath = "~" + $currPath.SubString($Home.Length)
    }
    Write-Host $currPath -ForegroundColor Cyan -NoNewline

    # Display the Git status text
    # The conditional prevents the posh-git module from being loaded every time
    # PowerShell is started. This way, it's only loaded the first time a git
    # repo is entered.
    # The (Get-Module posh-git) condition defaults to using Write-VcsStatus
    # once posh-git is loaded, though, since it's faster than "git rev-parse".
    if ((Get-Module posh-git) -or (git rev-parse --is-inside-work-tree)) {
        Write-VcsStatus
    }

    $LASTEXITCODE = $origLastExitCode

    # Display the prompt character
    If ($nestedPromptLevel -eq 0) {
        $promptChar = "$"
    } Else {
        $promptChar = ">"
    }
    "$($promptChar * ($nestedPromptLevel + 1)) "
}

# Aliases
# lo will use the original pipeable Get-ChildItem functionality
Set-Alias lo Get-ChildItem -Option AllScope

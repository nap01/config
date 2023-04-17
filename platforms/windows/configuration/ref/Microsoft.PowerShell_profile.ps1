# The first time the Terminal-Icons module needs to be installed:
# Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module Terminal-Icons

# Startup

function changeTheme {
    $Themes = "C:\Users\timde\AppData\Local\Programs\oh-my-posh\themes\"
    $Theme = $args[0]
    if($null -eq $Theme) {
        $Theme = Get-ChildItem $Themes -name | Select-Object -index $(Random $((Get-ChildItem $Themes).Count))
    } else {
        $Theme = $Theme + ".omp.json"
    }
    Write-Output "Using $Theme"
    oh-my-posh init pwsh --config "$Themes$Theme" | Invoke-Expression
}

# Always use a random theme
changeTheme

fnm env --use-on-cd | Out-String | Invoke-Expression

# History

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows

# Alias

Set-Alias -Name code -Value code-insiders

function .. {
    cd ..
}

function .... {
    cd ../../
}

function ...... {
    cd ../../../
}

function oss {
    cd "~/dev/oss/$args"
}

function work {
    cd "~/dev/work/$args"
}

# Git

function gb {
    git checkout -b $args
}

function gbt ([string] $taskid) {
    git checkout -b "task/$taskid"
}

function gs {
    git checkout $args
    git pull
}

function gmaster {
    gs 'master'
}

function gmain {
    gs 'main'
}

function gdev {
    gs 'develop'
}

function gco {
    git add .
    git commit -m $args
}

function gfeat {
    if($null -eq $args[1]) {
        gco "feat: $($args[0])"
    }else {
        gco "feat($($args[0])): $($args[1])"
    }
}

function gfix {
    if($null -eq $args[1]) {
        gco "fix: $($args[0])"
    }else {
        gco "fix($($args[0])): $($args[1])"
    }
}

function gtest {
    if($null -eq $args[1]) {
        gco "test: $($args[0])"
    }else {
        gco "test($($args[0])): $($args[1])"
    }
}

function gdocs {
    if($null -eq $args[1]) {
        gco "docs: $($args[0])"
    }else {
        gco "docs($($args[0])): $($args[1])"
    }
}

function gstyle {
    if($null -eq $args[1]) {
        gco "style: $($args[0])"
    }else {
        gco "style($($args[0])): $($args[1])"
    }
}

function grefactor {
    if($null -eq $args[1]) {
        gco "refactor: $($args[0])"
    }else {
        gco "refactor($($args[0])): $($args[1])"
    }
}

function gperf {
    if($null -eq $args[1]) {
        gco "perf: $($args[0])"
    }else {
        gco "perf($($args[0])): $($args[1])"
    }
}

function gchore {
    if($null -eq $args[1]) {
        gco "chore: $($args[0])"
    }else {
        gco "chore($($args[0])): $($args[1])"
    }
}

function gpu {
    git pull
}

function goops {
    git add .
    git commit --amend --no-edit
}

function gfp {
    git push --force-with-lease
}

function gr {
    git reset --hard
    git clean -f -d
}

# Macros

# Inspired by Scott's profile https://gist.github.com/shanselman/25f5550ad186189e0e68916c6d7f44c3
Set-PSReadLineKeyHandler -Key Ctrl+Shift+b `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        if(Test-Path -Path ".\package.json") {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm run build")
        }else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet build")
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }

Set-PSReadLineKeyHandler -Key Ctrl+Shift+t `
    -BriefDescription BuildCurrentDirectory `
    -LongDescription "Build the current directory" `
    -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        if(Test-Path -Path ".\package.json") {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm run test")
        }else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet test")
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }

Set-PSReadLineKeyHandler -Key Ctrl+Shift+s `
    -BriefDescription StartCurrentDirectory `
    -LongDescription "Start the current directory" `
    -ScriptBlock {
        [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
        if(Test-Path -Path ".\package.json") {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("npm start")
        }else {
            [Microsoft.PowerShell.PSConsoleReadLine]::Insert("dotnet run")
        }
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
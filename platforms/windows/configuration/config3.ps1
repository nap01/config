# Script Configuration
$gitconfig = @" 
[includeIf "gitdir:~/git/home/"]
  path = ~/git/.gitconfig-home
[includeIf "gitdir:~/git/work/"]
  path = ~/git/.gitconfig-work
[includeIf "gitdir:~/git/foss/"]
  path = ~/git/.gitconfig-foss
[includeIf "gitdir:~/git/gdev/"]
  path = ~/git/.gitconfig-gdev
"@

$gitconfig-home = @" 
[user]
 name = home_user
 email = home_email
"@

$gitconfig-work = @" 
[user]
 name = work_user
 email = work_email
"@

$gitconfig-foss = @" 
[user]
 name = foss_user
 email = foss_email
"@

$gitconfig-gdev = @" 
[user]
 name = gdev_user
 email = gdev_email
"@

# Install fnm
cargo install fnm
Add-Content $profile "fnm env --use-on-cd | Out-String | Invoke-Expression" 

# Configure Git
sl ~
mkdir git
sl git
ni .gitconfig
Add-Content .gitconfig "$gitconfig"
mkdir home
mkdir work
mkdir foss
mkdir gdev

sl ~/work
sl ~/home
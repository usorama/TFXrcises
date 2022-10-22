add-content -path c:/users/Dell/.ssh/config -value @'

Host ${hostname}
User ${user}
IdentityFile ${identityfile}
'@
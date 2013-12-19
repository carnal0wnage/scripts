

$computers = Get-Content computers.txt


Foreach( $computer in $computers ) {

  [object[]]$sessions = Invoke-Expression ".\PsLoggedon.exe -x -l \\$Computer" | 
    Where-Object {$_ -match '^\s{2,}((?<domain>\w+)\\(?<user>\S+))|(?<user>\S+)'} | 
    Select-Object @{ 
      Name='Computer' 
      Expression={$Computer} 
    }, 
    @{ 
      Name='Domain' 
      Expression={$matches.Domain} 
    }, 
    @{ 
      Name='User' 
      Expression={$Matches.User} 
    } 
    IF ($Sessions.count -ge 1) { 
      Write-Host ("{0} Users Logged into {1}" –f $Sessions.count,     
      $Computer) -ForegroundColor 'Red' 
    } 
    Else { 
      Write-Host ("{0} can be rebooted!" -f $Computer) ` 
      -ForegroundColor 'Green' 
    } 
}

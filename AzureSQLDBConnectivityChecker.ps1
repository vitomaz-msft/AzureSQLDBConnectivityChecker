## Copyright (c) Microsoft Corporation.
#Licensed under the MIT license.

#Azure SQL DB Connectivity Checker

#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

$serversToCheck = @('', '', '') #provide one or more, like @('server1', 'server2', 'server3'), you can add more than 3

# Parameter region when Invoke-Command -ScriptBlock is used
$parameters = $args[0]
if ($null -ne $parameters) {
    $serversToCheck = $parameters['serversToCheck']
}

function PrintDNSResults($dnsResult, [string] $dnsSource) {
    if ($dnsResult) {
        Write-Host 'Found DNS record in' $dnsSource '(IP Address:'$dnsResult.IPAddress')'
    }
    else {
        Write-Host 'Could not found DNS record in' $dnsSource
    }
}

function ValidateDNS([String] $serverName) {
    Try {
        Write-Host 'Validating DNS record for' $serverName

        $DNSfromHosts = Resolve-DnsName -Name $serverName -CacheOnly -ErrorAction SilentlyContinue
        PrintDNSResults $DNSfromHosts 'hosts file'

        $DNSfromCache = Resolve-DnsName -Name $serverName -NoHostsFile -CacheOnly -ErrorAction SilentlyContinue
        PrintDNSResults $DNSfromCache 'cache'

        $DNSfromCustomerServer = Resolve-DnsName -Name $serverName -DnsOnly -ErrorAction SilentlyContinue
        PrintDNSResults $DNSfromCustomerServer 'DNS server'

        $DNSfromAzureDNS = Resolve-DnsName -Name $serverName -DnsOnly -Server 208.67.222.222 -ErrorAction SilentlyContinue
        PrintDNSResults $DNSfromAzureDNS 'Open DNS'
    }
    Catch {
        Write-Host "Error at ValidateDNS" -Foreground Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

$gateways = @(
    New-Object PSObject -Property @{Region = "Australia Central"; Gateways = ("20.36.105.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Australia Central2"; Gateways = ("20.36.113.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Australia East"; Gateways = ("13.75.149.87", "40.79.161.1"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Australia South East"; Gateways = ("13.73.109.251"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Brazil South"; Gateways = ("104.41.11.5", "191.233.200.14"); Affected20191014 = $true; TRs = ('191.233.200.9') } #
    New-Object PSObject -Property @{Region = "Canada Central"; Gateways = ("40.85.224.249"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Canada East"; Gateways = ("40.86.226.166"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Central US"; Gateways = ("23.99.160.139", "13.67.215.62", "52.182.137.15", "104.208.21.1"); Affected20191014 = $true; TRs = ('13.89.168.16'); } #
    New-Object PSObject -Property @{Region = "China East"; Gateways = ("139.219.130.35"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "China East 2"; Gateways = ("40.73.82.1"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "China North"; Gateways = ("139.219.15.17"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "China North 2"; Gateways = ("40.73.50.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "East Asia"; Gateways = ("191.234.2.139", "52.175.33.150", "13.75.32.4"); Affected20191014 = $true; TRs = ('23.97.68.51') } #
    New-Object PSObject -Property @{Region = "East US"; Gateways = ("191.238.6.43", "40.121.158.30", "40.79.153.12", "40.78.225.32"); Affected20191014 = $true; TRs = ('40.76.42.44') } #
    New-Object PSObject -Property @{Region = "East US 2"; Gateways = ("191.239.224.107", "40.79.84.180", "52.177.185.181", "52.167.104.0", "104.208.150.3"); Affected20191014 = $true; TRs = ('104.208.233.240') } #CR1
    New-Object PSObject -Property @{Region = "France Central"; Gateways = ("40.79.137.0", "40.79.129.1"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Germany Central"; Gateways = ("51.4.144.100"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Germany North East"; Gateways = ("51.5.144.179"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "India Central"; Gateways = ("104.211.96.159"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "India South"; Gateways = ("104.211.224.146"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "India West"; Gateways = ("104.211.160.80"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Japan East"; Gateways = ("191.237.240.43", "13.78.61.196", "40.79.184.8", "40.79.192.5"); Affected20191014 = $true; TRs = ('13.78.104.0') } #
    New-Object PSObject -Property @{Region = "Japan West"; Gateways = ("191.238.68.11", "104.214.148.156", "40.74.97.10"); Affected20191014 = $true; TRs = ('40.74.115.153') } #
    New-Object PSObject -Property @{Region = "Korea Central"; Gateways = ("52.231.32.42"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "Korea South"; Gateways = ("52.231.200.86"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "North Central US"; Gateways = ("23.98.55.75", "23.96.178.199", "52.162.104.33"); Affected20191014 = $true; TRs = ('23.96.202.229') } #
    New-Object PSObject -Property @{Region = "North Europe"; Gateways = ("191.235.193.75", "40.113.93.91", "52.138.224.1"); Affected20191014 = $true; TRs = ('104.41.205.195') } #
    New-Object PSObject -Property @{Region = "South Africa North"; Gateways = ("102.133.152.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "South Africa West"; Gateways = ("102.133.24.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "South Central US"; Gateways = ("23.98.162.75", "13.66.62.124", "104.214.16.32"); Affected20191014 = $true; TRs = ('40.84.153.95') } #
    New-Object PSObject -Property @{Region = "South East Asia"; Gateways = ("23.100.117.95", "104.43.15.0", "40.78.232.3"); Affected20191014 = $true; TRs = ('104.43.10.74') } #
    New-Object PSObject -Property @{Region = "UAE Central"; Gateways = ("20.37.72.64"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "UAE North"; Gateways = ("65.52.248.0"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "UK South"; Gateways = ("51.140.184.11"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "UK West"; Gateways = ("51.141.8.11"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "West Central US"; Gateways = ("13.78.145.25"); Affected20191014 = $false }
    New-Object PSObject -Property @{Region = "West Europe"; Gateways = ("191.237.232.75", "40.68.37.158", "104.40.168.105"); Affected20191014 = $true; TRs = ('40.74.60.91') } #
    New-Object PSObject -Property @{Region = "West US"; Gateways = ("23.99.34.75", "104.42.238.205", "13.86.216.196"); Affected20191014 = $true; TRs = ('138.91.240.14') } #
    New-Object PSObject -Property @{Region = "West US 2"; Gateways = ("13.66.226.202"); Affected20191014 = $false }
)
$TRPorts = @('11000', '11001', '11010', '11020', '11050')

Try {
    #Despite computername and username will be used to calculate a hash string, this will keep you anonymous but allow us to identify multiple runs from the same user
    $StringBuilderHash = New-Object System.Text.StringBuilder
    [System.Security.Cryptography.HashAlgorithm]::Create("MD5").ComputeHash([System.Text.Encoding]::UTF8.GetBytes($env:computername + $env:username)) | ForEach-Object {
        [Void]$StringBuilderHash.Append($_.ToString("x2"))
    }

    $body = New-Object PSObject `
    | Add-Member -PassThru NoteProperty name 'Microsoft.ApplicationInsights.Event' `
    | Add-Member -PassThru NoteProperty time $([System.dateTime]::UtcNow.ToString('o')) `
    | Add-Member -PassThru NoteProperty iKey "a75c333b-14cb-4906-aab1-036b31f0ce8a" `
    | Add-Member -PassThru NoteProperty tags (New-Object PSObject | Add-Member -PassThru NoteProperty 'ai.user.id' $StringBuilderHash.ToString()) `
    | Add-Member -PassThru NoteProperty data (New-Object PSObject `
        | Add-Member -PassThru NoteProperty baseType 'EventData' `
        | Add-Member -PassThru NoteProperty baseData (New-Object PSObject `
            | Add-Member -PassThru NoteProperty ver 2 `
            | Add-Member -PassThru NoteProperty name '0.4'));

$body = $body | ConvertTo-JSON -depth 5;
Invoke-WebRequest -Uri 'https://dc.services.visualstudio.com/v2/track' -Method 'POST' -UseBasicParsing -body $body > $null
}
Catch { }

Clear-Host
Write-Host '******************************************' -ForegroundColor Green
Write-Host '  Azure SQL DB Connectivity Checker v0.4  ' -ForegroundColor Green
Write-Host '******************************************' -ForegroundColor Green
Write-Host

foreach ($serverName in $serversToCheck) {
    if ($serverName -and $serverName.Length -gt 0) {
        if (!$serverName.EndsWith('.database.windows.net')) {
            $serverName = $serverName + '.database.windows.net'
        }
        Write-Host
        Write-Host '##### Testing' $serverName '#####' -ForegroundColor Green
        Write-Host

        ValidateDNS $serverName

        try {
            $CR = [System.Net.DNS]::GetHostEntry($ServerName)
        }
        catch {
            Write-Host 'ERROR: Name resolution of' $serverName 'failed' -ForegroundColor Red
            continue
        }
        $CRaddress = $CR.AddressList[0].IPAddressToString
        $gateway = $gateways | Where-Object { $_.Gateways -eq $CRaddress }
        if (!$gateway) {
            Write-Host 'ERROR:' $CRaddress 'is not a valid gateway address, please check the DNS resolution' -ForegroundColor Red
            continue
        }
        $isCR1 = $CRaddress -eq $gateway.Gateways[0]

        Write-Host 'The server' $serverName 'is running on' $gateway.Region
        Write-Host 'The current gateway IP address is' $CRaddress
        Write-Host
        if ($gateway.Affected20191014) {
            Write-Host 'This region WILL be affected by the Gateway migration starting at Oct 14 2019!' -ForegroundColor Yellow
            if ($isCR1) {
                Write-Host 'and this server is running on one of the affected Gateways' -ForegroundColor Red
            }
            else {
                Write-Host 'but this server is NOT running on one of the affected Gateways (never was or already migrated)' -ForegroundColor Green
                Write-Host 'Please check other servers you may have in the region' -ForegroundColor Yellow
            }
        }
        else {
            Write-Host 'This region will NOT be affected by the Oct 14 2019 Gateway migration!' -ForegroundColor Green
        }
        Write-Host

        foreach ($gatewayAddress in $gateway.Gateways) {
            $testResult = Test-NetConnection $gatewayAddress -Port 1433 -WarningAction SilentlyContinue

            if ($testResult.TcpTestSucceeded) {
                Write-Host 'Tested (gateway) connectivity to' $gatewayAddress':1433 -> TCP test succeed' -ForegroundColor Green
            }
            else {
                Write-Host
                Write-Host 'Tested (gateway) connectivity to' $gatewayAddress':1433 -> TCP test FAILED' -ForegroundColor Red
                Write-Host 'Please make sure you fix the connectivity from this machine to' $gatewayAddress':1433 to avoid issues!' -ForegroundColor Red
                Write-Host
            }
        }

        if ($gateway.TRs) {
            Write-Host
            Write-Host 'Redirect Policy related tests:'
            $redirectSucceeded = 0
            $redirectTests = 0
            foreach ($tr in $gateway.TRs) {
                foreach ($port in $TRPorts) {
                    $testRedirectResults = Test-NetConnection $tr -Port $port -WarningAction SilentlyContinue
                    if ($testRedirectResults.TcpTestSucceeded) {
                        $redirectTests += 1
                        $redirectSucceeded += 1
                        Write-Host 'Tested (redirect) connectivity to' $tr':'$port '-> TCP test succeeded' -ForegroundColor White
                    }
                    else {
                        $redirectTests += 1
                        Write-Host 'Tested (redirect) connectivity to' $tr':'$port '-> TCP test FAILED' -ForegroundColor White
                    }
                }
            }
            Write-Host
            Write-Host 'Tested (redirect) connectivity' $redirectTests 'times and' $redirectSucceeded 'of them succeeded' -ForegroundColor Green
            Write-Host
            Write-Host 'Please note this was just some tests to check connectivity using the 11000-11999 port range, not your database' -ForegroundColor Yellow
            if ($redirectSucceeded / $redirectTests -ge 0.5 ) {
                Write-Host 'Based on the result it is likely the Redirect Policy will work from this machine' -ForegroundColor Green
            }
            else {
                Write-Host 'Based on the result the Redirect Policy MAY NOT work from this machine, this can be expected for connections from outside Azure' -ForegroundColor Red
            }
            Write-Host 'Please check more about Azure SQL Connectivity Architecture at https://docs.microsoft.com/en-us/azure/sql-database/sql-database-connectivity-architecture' -ForegroundColor Yellow
            Write-Host
        }
    }
}
Write-Host 'All tests are now done!' -ForegroundColor Green
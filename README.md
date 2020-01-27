# Azure SQL DB Connectivity Checker

This PowerShell script will run some connectivity checks from this machine to the server and database.

**In order to run it you need to:**
1. Open Windows PowerShell ISE
 
2. Open a New Script window
 
3. Paste the following in the script window (please note that, except databases and credentials, the other parameters are optional):

```powershell
$parameters = @{
    Server = '.database.windows.net'
    Database = ''
}
 
$ProgressPreference = "SilentlyContinue";
$scriptUrlBase = 'raw.githubusercontent.com/vitomaz-msft/AzureSQLDBConnectivityChecker/master/'
Invoke-Command -ScriptBlock ([Scriptblock]::Create((iwr ($scriptUrlBase+'/AzureSQLDBConnectivityChecker.ps1')).Content)) -ArgumentList $parameters
#end
```
4. Set the parameters on the script, you need to set server name and database name.

5. Run it.

6. The results can be seen in the output window. 
If the user has the permissions to create folders, a folder with the resulting log file will be created.
When running on Windows, the folder will be opened automatically after the script completes.

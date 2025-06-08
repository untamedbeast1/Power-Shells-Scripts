# Define the username of the Active Directory account to be disabled.

$username = "TestUsername"

# Define the path for the output log file.
# Ensure the path exists and the script has write permissions to it.
$output_file_path = "C:\Users\account_status.txt"

# Define the message to be written to the log file and displayed in the console.
$output_message = "Account $username has been disabled."

# --- Script Actions ---

# Disable the Active Directory account specified by $username.
# This command requires the ActiveDirectory module to be installed on the system
# where the script is executed.
# Example: Install-WindowsFeature -Name GPMC,RSAT-ADDS -IncludeManagementTools
Disable-ADAccount -Identity $username

# Write the output message to the specified text file.

# Set-Content will overwrite the file if it exists, or create it if it doesn't.
Set-Content -Path $output_file_path -Value $output_message

# Display the output message in the PowerShell console.
Write-Output $output_message



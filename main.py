import platform
import subprocess
import argparse
import sys

def check_command_installed(command):
    """ Check if a command is installed """
    result = subprocess.run(['which', command], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return result.returncode == 0

def run_powershell_script(script_path):
    try:
        subprocess.run(["pwsh", "-File", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running PowerShell script: {e}")

def run_bash_script(script_path):
    try:
        subprocess.run(["bash", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running Bash script: {e}")

def main():
    parser = argparse.ArgumentParser(description="Monitor system using Bash or PowerShell scripts")
    parser.add_argument('--bash', action='store_true', help='Run the Bash script')
    parser.add_argument('--powershell', action='store_true', help='Run the PowerShell script')
    args = parser.parse_args()

    if not args.bash and not args.powershell:
        print("Error: You must specify either --bash or --powershell")
        sys.exit(1)

    current_platform = platform.system()

    if current_platform == "Linux":
        if args.powershell:
            if check_command_installed('pwsh'):
                print("Detected platform: Linux. Running PowerShell script.")
                run_powershell_script("monitor_pwsh.ps1")
            else:
                print("Error: PowerShell (pwsh) is not installed.")
        elif args.bash:
            print("Detected platform: Linux. Running Bash script.")
            run_bash_script("monitor.sh")
    elif current_platform == "Windows":
        if args.powershell:
            print("Detected platform: Windows. Running PowerShell script.")
            run_powershell_script("monitor.ps1")
        elif args.bash:
            if check_command_installed('bash'):
                print("Detected platform: Windows. Running Bash script.")
                run_bash_script("monitor.sh")
            else:
                print("Error: Bash is not installed.")
    else:
        print(f"Unsupported platform: {current_platform}")

if __name__ == "__main__":
    main()

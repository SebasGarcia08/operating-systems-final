import platform
import subprocess

def run_powershell_script(script_path):
    try:
        subprocess.run(["powershell", "-File", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running PowerShell script: {e}")

def run_bash_script(script_path):
    try:
        subprocess.run(["bash", script_path], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error running Bash script: {e}")

def main():
    # Paths to the scripts
    powershell_script_path = "monitor.ps1"
    bash_script_path = "monitor.sh"

    current_platform = platform.system()

    if current_platform == "Windows":
        print("Detected platform: Windows")
        run_powershell_script(powershell_script_path)
    elif current_platform in ["Linux", "Darwin"]:
        print(f"Detected platform: {current_platform}")
        run_bash_script(bash_script_path)
    else:
        print(f"Unsupported platform: {current_platform}")

if __name__ == "__main__":
    main()

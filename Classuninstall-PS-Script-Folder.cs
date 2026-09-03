using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.ComponentModel;
using System.Configuration.Install;
using System.IO;
using System.Collections;

namespace Sea_Trials_Script_Launcher
{
    [RunInstaller(true)]
    public class CustomActions : Installer
    {
        public override void Uninstall(IDictionary savedState)
        {
            base.Uninstall(savedState);
            DeleteScriptFolder();
        }

        private void DeleteScriptFolder()
        {
            string targetDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "VS_Scripts");
            string logFile = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "UninstallLog.txt");
            StreamWriter writer = null;
            if (Directory.Exists(targetDirectory))
            {
                try
                {
                    writer = new StreamWriter(logFile, true);
                    Directory.Delete(targetDirectory, true);
                    writer.WriteLine($"{DateTime.Now}: Script folder deleted successfully.");
                }
                catch (Exception ex)
                {
                    writer.WriteLine($"{DateTime.Now}: An error occurred: " + ex.Message);
                }
            }
            else
            {
                writer.WriteLine($"{DateTime.Now}: Script folder does not exist.");
            }
        }
    }
}

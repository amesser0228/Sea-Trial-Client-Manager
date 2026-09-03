using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

namespace Sea_Trials_Script_Launcher
{
    public class VS_Scripts_Helper
    {
        private string folderPath;

        public VS_Scripts_Helper(string directoryPath) {

            folderPath = directoryPath;

        }

        public string[] GetScripts() { 
        
            return Directory.GetFiles(folderPath);
        }
    }
}

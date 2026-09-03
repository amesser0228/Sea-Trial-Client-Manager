using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Sea_Trials_Script_Launcher
{
    public static class toolTipHelper
    {
        public static void SetToolTip(Control control, string tooltipText)
        {
            ToolTip tooltip = new ToolTip
            {
                AutoPopDelay = 5000,
                InitialDelay = 1000,
                ReshowDelay = 500,
                ShowAlways = true
            };
            tooltip.SetToolTip(control, tooltipText);
        }
    }
}



using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace WindowsFormsApplication1
{
    public partial class Form1 : Form
    {
        IDataObject ido = new DataObject();
      

        public Form1()
        {
            InitializeComponent();
        }
           
            
            private void button1_Click(object sender, System.EventArgs e)
{
   

 ido = Clipboard.GetDataObject();
            var data = (MemoryStream)ido.GetData("MathML");

            if (data == null)
            {
                textBox2.Text = "No MathML on Clipboard";
            }
            else
            {
                string mathMl;
                using (data)
                {
                    using (var sr = new StreamReader(data))
                    {
                        mathMl = sr.ReadToEnd();
                    }
                }

                textBox2.Text = mathMl.Replace("><", ">\r\n<");
            }
          // good, for text
            //textBox2.Text = (string)ido.GetData(DataFormats.UnicodeText);
            }

        }
     
    }


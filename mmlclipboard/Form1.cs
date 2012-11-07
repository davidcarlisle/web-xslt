using System;
using System.IO;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Text.RegularExpressions;
using System.Xml;
using System.Xml.Linq;

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
                textBox2.Text = "No MathML on Clipboard\r\nAvailable formats:\r\n";
                for (var i = 0; i < ido.GetFormats().Length; i++)
                {
                    textBox2.Text += ido.GetFormats()[i];
                    textBox2.Text += "\r\n";
                }

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

        private void button2_Click(object sender, System.EventArgs e)
        {
            string str1 = "X<?xml version=\"1.0\" encoding=\"UTF-16\"?><math xmlns=\"http://www.w3.org/1998/Math/MathML\"><mfrac><mi>a</mi><mi>b</mi></mfrac></math>";
            Byte[] str2 = System.Text.Encoding.Unicode.GetBytes(str1);
            str2[0] = 255;
            str2[1] = 254;

            MemoryStream clp = new MemoryStream(str2);
            Clipboard.SetData("MathML", clp);
        }
        private void button3_Click(object sender, System.EventArgs e)
        {
            string str0 = textBox2.Text;
            XmlReader reader = XmlReader.Create(new StringReader(str0));
            try
            {
                XDocument testdoc = new XDocument(XDocument.Parse(str0));

                string str1 = Regex.Replace(str0, @"^(<\?xml.*\?>)?", "X<?xml version=\"1.0\" encoding=\"UTF-16\"?>");
                Byte[] str2 = System.Text.Encoding.Unicode.GetBytes(str1);
                str2[0] = 255;
                str2[1] = 254;
                MemoryStream clp = new MemoryStream(str2);
                Clipboard.SetData("MathML", clp);
            }
            catch (Exception xmlerr)
            {
                textBox2.Text = "\r\nXML error Data not copied:\r\n\r\n" + xmlerr.Message + "\r\n-----\r\n" + textBox2.Text;
            }

        }

    }


}


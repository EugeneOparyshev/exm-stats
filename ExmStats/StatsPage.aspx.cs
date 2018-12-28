namespace ExmStats
{
    using System;
    using System.Collections.Generic;
    using System.Web.UI.WebControls;

    public partial class StatsPage : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Label1.Text = "-";
            Label2.Text = "-";
            Label3.Text = "-";
            Label4.Text = "-";
            Label5.Text = "-";
            Label6.Text = "-";
            Label7.Text = "-";
            Label8.Text = "-";
            Label9.Text = "-";
            Label10.Text = "-";
            Label11.Text = "-";
            Label12.Text = "-";
            Label13.Text = "-";
            Label14.Text = "-";
            Label15.Text = "-";
            Label16.Text = "-";
        }

        #region validation part

        public bool ValidateData(TextBox MessageIdTextBox, TextBox MessageRootTextBox)
        {
            Guid result;
            Guid result2;
            return Guid.TryParse(MessageIdTextBox.Text, out result) && Guid.TryParse(MessageRootTextBox.Text, out result2);
        }

        #endregion

        #region SQL part
        
        public string IntegrateMessageIDandRoot()
        {
            string formattedMessageRoot = MessageRootTextBox.Text.Replace("-", string.Empty).ToLower();
            string formattedMessageId = MessageIdTextBox.Text.Replace("-", string.Empty).ToLower();
            return (formattedMessageRoot + "_" + formattedMessageId);
        }
        
        public string FindEventInDimensionKey(string dimensionkey)
        {
            int numberLocation = StringExtensions.FindIndexOfEvent(dimensionkey, '_', 2)+1;
            int numberLocation2 = StringExtensions.FindIndexOfEvent(dimensionkey, '_', 3);
            int symbolLength = numberLocation2 - numberLocation;
            return dimensionkey.Substring(numberLocation, symbolLength);
        }

        public void CheckRowEventType(string eventType, string visitsRowValue, string countRowValue)
        {
            switch (eventType)
            {
                //unspecified
                case "0":
                
                //opened
                case "1":
                    Label2.Text = IncrementEventNumber(Label2.Text, visitsRowValue);
                    Label4.Text = IncrementEventNumber(Label4.Text, countRowValue);
                    break;
                
                //clicked
                case "4":
                    Label3.Text = IncrementEventNumber(Label3.Text, visitsRowValue);
                    Label5.Text = IncrementEventNumber(Label5.Text, countRowValue);
                    break;
               
                //unsubscribed
                case "16":
                    Label7.Text = IncrementEventNumber(Label7.Text, visitsRowValue);
                    break;

                //bounced
                case "32":
                    Label6.Text = IncrementEventNumber(Label6.Text, visitsRowValue);
                    break;
                //sent
                case "64":
                    Label1.Text = IncrementEventNumber(Label1.Text, visitsRowValue);
                    break;
                
                //spam
                case "128":
                    Label8.Text = IncrementEventNumber(Label1.Text, visitsRowValue);
                    break;
                default:
                    break;
            }
        }

        private string IncrementEventNumber(string output, string rowvalue)
        {
            int currentNumber;
            int numberOfInteractions;
            Int32.TryParse(output, out currentNumber);
            Int32.TryParse(rowvalue, out numberOfInteractions);
            return (currentNumber + numberOfInteractions).ToString();
        }
        #endregion

        #region Mongo part

        public List<string> CreateMongoInteractionsList()
        {
            return new List<string>()
            {
                "Email Sent",
                "Email Opened",
                "Click Email Link",
                "Email Opened First Time",
                "First Click Email Link",
                "Email Bounced",
                "Unsubscribe from email",  
                "Email Spam Reported"
            };
        }

        public List<Label> CreateMongoControlsList()
        {
            return new List<Label>()
            {
                Label9,
                Label10,
                Label11,
                Label12,
                Label13,
                Label14,
                Label15,
                Label16
            };
        }
        #endregion Sql part  
    }
}
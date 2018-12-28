<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="StatsPage.aspx.cs" Inherits="ExmStats.StatsPage" %>
<%@ Import Namespace="ExmStats" %>
<%@ Import Namespace="MongoDB.Driver" %>
<%@ Import Namespace="MongoDB.Bson" %>
<%@ Import Namespace="System.Data.SqlClient" %>

<!DOCTYPE html>

<script runat="server">

        protected void Button1_Click(object sender, EventArgs e)
        {
            bool flag = ValidateData(MessageIdTextBox, MessageRootTextBox);

            if (flag)
            {
                RequestMongoData();
                RequestSqlData();
            }

        }

        private void RequestSqlData()
        {
            string reportingConnectionString = ConfigurationManager.ConnectionStrings["reporting"].ConnectionString;
            using (SqlConnection myConnection = new SqlConnection(reportingConnectionString))
            {
                string requestToSql = String.Format("Select * FROM [dbo].[ReportDataView] WHERE [SegmentId] = '7558FC89-C25F-4606-BBC5-43B91A382AC9' and DimensionKey like '%{0}%'", IntegrateMessageIDandRoot());
                SqlCommand cmd = new SqlCommand(requestToSql, myConnection);
                myConnection.Open();

                using (SqlDataReader oReader = cmd.ExecuteReader())
                {
                    while (oReader.Read())
                    {
                        string dimensionkey = oReader["DimensionKey"].ToString();
                        string visitsRowValue = oReader["Visits"].ToString();
                        string countRowValue = oReader["Count"].ToString();
                        string eventOfRow = FindEventInDimensionKey(dimensionkey);
                        CheckRowEventType(eventOfRow, visitsRowValue, countRowValue);
                    }

                    myConnection.Close();
                }
            }
        }

        private void RequestMongoData()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["analytics"].ConnectionString;
            MongoUrl mongoUrl = new MongoUrl(connectionString);
            var server = new MongoClient(connectionString).GetServer();
            var db = server.GetDatabase(mongoUrl.DatabaseName);
            //
            var col = db.GetCollection<BsonDocument>("Interactions");
            var mongoInteractionsList = CreateMongoInteractionsList();
            var mongoControlsList = CreateMongoControlsList();
            for (int i = 0; i < mongoInteractionsList.Count; i++)
            {
                IMongoQuery mongoQuery = MongoDB.Driver.Builders.Query.EQ("Pages.PageEvents.Name", mongoInteractionsList[i]);
                IMongoQuery mongoQuery2 = MongoDB.Driver.Builders.Query.Matches("Pages.PageEvents.Data", new BsonRegularExpression(MessageIdTextBox.Text));
                IMongoQuery interSectionQuery = MongoDB.Driver.Builders.Query.And(mongoQuery, mongoQuery2);
                var resultQuery = col.Find(interSectionQuery);
                mongoControlsList[i].Text = resultQuery.ToList().Count.ToString();
                //
            }
        }        
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <style type="text/css">
        #form1 {
            height: 578px;
            width: 837px;
        }
    </style>
</head>
<body style="height: 675px">
    <form id="form1" runat="server">
    <div>
    
        <br />
        <br />
        <br />
        <br />
        <br />
        <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Message Root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Message ID</div>
        <br />
        <br />
        <asp:TextBox ID="MessageRootTextBox" runat="server" Width="255px"></asp:TextBox>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:TextBox ID="MessageIdTextBox" runat="server" Width="261px"></asp:TextBox>
        <br />
        <br />
        <asp:Label ID="Label17" runat="server" Font-Bold="True" Font-Italic="False" Font-Size="Larger" ForeColor="#FF3300" Text=" "></asp:Label>
        <br />
        <br />
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Check SQL" />
        <br />
        <br />
        <br />
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Sent&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Opened&nbsp;&nbsp;&nbsp;&nbsp; Clicked&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Unique Opened&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Unique Clicked&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Bounced&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Unsubscribed&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Spam&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<br />
        <br />
        Analytics&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <div style="display:inline-block;">
        <asp:Label ID="Label9" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;
        <asp:Label ID="Label10" runat="server" Text="-"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
        <asp:Label ID="Label11" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label12" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;
        <asp:Label ID="Label13" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label14" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
        <asp:Label ID="Label15" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label16" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </div>
        <br />
        <br />
        SQL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <div style="display:inline-block;">
        <asp:Label ID="Label1" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;
        <asp:Label ID="Label2" runat="server" Text="-"></asp:Label>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
        <asp:Label ID="Label3" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label4" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;
        <asp:Label ID="Label5" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label6" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;
        <asp:Label ID="Label7" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:Label ID="Label8" runat="server" Text="-"></asp:Label>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </div>
    </form>
</body>
</html>

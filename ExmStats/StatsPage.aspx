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
            height: 366px;
            width: 793px;
        }
		#table {
            text-align:center;
        }
    </style>
</head>
<body style="height: 675px">
    <form id="form1" runat="server">
    <div>
    
        Message Root&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox ID="MessageRootTextBox" runat="server" Width="255px"></asp:TextBox>
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <br />
        <br />
        Message ID&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <asp:TextBox ID="MessageIdTextBox" runat="server" Width="261px"></asp:TextBox>
        </div>
        <br />

        <asp:Label ID="Label17" runat="server" Font-Bold="True" Font-Italic="False" Font-Size="Larger" ForeColor="#FF3300" Text=" "></asp:Label>
        <asp:Button ID="Button1" runat="server" OnClick="Button1_Click" Text="Check databases" />
        <br />
        <br />
        <br />
        <table style="width:40%">
  <tr>
    <th></th>
    <th>Analytics</th> 
    <th>Reporting</th>
  </tr>
  <tr>
    <td>Sent</td>
    <td id="table"><asp:Label ID="Label9" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label1" runat="server" Text="-"></asp:Label></td>
  </tr>
  <tr>
    <td>Opened</td>
    <td id="table"><asp:Label ID="Label10" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label2" runat="server" Text="-"></asp:Label></td>
  </tr>
  <tr>
    <td>Clicked</td>
    <td id="table"><asp:Label ID="Label11" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label3" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unique Opened</td>
    <td id="table"><asp:Label ID="Label12" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label4" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unique Clicked</td>
    <td id="table"><asp:Label ID="Label13" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label5" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Bounced</td>
    <td id="table"><asp:Label ID="Label14" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label6" runat="server" Text="-"></asp:Label></td>
  </tr>
              <tr>
    <td>Unsubscribed</td>
    <td id="table"><asp:Label ID="Label15" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label7" runat="server" Text="-"></asp:Label></td>
  </tr>
            <tr>
    <td>Bounced</td>
    <td id="table"><asp:Label ID="Label16" runat="server" Text="-"></asp:Label></td>
    <td id="table"><asp:Label ID="Label8" runat="server" Text="-"></asp:Label></td>
  </tr>

</table>
        
        </div>
    </form>
</body>
</html>
